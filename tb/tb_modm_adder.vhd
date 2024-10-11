------------------------------------------------------------
-- Testbench for modulo m adder (tb_modm_adder.vhd)
-- defines: tb_modm_adder
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_modm_adder is
end tb_modm_adder;
 
architecture behavior of tb_modm_adder is 
  constant k : integer := 8;
  constant m : std_logic_vector := std_logic_vector ( to_unsigned(239, k));
 
  component modm_addition
    generic(
      k: integer
    );
    port(
      x, y, m : in  std_logic_vector(k-1 downto 0);
      z : out  std_logic_vector(k-1 downto 0)
    );
  end component;
    
  component modm_adder
    generic(
      k: integer
    );
    port(
      x, y, m : in  std_logic_vector(k-1 downto 0);
      z : out  std_logic_vector(k-1 downto 0)
    );
  end component;
   
  signal x, y: std_logic_vector(k-1 downto 0) := (others => '0');
  signal z1: std_logic_vector(k-1 downto 0) := (others => '0');
 
begin
  --dut1: modm_addition 
  dut1: modm_adder
    generic map (
      k => k
    )
    port map (
      x => x,
      y => y,
      m => m,
      z => z1
    );

  stim_proc: process
  begin		
    x <= std_logic_vector(to_unsigned(215, k));
    y <= std_logic_vector(to_unsigned(35, k));		
    wait for 100 ns;	

    wait;
  end process;

end;
