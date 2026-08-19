----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:42:30 04/09/2010 
-- Design Name: 
-- Module Name:    alu_control - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_control is
    Port ( aluop : in  STD_LOGIC_VECTOR (2 downto 0);
           funct : in  STD_LOGIC_VECTOR (5 downto 0);
           s     : out STD_LOGIC_VECTOR (3 downto 0));
end alu_control;

architecture Behavioral of alu_control is

begin
	s <= "0000" when aluop = "000" else	-- SW, LW y ADDI
		  "0001" when aluop = "001" else	-- BNE y BEQ
		  "0011" when aluop = "011" else	-- ORI
		  "0010" when aluop = "100" else -- ANDI
		  "0100" when aluop = "101" else -- SLTI
		  "1110" when aluop = "110" else -- XORI
		  "1101" when aluop = "111" else -- SLTUI		  
		  "0000" when aluop = "010" and (funct = "100000" or funct = "100001") else	-- ADD y ADDU
		  "0001" when aluop = "010" and (funct = "100010" or funct = "100011") else	-- SUB y SUBU
		  "0010" when aluop = "010" and funct = "100100" else	-- AND
		  "0011" when aluop = "010" and funct = "100101" else	-- OR
		  "0100" when aluop = "010" and funct = "101010" else	-- SLT
		  "1101" when aluop = "010" and funct = "101011" else -- SLTU
		  "0101" when aluop = "010" and funct = "000000" else	-- SLL
		  "0110" when aluop = "010" and funct = "000010" else	-- SRL
		  "1000" when aluop = "010" and funct = "000110" else -- SRLV
		  "1001" when aluop = "010" and funct = "000100" else -- SLLV
		  "1010" when aluop = "010" and funct = "000011" else -- SRA
		  "1011" when aluop = "010" and funct = "000111" else -- SRAV
		  "1110" when aluop = "010" and funct = "100110" else -- XOR
		  "1111" when aluop = "010" and funct = "100111" else -- NOR
		  "0111"; -- esta situación no debe darse nunca
end Behavioral;

