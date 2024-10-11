----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2023 11:01:01
-- Design Name: 
-- Module Name: RSA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity RSA is
  Port ( 
         clk : in std_logic;
         sw1 : in std_logic ; 
         sw2 : in std_logic ; 
         btn: in std_logic;
         led: out std_logic;
         seg: out std_logic_vector(6 downto 0);
         dp : out std_logic;
         an : out std_logic_vector(3 downto 0)         
         );
         
         

end RSA;

architecture Behavioral of RSA is

  component modm_exponentiation
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
  
  
    component display
    port ( 
      clk            : in std_logic;
      seg            : out std_logic_vector(6 downto 0);
      dp             : out std_logic;
      an             : out std_logic_vector(3 downto 0);
      hex2led_int1   : in std_logic_vector(3 downto 0);
      hex2led_int2   : in std_logic_vector(3 downto 0);
      hex2led_int3   : in std_logic_vector(3 downto 0);
      hex2led_int4   : in std_logic_vector(3 downto 0)
    );
  end component;


  signal cleartext : std_logic_vector(15 downto 0) := "1000000000000000"; --0x8000
  signal cryptotext : std_logic_vector(15 downto 0) := x"F20F";
  signal priv_k : std_logic_vector(15 downto 0) := x"D4BF";
  signal publ_k : std_logic_vector(15 downto 0)  := x"007F";
  signal n : std_logic_vector(15 downto 0) := x"F797";
  
  signal x,y,z : std_logic_vector(15 downto 0);
  

begin


 
x <= priv_k when sw2 = '0' else publ_k; 
y <= cleartext when sw1 = '0' else cryptotext;


  Display_inst : display
    port map (
      clk            => clk,
      seg            => seg,
      dp             => dp,
      an             => an,
      hex2led_int1   => z(3 downto 0),
      hex2led_int2   => z(7 downto 4),
      hex2led_int3   => z(11 downto 8),
      hex2led_int4   => z(15 downto 12)
    );

  -- Instantiate the modm_exponentiation entity
  ModExp_inst : modm_exponentiation
    generic map (
      k => 16, 
      log_k => 4 
    )
    port map (
      x => x,
      y => y,
      m => n,
      clk => clk,
      reset => btn,
      z => z,
      done => led
    );


end Behavioral;
