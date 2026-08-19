----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    16:59:32 04/08/2010 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
--use IEEE.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( -- entradas
	        op1     : in  STD_LOGIC_VECTOR (31 downto 0);
           op2     : in  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (3 downto 0);
		     shiftamt: in  STD_LOGIC_VECTOR (4 downto 0);
			  -- salidas
           s       : out STD_LOGIC_VECTOR (31 downto 0);
           zero    : out STD_LOGIC);
end alu;

architecture Behavioral of alu is
	COMPONENT alu_parcial
	Port (  op1     : in  STD_LOGIC_VECTOR (31 downto 0);
           op2     : in  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (3 downto 0);
           s       : out STD_LOGIC_VECTOR (31 downto 0));
	END COMPONENT;

	COMPONENT barrel_shifter
	Port (  e          : in  STD_LOGIC_VECTOR (31 downto 0);
           control    : in  STD_LOGIC_VECTOR (4 downto 0);
           op         : in  STD_LOGIC_VECTOR (1 downto 0);
           s          : out STD_LOGIC_VECTOR (31 downto 0));
	END COMPONENT;
	
	signal s_alu_parcial : std_logic_vector(31 downto 0);
	signal s_barrel      : std_logic_vector(31 downto 0);
	signal s_mux         : std_logic_vector(31 downto 0);
	signal op_bshift     : std_logic_vector(1 downto 0);
	signal shift_amount  : std_logic_vector(4 downto 0);
	
begin
	Inst_alu_parcial: alu_parcial PORT MAP(
		op1     => op1,
		op2     => op2,
		control => control,
		s       => s_alu_parcial
	);

	Inst_barrel_shifter: barrel_shifter PORT MAP(
		e       => op2,
		control => shift_amount,
		op      => op_bshift,	-- Qué tipo de shift se hace
		s       => s_barrel
	);

	-- decodificador de corrimiento derecha/izquierda
	op_bshift <= "00" when control = "0101" or control = "1001" else --sll y sllv
	             "01" when control = "0110" or control = "1000" else --srl y srlv
					 "10" when control = "1010" or control = "1011" else --sra y srav
					 "11";
	
	-- multiplexor de salida
	s_mux <= s_barrel when control = "0101" or control = "0110" or control = "1000" or 
	                       control = "1001" or control = "1010" or control = "1011" else 
	         s_alu_parcial;
	
	-- detector de cero
	zero <= '1' when s_mux = X"00000000" else 
	        '0';

	-- conectamos shift_amount a shift_amount de la instrucción para las operaciones de corrimiento constante
	-- o a los 5 bits menos significativos de RS si la instrucción es de corrimiento por registro
	shift_amount <= shiftamt        when control = "0101" or  control = "0110" or control = "1010" else
	                op1(4 downto 0) when control = "1000" or  control = "1001" or control = "1011" else
						 "00000";
	
	-- conectamos la salida
	s <= s_mux;
	
end Behavioral;

