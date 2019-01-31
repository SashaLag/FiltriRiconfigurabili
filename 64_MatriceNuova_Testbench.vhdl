library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is 
end testbench;

architecture testbench of testbench is

component memoria is 
	PORT (
	 	 w,r,clk: IN std_logic;
		   data1: INOUT std_logic_vector(7 downto 0);
		   data2: INOUT std_logic_vector(7 downto 0);
		addr1: IN std_logic_vector(15 downto 0);
		addr2: IN std_logic_vector(15 downto 0)
	);	
end component;

component jericho is
	PORT (
		clk, reset, start: IN std_logic;
		data1: INOUT std_logic_vector(7 downto 0);
		data2: INOUT std_logic_vector(7 downto 0);
		r,w : OUT std_logic;
		addr1: OUT std_logic_vector(15 downto 0);
		addr2: OUT std_logic_vector(15 downto 0)
	); 
end component;

signal test_start : std_logic := '0';
signal test_reset : std_logic := '0';
signal test_clk : std_logic := '0';
signal r_t, w_t : std_logic; 
signal data1_t : std_logic_vector(7 downto 0);
signal addr1_t : std_logic_vector(15 downto 0);
signal data2_t : std_logic_vector(7 downto 0);
signal addr2_t : std_logic_vector(15 downto 0);

for i1: jericho use entity work.jericho(battle);
for i2: memoria use entity work.memoria(mem32x8);


BEGIN

test_reset <= '1' after 19 ns, '0' after 31 ns;
test_clk <= not test_clk after 10 ns;
test_start <= '1' after 39 ns, '0' after 60 ns;



i1: jericho
	port map (clk => test_clk, reset => test_reset, start => test_start,
		  data1 => data1_t, r => r_t, w => w_t, addr1 => addr1_t,
		  data2 => data2_t, addr2 => addr2_t);
i2: memoria
	port map (w => w_t, r => r_t, clk => test_clk, data1 => data1_t, data2 => data2_t, addr1 => addr1_t, addr2 => addr2_t);

  
end testbench;