library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modm_adder is
  generic (
    k : integer
  );
  port (
    x, y, m: in std_logic_vector(k-1 downto 0);
    z: out std_logic_vector(k-1 downto 0)
  );
end modm_adder;


architecture rtl of modm_adder is
  signal long_x, sum1, long_z1, sum2: std_logic_vector(k downto 0);
  signal c1, c2, sel: std_logic;
  signal z1, z2: std_logic_vector(k-1 downto 0);
  signal minus_m: std_logic_vector(k-1 downto 0);

begin
  minus_m <= std_logic_vector( - signed(m) );
  long_x <= '0' & x;
  sum1 <= std_logic_vector(unsigned(long_x) + unsigned(y));
  c1 <= sum1(k);
  z1 <= sum1(k-1 downto 0);
  long_z1 <= '0' & z1;
  sum2 <= std_logic_vector(unsigned(long_z1) + unsigned(minus_m));
  c2 <= sum2(k);
  z2 <= sum2(k-1 downto 0);
  
  sel <= c1 or c2;
  with sel select z <= z1 when '0', z2 when others;
end rtl;
