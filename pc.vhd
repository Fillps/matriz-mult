
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pc is
	port(
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		start : IN STD_LOGIC;
		
		done : OUT STD_LOGIC;
		idle : OUT STD_LOGIC;
		ready : OUT STD_LOGIC;
		
		addressA : OUT STD_LOGIC_VECTOR(3 downto 0);
		addressB : OUT STD_LOGIC_VECTOR(3 downto 0);
		addressR : OUT STD_LOGIC_VECTOR(3 downto 0);
		
		writeR : OUT STD_LOGIC;
		
		rstAdder : OUT STD_LOGIC;
		enableAdd : OUT STD_LOGIC
	);
end pc;

architecture Behavioral of pc is

type St is (IDLE_ST, RST_ST, START_ST, SAVE_ST, NEXT_VALUE_ST, DONE_ST, WAIT_SAVE_ST, WAIT_ADD_ST);
signal current_st : St;
signal next_st : St := RST_ST;
 
signal addressA_t, addressB_t, addressR_t : std_logic_vector(3 downto 0);
signal countA, countB : std_logic_vector(3 downto 0);
signal rowA, colB : std_logic_vector(1 downto 0);
signal done_s : std_logic;
begin

done <= done_s;
	process(start, clk, rst)
	begin
		if (rst = '1') then
			next_st <= RST_ST;
		elsif (rising_edge(clk)) then
			case next_st is 
				when IDLE_ST =>
					idle <= '1';
					ready <= '1';
					writeR <= '0';
					rstAdder <= '0';
					enableAdd <= '0';
					if start = '1' and done_s = '0' then
						idle <= '0';
						next_st <= START_ST;
					else 
						next_st <= IDLE_ST;
					end if;
				when RST_ST =>
					idle <= '0';
					ready <= '0';
					writeR <= '0';
					enableAdd <= '0';
					done_s <= '0';
					
					next_st <= IDLE_ST;
					
				when START_ST =>
					ready <= '0';
					addressA_t <= "0000";
					addressB_t <= "0000";
					addressR_t <= "0000";
					countA <= "0000";
					countB <= "0000";
					rowA <= "00";
					colB <= "00";
					rstAdder <= '1';
					enableAdd <= '0';
					next_st <= NEXT_VALUE_ST;
				when NEXT_VALUE_ST =>
					if ((countA = "0000" and countB = "0000")) then
						rstAdder <= '1';
					else
						rstAdder <= '0';
					end if;
					enableAdd <= '1';
					writeR <= '0';
					addressA <= addressA_t + countA;
					addressB <= addressB_t + countB;
					if countA = "0011" then
						countA <= "0000";
						countB <= "0000";
						next_st <= WAIT_ADD_ST;
					else
						countA <= countA + 1;
						countB <= countB + 4;
						
						next_st <= NEXT_VALUE_ST;
					end if;
				when WAIT_ADD_ST =>
					next_st <= SAVE_ST;
				when SAVE_ST =>
					enableAdd <= '0';
					writeR <= '1';
					if colB="11" then
						colB <= "00";
						rowA <= rowA + 1;
						addressA_t <= addressA_t + 4;
						addressB_t <= "0000";
					else
						colB <= colB + 1;
						addressB_t <= addressB_t + 1;
					end if;
					if rowA = "11" and colB = "11" then
						next_st <= DONE_ST;
					else 
						next_st <= WAIT_SAVE_ST;
					end if;
				when WAIT_SAVE_ST =>
					writeR <= '0';
					rstAdder <= '1';
					addressR_t <= addressR_t + 1;
					next_st <= NEXT_VALUE_ST;
				when DONE_ST =>
					done_s <= '1';
					next_st <= IDLE_ST;
			end case;
		end if;
	end process;
	
addressR <= addressR_t;

end Behavioral;

