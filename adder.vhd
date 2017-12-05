----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:57:47 12/05/2017 
-- Design Name: 
-- Module Name:    adder - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder is
	port(
		enableAdder, rst : IN std_logic;
		toAdd : IN std_logic_vector(15 downto 0);
		result : OUT std_logic_vector(15 downto 0)
		);
end adder;

architecture Behavioral of adder is
signal result_s : std_logic_vector(15 downto 0);
begin
	process(enableAdder, rst, toAdd)
	begin
		if (rst = '1') then
			result_s <= "0000000000000000";
		elsif (enableAdder = '1') then
			result_s <= result_s + toAdd;
		end if;
	end process;
	

	result <= result_s;
end Behavioral;

