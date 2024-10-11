--------------------------------------------------------------------------------
-- Company: 		 Xilinx
-- Engineer:       Steven Elzinga
--
-- Create Date:    15:53:35 02/01/05
-- Design Name:    Stopwatch
-- Module Name:    led_control - led_control_arch
-- Project Name:   ISE In Depth Tutorial
-- Target Device:  xc3s200-4ft256
-- Tool versions:  ISE 7.1i
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_control is
    Port ( CLK : in std_logic;
           DISP0 : in std_logic_vector(6 downto 0);
           DISP1 : in std_logic_vector(6 downto 0);
           DISP2 : in std_logic_vector(6 downto 0);
           DISP3 : in std_logic_vector(6 downto 0);
           AN : out std_logic_vector(3 downto 0);
           DP : out std_logic;
           SEVEN_SEG : out std_logic_vector(6 downto 0));
end led_control;

architecture led_control_arch of led_control is

  signal d0 : std_logic_vector (6 downto 0);
  signal cnt : std_logic_vector (15 downto 0);
  signal sel : std_logic_vector (1 downto 0);

begin

  sel <= cnt (15 downto 14);

  process (sel,  DISP0, DISP1, DISP2, DISP3)
  begin
    case (sel) is
	   when "00" => 
		  AN <= "0111";
		  d0 <= DISP3;
		  dp <= '0';
      when "01" =>
		  AN <= "1011";
		  d0 <= DISP2;
		  dp <= '0';
      when "10" =>
		  AN <= "1101";
		  d0 <= DISP1;
		  dp <= '1';
      when others =>
		  AN <= "1110";
		  d0 <= DISP0;
		  dp <= '1';
    end case;
  end process;

  process (CLK)
  begin
    if CLK'event and CLK = '1' then
	   cnt <= std_logic_vector(unsigned(cnt) + 1);
    end if;
  end process;

SEVEN_SEG <= d0;

end led_control_arch;
