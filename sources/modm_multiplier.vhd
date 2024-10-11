----------------------------------------------------------------------------
-- Modulo m multiplier (modm_multiplier.vhd)
-- defines: modm_multiplier
----------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modm_multiplier is
  generic (
    k: integer;
    log_k: integer
  );
  port (
    x, y, m: in std_logic_vector(k-1 downto 0);
    clk, reset: in std_logic;
    z: out std_logic_vector(k-1 downto 0);
    done: out std_logic
  );
end modm_multiplier;

architecture rtl of modm_multiplier is
  signal p, second_operand, sum, int_x: std_logic_vector(k-1 downto 0);
  signal step_type, ce_p, condition, load, x_i, update, equal_zero: std_logic;
  type states is (Init, Add, Dbl, Finished);
  signal current_state, next_state: states;
  signal count: std_logic_vector(log_k-1 downto 0);
  constant zero : std_logic_vector(log_k-1 downto 0) := (others => '0');

  component modm_adder is
  generic (
    k: integer
  );
    port (
      x, y, m: in std_logic_vector(k-1 downto 0);
      z: out std_logic_vector(k-1 downto 0)
    );
  end component;

begin
  with step_type select second_operand <= p when '0', y when others;

  main_component: modm_adder 
    generic map
      ( k => k )
    port map
      ( 
        x => p, 
	y => second_operand, 
	m => m, 
	z => sum
      );

  condition <= ce_p and (not(step_type) or x_i);

  parallel_register: process(clk)
  begin
    if clk'event and clk = '1' then
      if load = '1' then 
        p <= (others => '0');
      elsif condition = '1' then 
        p <= sum;
      end if;
    end if;
  end process parallel_register;

  equal_zero <= '1' when count = zero else '0';

  z <= p;

  shift_register: process(clk)
  begin
    if clk'event and clk='1' then
      if load = '1' then 
	int_x <= x;
      elsif update = '1' then
	for i in k-1 downto 1 loop int_x(i) <= int_x(i-1); end loop;
	int_x(0) <= '0';
      end if;
    end if;
  end process shift_register;

  x_i <= int_x(k-1);

  counter: process(clk)
  begin
    if clk'event and clk = '1' then
      if load = '1' then 
	count <= std_logic_vector(to_unsigned(k-1, log_k));
      elsif update = '1' then 
	count <= std_logic_vector(unsigned(count) - to_unsigned(1, log_k));
      end if;
    end if;
  end process counter; 

  fsm_state_update: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1'
        then current_state <= Init;
        else current_state <= next_state;
      end if;
    end if;
  end process fsm_state_update;

  fsm_next_state: process(current_state, equal_zero)
  begin
    next_state <= current_state;
    case current_state is
      when Init => next_state <= Add;
      when Add  => if equal_zero = '1' 
		     then next_state <= Finished; 
		     else next_state <= Dbl;
		   end if;
      when Dbl  => next_state <= Add;
      when Finished  => 
    end case;
  end process fsm_next_state;

  fsm_output: process(current_state)
  begin
    case current_state is
      when Init      =>  step_type <= '0'; ce_p <= '0'; load <= '1'; update <= '0'; done <= '0';
      when Add       =>  step_type <= '1'; ce_p <= '1'; load <= '0'; update <= '1'; done <= '0';
      when Dbl       =>  step_type <= '0'; ce_p <= '1'; load <= '0'; update <= '0'; done <= '0';
      when Finished  =>  step_type <= '0'; ce_p <= '0'; load <= '0'; update <= '0'; done <= '1';
    end case;
  end process fsm_output;

end rtl;
