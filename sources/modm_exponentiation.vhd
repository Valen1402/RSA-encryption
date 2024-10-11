----------------------------------------------------------------------------
-- Modulo m exponentiation (modm_exponentiation.vhd)
-- defines: modm_exponentiation
----------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity exponentiation 

entity modm_exponentiation is
  generic(
    k: integer ; -- number of bits 
    log_k: integer -- to instantiate the loop count variable
  );
  port (
    x, y, m: in std_logic_vector(k-1 downto 0); --inputs 
    clk, reset: in std_logic; 
    z: out std_logic_vector(k-1 downto 0);
    done: out std_logic;
    stage: out std_logic_vector(3 downto 0)
  );
end modm_exponentiation;

-- architecure 

architecture rtl of modm_exponentiation is
 -- used signals for datapath 

  signal p, second_operand, product, int_x, register_in: std_logic_vector(k-1 downto 0);
  constant one: std_logic_vector(k-1 downto 0) := (0 => '1', others => '0');
  -- control signals for datapath 
  
  signal save, update, step_type, load, reg_en, x_i, finished: std_logic;
  signal mult_reset, done_mul: std_logic;
  
  -- state machine type declaration 
  
  type state is (Init, Prepare_sqr, Compute_sqr, End_sqr, Do_mul, Prepare_mul, Compute_mul, End_mul, More, Done_st);
  signal current_state, next_state: state;
  
  -- loop variable count and zero to check 
  
  signal count: std_logic_vector(log_k-1 downto 0);
  constant zero : std_logic_vector(log_k-1 downto 0) := (others => '0');

-- component declaration 

  component modm_multiplier is
    generic(
      k: integer;
      log_k: integer
    );
    port (
      x, y, m: in std_logic_vector(k-1 downto 0);
      clk, reset: in std_logic;
      z: out std_logic_vector(k-1 downto 0);
      done: out std_logic
    );
  end component;


-- architecture begins 

begin

--multiplier instantiation 

  main_component: modm_multiplier
    generic map(
      k => k,
      log_k => log_k
    )
    port map(
      x => p, 
      y => second_operand, 
      m => m,
      clk => clk, 
      reset => mult_reset, 
      z => product, 
      done => done_mul
    );

  --laod signal to load the product register 
 
  with load select register_in <= one when '1', product when others;

 -- to select the second operand of multiplier in SQR and MULT states 
 
  with step_type select second_operand <= p when '0', y when others;

-- to ENABLE product save register 

  reg_en <= save or load;

--parrallel register to save product at each state 

  parallel_register: process(clk)
    begin
    if clk'event and clk = '1' then
      if reg_en = '1' then 
        p <= register_in;
      end if;
    end if;
  end process parallel_register;

-- product goes to z and only valid when mult_done = '1' 

  z <= p;

-- update register to have loop for each element of x 

  shift_register: process(clk)
  begin
  if clk'event and clk='1' then
    if load = '1' then 
      int_x <= x;
    elsif update = '1' then 
      for i in k-1 downto 1 loop int_x(i) <= int_x(i-1); end loop;
      int_x(0) <= '0'; --update operation 
    end if;
  end if;
  end process shift_register;

--MSB of the x_int 

  x_i <= int_x(k-1);

--counter loop variable 

  counter: process(clk)
  begin
    if clk'event and clk = '1' then
      if load = '1' then 
	count <= std_logic_vector(to_unsigned(k-1, log_k));
      elsif update = '1' then 
	count <= std_logic_vector(unsigned(count) - to_unsigned(1, log_k)); --decrementing 
      end if;
    end if;
  end process counter; 

-- when the count = 0 then the loop ends and result is ready at p or z 

  finished <= '1' when count = zero else '0';


--FSM register 

  fsm_state_update: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1'
        then current_state <= Init; --INIT is the intial state 
        else current_state <= next_state;
      end if;
    end if;
  end process fsm_state_update;


-- FSM state change 

  fsm_next_state: process(current_state, x_i, done_mul, finished)
  begin
    next_state <= current_state;
    case current_state is
      when Init         => next_state <= Do_mul; -- goes to Do_Mul 
      when Do_mul       => if x_i = '1' then next_state <= Prepare_mul; else next_state <= More; end if;
      when Prepare_mul  => next_state <= Compute_mul;
      when Compute_mul  => if done_mul = '1' then next_state <= End_mul; end if;
      when End_mul      => next_state <= More;
      when Prepare_sqr  => next_state <= Compute_sqr;
      when Compute_sqr  => if done_mul = '1' then next_state <= End_sqr; end if;
      when End_sqr      => next_state <= Do_mul;
      when More         => if finished = '1' then next_state <= Done_st; else next_state <= Prepare_sqr; end if;
      when Done_st      =>  -- stays in the done_st state
    end case;
  end process fsm_next_state;
   
   
   -- FSM outputs 
   
  fsm_output: process(current_state)
  begin
    case current_state is
      when Init        
                     => save <='0'; update <= '0' ; step_type <= '0'; load <= '1' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(1, 4));
      when Do_mul      
                     => save <='0'; update <= '0' ; step_type <= '0'; load <= '0' ; done <= '0'; mult_reset <= '1' ; stage <= std_logic_vector(to_unsigned(2, 4));
      when Prepare_mul  
                     => save <='0'; update <= '0' ; step_type <= '1'; load <= '0' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(3, 4));
      when Compute_mul  
                     => save <='0'; update <= '0' ; step_type <= '1'; load <= '0' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(4, 4));
      when End_mul    
                     => save <='1'; update <= '0' ; step_type <= '1'; load <= '0' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(5, 4));
      when Prepare_sqr  
                     => save <='0'; update <= '0' ; step_type <= '0'; load <= '0' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(6, 4));
      when Compute_sqr   
                     => save <='0'; update <= '0' ; step_type <= '0'; load <= '0' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(7, 4));
      when End_sqr     
                     => save <='1'; update <= '0' ; step_type <= '0'; load <= '0' ; done <= '0'; mult_reset <= '0' ; stage <= std_logic_vector(to_unsigned(8, 4));
      when More        
                     => save <='0'; update <= '1' ; step_type <= '0'; load <= '0' ; done <= '0'; mult_reset <= '1' ; stage <= std_logic_vector(to_unsigned(9, 4));
      when Done_st     
                     => save <='0'; update <= '0' ; step_type <= '0'; load <= '0' ; done <= '1'; mult_reset <= '1' ;
    end case;
  end process fsm_output;

end rtl;