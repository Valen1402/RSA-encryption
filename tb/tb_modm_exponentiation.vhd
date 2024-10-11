library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity tb_exponentiation is
end tb_exponentiation;

architecture Behavioral of tb_exponentiation is


  constant k: integer := 192; 
  constant log_k: integer := 58; 
   
  constant m : std_logic_vector(k-1 downto 0) := (191 downto 17 => '1', 15 downto 0 => '1', others => '0');
  
  signal x, y, z: std_logic_vector(k-1 downto 0);
  signal clk, reset, done: std_logic := '0';
  signal stage: std_logic_vector(3 downto 0);

  -- Instantiate the modm_exponentiation component
  component modm_exponentiation
    generic (
      k: integer;
      log_k: integer 
    );
    port (
      x, y, m: in std_logic_vector(k-1 downto 0);
      clk, reset: in std_logic;
      z: out std_logic_vector(k-1 downto 0);
      done: out std_logic;
      stage: out std_logic_vector(3 downto 0)
    );
  end component;



  -- Instantiate the modm_exponentiation entity
  begin
    dut1: modm_exponentiation
      generic map (
        k => k,
        log_k => log_k 
      )
      port map (
        x => x,
        y => y,
        m => m,
        clk => clk,
        reset => reset,
        z => z,
        done => done,
        stage => stage
      );
   
   
  process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
  
  reset <= '1'; 
  wait for 10 ns ; 
  reset <= '0'; 
  --(2**192)-1-(2**16)
  x <= (191 downto 0 => '1');
  y <= (190 downto 0 => '1', others => '0');
  wait until done = '1';
  wait; 
  end process stim_proc;
  
      
  end Behavioral;