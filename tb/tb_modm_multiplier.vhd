----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2023 10:28:07
-- Design Name: 
-- Module Name: tb_modm_multiplier - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_modm_multiplier is
--  Port ( );
end tb_modm_multiplier;

architecture Behavioral of tb_modm_multiplier is

  constant k : integer :=8;
  constant m : std_logic_vector := std_logic_vector ( to_unsigned(239, k));
  constant log_k : integer:= 3;
  
  
  component modm_multiplier
    generic(
      k: integer ;
      log_k: integer

    );
    port(
        x, y, m: in std_logic_vector(k-1 downto 0);
        clk, reset: in std_logic;
        z: out std_logic_vector(k-1 downto 0);
        done: out std_logic
    );
  end component;
  
  signal x, y: std_logic_vector(k-1 downto 0) := (others => '0');
  signal z: std_logic_vector(k-1 downto 0) := (others => '0');
  signal clk, reset, done : std_logic;
  constant clk_period : time := 10 ns;
  
 
begin
    dut1: modm_multiplier
        generic map (
          k => k,
          log_k => log_k
        )
        port map (
          x => x,
          y => y,
          m => m,
          z => z,
          clk => clk,
          reset => reset,
          done => done
        );
 
 clk_process :process
   begin
		clk <= '0';
		wait for clk_period;
		clk <= '1';
		wait for clk_period;
   end process;
         
 stim_proc: process
  begin	
    reset <= '1';
    wait for 20ns;
    reset <= '0';
    x <= std_logic_vector(to_unsigned(235, k));
    y <= std_logic_vector(to_unsigned(10, k));		
    wait for 1000 ns;	

    wait;
  end process;
  
end Behavioral;
