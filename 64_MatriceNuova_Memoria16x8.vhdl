library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria is
	port (
		w, r, clk: in std_logic;
		addr1, addr2: in std_logic_vector(15 downto 0);
		data1, data2: inout std_logic_vector(7 downto 0)
	);
end memoria;

architecture mem32x8 of memoria is

type tipo_banco_registri8 is array (0 to 31) of std_logic_vector(7 downto 0);
signal banco_registri8: tipo_banco_registri8 := (
	"00000001", "00000100", "10000000", "11111000",
	"00000000", "00000000", "00000000", "00000000",		-- primi 4: matrice di partenza
	"00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000",		-- ultimi 4: matrice destinazione
	"00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000",	
	"00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000"	
	);

begin
	process (r, w, clk)
	begin
		if r = '1' then
			if rising_edge(clk) then
				data1 <= banco_registri8(to_integer(unsigned(addr1)));
				data2 <= banco_registri8(to_integer(unsigned(addr2)));
			end if;

		elsif w = '1' then
			data1 <= "ZZZZZZZZ";
			data2 <= "ZZZZZZZZ";
			if rising_edge(clk) then
				banco_registri8(to_integer(unsigned(addr1))) <= data1;
				banco_registri8(to_integer(unsigned(addr2))) <= data2;
			end if;
		end if;
	end process;
end mem32x8;

