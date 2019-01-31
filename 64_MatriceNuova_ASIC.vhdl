library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity jericho is
	port(
		clk, start, reset : IN std_logic;
		addr1, addr2 : out std_logic_vector(15 downto 0);
		data1, data2 : inout std_logic_vector (7 downto 0);
		r, w : out std_logic
	);
end jericho;


architecture battle of jericho is

signal state, next_state : integer;
signal i1, i2, o1, o2 : std_logic_vector(15 downto 0);
signal temp1, temp2 : std_logic_vector(7 downto 0);
constant RC : integer := 16;					-- 16384;

begin
	assNextState: process (clk, reset)
	begin
		if reset = '1' then
			state <= 0;
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;

	assRegistri: process (clk, reset)
	begin
		if reset = '1' then
			data1 <= "ZZZZZZZZ";	
			data2 <= "ZZZZZZZZ";
			w <= '0';
			r <= '0';

		elsif rising_edge(clk) then
			case state is
				when 0 =>
					null;
				when 1 =>
					i1 <= std_logic_vector(to_unsigned(0,16));
					i2 <= std_logic_vector(to_unsigned(1,16));
					o1 <= std_logic_vector(to_unsigned(rc,16));
					o2 <= std_logic_vector(to_unsigned(1,16) + to_unsigned(rc, 16));

				when 2 =>
					r <= '1';
					addr1 <= i1;
					addr2 <= i2;

				when 3 =>
					i1 <= std_logic_vector(unsigned(i1) + to_unsigned(2,16));

				when 4 =>
					temp1 <= data1;
					temp2 <= data2;

				when 5 =>
					i2 <= std_logic_vector(unsigned(i2) + to_unsigned(2,16));
					r <= '0';

					if temp1 > std_logic_vector(to_unsigned(200, 8)) then
						temp1 <= std_logic_vector(to_unsigned(200, 8));

					elsif temp1 < std_logic_vector(to_unsigned(100, 8)) then
						temp1 <= std_logic_vector(to_unsigned(100, 8));
					end if;


					if temp2 > std_logic_vector(to_unsigned(200, 8)) then
						temp2 <= std_logic_vector(to_unsigned(200, 8));

					elsif temp2 < std_logic_vector(to_unsigned(100, 8)) then
						temp2 <= std_logic_vector(to_unsigned(100, 8));
					end if;

				when 6 =>
					addr1 <= o1;
					addr2 <= o2;

				when 7 => 
					w <= '1';
					data1 <= temp1;
					data2 <= temp2;
					o2 <= std_logic_vector(unsigned(o2) + to_unsigned(2,16));

				when 8 =>
					w <= '0';
					data1 <= "ZZZZZZZZ";
					data2 <= "ZZZZZZZZ";
					o1 <= std_logic_vector(unsigned(o1) + to_unsigned(2,16));

				when others =>
					null;
			end case;
		end if;
	end process;


	assStati: process (all)
	begin
		case state is
			when 0 =>
				if start = '1' then
					next_state <= 1;
				else
					next_state <= 0;
				end if;

			when 1 =>
				next_state <= 2;

			when 2 =>
				next_state <= 3;

			when 3 =>
				next_state <= 4;

			when 4 =>
				next_state <= 5;

			when 5 =>
				next_state <= 6;

			when 6 =>
				next_state <= 7;

			when 7 =>
				next_state <= 8;

			when 8 =>
				if i1 < std_logic_vector(to_unsigned(rc, 16)) then
					next_state <= 2;
				else
					next_state <= 0;
				end if;

			when others =>
				next_state <= 0;

		end case;
	end process;
end battle;


















