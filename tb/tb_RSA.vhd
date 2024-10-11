library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_RSA is
end tb_RSA;

architecture sim of tb_RSA is
  signal clk : std_logic := '0';
  signal sw1 : std_logic := '0';
  signal sw2 : std_logic := '0';
  signal btn : std_logic := '0';
  signal led : std_logic;
  signal seg : std_logic_vector(6 downto 0);
  signal dp  : std_logic;
  signal an  : std_logic_vector(3 downto 0);

  component RSA
    Port (
      clk : in std_logic;
      sw1 : in std_logic;
      sw2 : in std_logic;
      btn : in std_logic;
      led : out std_logic;
      seg : out std_logic_vector(6 downto 0);
      dp  : out std_logic;
      an  : out std_logic_vector(3 downto 0)
    );
  end component;
  
  begin 



clk <= not clk after 5ns;

  -- Stimulus process
  process
  begin
  
    wait for 10 ns;  -- Initial wait
    sw1 <= '1';
    sw2 <= '0';
    btn <= '0';


-- deasserting reset 
    wait for 20 ns;  -- Add more test scenarios as needed
    btn <= '1';
    
    wait until led = '1'; 
    
--    wait for 200 ns; 
--    btn <= '0';

--    wait for 20 ns;  -- Add more test scenarios as needed
--    sw1 <= '1';
--    sw2 <= '0';
--    btn <= '1';

--    wait for 200 ns; 
--    btn <= '0';
    
--    wait for 200 ns;  -- Add more test scenarios as needed
--    sw1 <= '0';
--    sw2 <= '1';
--    btn <= '1';

--    wait for 200 ns; 
--    btn <= '0';
    
--    wait for 200 ns;  -- Add more test scenarios as needed
--    sw1 <= '0';
--    sw2 <= '0';
--    btn <= '1';


    wait;
  end process;


    uut: RSA port map (
      clk => clk,
      sw1 => sw1,
      sw2 => sw2,
      btn => btn,
      led => led,
      seg => seg,
      dp  => dp,
      an  => an
    );
    
    
  end architecture;
