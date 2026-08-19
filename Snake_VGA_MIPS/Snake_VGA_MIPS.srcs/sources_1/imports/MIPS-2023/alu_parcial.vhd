----------------------------------------------------------------------------------
-- Company: UC
-- Engineer: Vicente González
-- 
-- Create Date:    	15:22:03 06/15/2017 
-- Design Name: 
-- Module Name:    	alu_parcial - Behavioral 
-- Project Name: 	MIPS - 2019
-- Target Devices: 	SPARTAN 3AN
-- Tool versions: 
-- Description: Parte de la ALU del MIPS. Es capaz de ejecutar las siguientes
--              operaciones: suma, resta, and, or, slt, sltu, nor y xor.
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_parcial is
    Port ( op1     : in  STD_LOGIC_VECTOR (31 downto 0);
           op2     : in  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (3 downto 0);
           s       : out  STD_LOGIC_VECTOR (31 downto 0));
end alu_parcial;

architecture Behavioral of alu_parcial is
	signal suma, sumando2 : STD_LOGIC_VECTOR (31 downto 0);
	signal cin : STD_LOGIC_VECTOR (0 downto 0);
	signal temp : STD_LOGIC_VECTOR (31 downto 0);
begin
	-- implementamos un único sumador para la suma y la resta.
	-- Para implementar la resta negamos uno de los operandos y le sumamos uno
	sumando2 <= not (op2) when control = "0001" else	-- si es resta ponemos op2 negado
	            op2;
	cin <= "1" when control = "0001" else	-- si es resta ponemos 1
	       "0";
	-- suma será op1 + op2 + 0
	-- resta será op1 + op2 negado + 1
	suma <= std_logic_vector(unsigned (op1) + unsigned (sumando2) + unsigned (cin));
	
	-- proceso que implementa los operaciones de la ALU
	process (op1, op2, suma, control, temp) is
	begin
		case control is
			when "0000" | "0001" => -- suma o resta
				temp <= suma;
--			when "0001" =>	-- resta
--				temp := suma;
			when "0010" => -- and
				temp <= op1 and op2;
			when "0011" => -- or
				temp <= op1 or op2;
			when "0100" => -- slt
				if signed (op1) < signed (op2) then 
					temp <= X"00000001";
				else 
					temp <= X"00000000";
				end if;
--				temp := op1 - op2;
--				temp := B"0000000000000000000000000000000" & temp (31);
			when "1101" => -- sltu
				if unsigned (op1) < unsigned (op2) then 
					temp <= X"00000001";
				else 
					temp <= X"00000000";
				end if;
			when "1110" => -- xor
				temp <= op1 xor op2;
			when "1111" => -- nor
				temp <= op1 nor op2;
			when others => 
				temp <= X"00000000";
		end case;

 		s <= temp; -- asignamos el valor calculado a la salida
		
	end process;
end Behavioral;
