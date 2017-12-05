----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:14:02 12/05/2017 
-- Design Name: 
-- Module Name:    mult_matriz4x4 - Behavioral 
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

entity mult_matriz4x4 is
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		start : IN std_logic;          
		done : OUT std_logic;
		idle : OUT std_logic;
		ready : OUT std_logic;
		resp : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
end mult_matriz4x4;

architecture Behavioral of mult_matriz4x4 is
	
	COMPONENT pc
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		start : IN std_logic;          
		done : OUT std_logic;
		idle : OUT std_logic;
		ready : OUT std_logic;
		addressA : OUT std_logic_vector(3 downto 0);
		addressB : OUT std_logic_vector(3 downto 0);
		addressR : OUT std_logic_vector(3 downto 0);
		writeR : OUT std_logic;
		rstAdder : OUT std_logic;
		enableAdd : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT mem_entrada
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	 );
	END COMPONENT;
	
	COMPONENT mem_resposta
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
  END COMPONENT;
  
	COMPONENT adder
	PORT(
		enableAdder : IN std_logic;
		rst : IN std_logic;
		toAdd : IN std_logic_vector(15 downto 0);          
		result : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;


signal enableAdd, rstAdder : std_logic;
signal writeR : std_logic_vector (0 downto 0);
signal addressA, addressB, addressR : std_logic_vector(3 downto 0);
signal valA, valB : std_logic_vector(7 downto 0);
signal valR, valMult, respR : std_logic_vector(15 downto 0);

begin

	Inst_pc: pc PORT MAP(
		clk,
		rst,
		start,
		done,
		idle,
		ready,
		addressA,
		addressB,
		addressR,
		writeR(0),
		rstAdder,
		enableAdd 
	);
	
	memA : mem_entrada
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => addressA,
    dina => "00000000",
    douta => valA
  );
  
  memB : mem_entrada
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => addressB,
    dina => "00000000",
    douta => valB
  );
  
  memR : mem_resposta
  PORT MAP (
    clka => clk,
    wea => writeR,
    addra => addressR,
    dina => valR,
    douta => respR
  );
  
 valMult <= valA * valB;
	
	Inst_adder: adder PORT MAP(
		enableAdder => enableAdd,
		rst => rstAdder,
		toAdd => valMult,
		result => valR
	);
	
resp <= valR;

end Behavioral;

