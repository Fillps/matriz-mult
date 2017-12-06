----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:16:40 12/05/2017 
-- Design Name: 
-- Module Name:    interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity interface is
	Port ( 
		clk : in std_logic; --clk
		rst_or_bram_in_low : in std_logic; -- botao
		alt_view : in std_logic; -- chave -- alterna em visualizar a memoria ou o a mult -- 1 = memoria; 0 = mult
		sel_bram : in std_logic_vector(1 downto 0); -- sel bram -- 00 ou 11 -> resp ; 01 -> ent A ; 10 -> ent B
		writeB : in std_logic; -- chave
		ender_low : in std_logic; -- botao -- conta em HEXA no display 2, para navegar a mem
		start_or_bram_in_high : in std_logic; 
		
		selDisplay : out std_logic_vector (3 downto 0); -- seleciona o display
		display : out std_logic_vector (6 downto 0); -- display 7 seg
		done_led : out std_logic; -- led
		ready_led : out std_logic; -- led
		idle_led : out std_logic -- led
		
	);
end interface;

architecture Behavioral of interface is

COMPONENT mult_matriz4x4
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		start : IN std_logic;
		selBram : IN std_logic_vector(1 downto 0);
		altView : IN std_logic;
		writeB : IN std_logic_vector(0 to 0);
		dataIn : IN std_logic_vector(15 downto 0);
		addressIn : IN std_logic_vector(3 downto 0);          
		done : OUT std_logic;
		idle : OUT std_logic;
		ready : OUT std_logic;
		bram_out : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

signal rst, start : std_logic;

signal BRAM_b_output, dataIN : std_logic_vector (15 downto 0);
signal BRAM_b_data_in  : std_logic_vector (7 downto 0);
signal BRAM_b_low_input  : std_logic_vector (3 downto 0);
signal BRAM_b_high_input : std_logic_vector (3 downto 0);
signal BRAM_b_data_in_low, BRAM_b_data_in_high: std_logic_vector (3 downto 0);
signal b_in_low, b_in_high : std_logic;
signal b_write : std_logic_vector(0 downto 0) := "0";

signal clock200hz : std_logic;

function binTo7seg(value : in std_logic_vector (3 downto 0)) return std_logic_vector is
begin
	case value is
		 when "0000" => return "1000000";
		 when "0001" => return "1111001";
		 when "0010" => return "0100100";
		 when "0011" => return "0110000";
		 when "0100" => return "0011001";
		 when "0101" => return "0010010";
		 when "0110" => return "0000010";
		 when "0111" => return "1111000";
		 when "1000" => return "0000000";
		 when "1001" => return "0010000";
		 when "1010" => return "0001000";
		 when "1011" => return "0000011";
		 when "1100" => return "1000110";
		 when "1101" => return "0100001";
		 when "1110" => return "0000110";
		 when "1111" => return "0001110";
		 when others => return "0001110";
		end case;
end binTo7seg;

begin

dataIN <= "00000000"&BRAM_b_data_in;

matriz4x4: mult_matriz4x4 PORT MAP(
		clk => clock200hz,
		rst => rst,
		start => start,
		selBram => sel_bram,
		altView => alt_view,
		writeB => b_write,
		dataIn => dataIN,
		addressIn => BRAM_b_low_input,
		done => done_led,
		idle => idle_led,
		ready => ready_led,
		bram_out => BRAM_b_output
	);
	
divisor:process(clk)
		variable conta200:integer range 0 to 62500;
		begin
			if (rising_edge(clk)) then
				if (conta200 < 62500) then
					conta200:=conta200 +1;
				else
					conta200:=0;
					clock200hz<=not(clock200hz);
				end if;
			end if;
	end process divisor;
	
	
  
	process(clock200hz, alt_view)
	variable ctrl: bit_vector(1 downto 0);
	begin
		if (rising_edge(clock200hz)) then
			
			if (alt_view = '1' and (sel_bram = "10" or sel_bram = "01")) then -- visualizar A ou B
				if (ctrl="00") then
					selDisplay<="1110";
					display <= binTo7seg(BRAM_b_output(3 downto 0));
					ctrl:="01";
				elsif (ctrl="01") then 
					selDisplay<="1101";
					display <= binTo7seg(BRAM_b_output(7 downto 4));						
					ctrl:="10";
				elsif (ctrl="10") then 
					selDisplay<="1111";
					ctrl:="11";
				else
					selDisplay<="0111";
					display <= binTo7seg(BRAM_b_low_input);
					ctrl:="00";
				end if;
			else			--visualizar R
				if (ctrl="00") then
					selDisplay<="1110";
					display <= binTo7seg(BRAM_b_output(3 downto 0));
					ctrl:="01";
				elsif (ctrl="01") then 
					selDisplay<="1101";
					display <= binTo7seg(BRAM_b_output(7 downto 4));						
					ctrl:="10";
				elsif (ctrl="10") then 
					selDisplay<="1011";
					display <= binTo7seg(BRAM_b_output(11 downto 8));	
					ctrl:="11";
				else
					selDisplay<="0111";
					display <= binTo7seg(BRAM_b_output(15 downto 12));	
					ctrl:="00";
				end if;
			end if;
		end if;
	end process;
	
	process(ender_low)
	begin
		if (rising_edge(ender_low)) then
			BRAM_b_low_input <= BRAM_b_low_input + 1; 
		end if;
	end process;
	
	
	process(b_in_low, alt_view)
	begin
		if (rising_edge(b_in_low) and alt_view = '1') then
			BRAM_b_data_in_low <= BRAM_b_output(3 downto 0) + 1; 
		end if;
	end process;
	
	process(b_in_high, alt_view)
	begin
		if (rising_edge(b_in_high) and alt_view = '1') then
			BRAM_b_data_in_high <= BRAM_b_output(7 downto 4) + 1; 
		end if;
	end process;
	rst <= rst_or_bram_in_low when (alt_view = '0') else '0';
	start <= start_or_bram_in_high when (alt_view = '0') else '0';
	
	b_in_high <= start_or_bram_in_high when (writeB = '1' and alt_view = '1') else '0';
	b_in_low <= rst_or_bram_in_low when (writeB = '1' and alt_view = '1') else '0';
	
	BRAM_b_data_in <= BRAM_b_data_in_high & BRAM_b_data_in_low;

	b_write(0) <= writeB;
end Behavioral;

