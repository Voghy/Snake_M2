----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    15:24:01 06/15/2017 
-- Design Name: 
-- Module Name:    barrel_shifter - Behavioral 
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barrel_shifter is
    Port ( e          : in  STD_LOGIC_VECTOR (31 downto 0);		-- entrada
           control    : in  STD_LOGIC_VECTOR (4 downto 0);		-- control, cantidad de bits a correr
           op         : in  STD_LOGIC_VECTOR (1 downto 0);		-- corrimiento a la derecha, a la izquierda o derecha aritmético
           s          : out STD_LOGIC_VECTOR (31 downto 0));	-- salida
end barrel_shifter;

architecture RTL of barrel_shifter is

begin
	-- corrimiento lógico o aritmético
	s <= to_stdlogicvector(to_bitvector(e) sll CONV_INTEGER(control)) when op = "00" else -- corrimiento lógico a la izquierda
	     to_stdlogicvector(to_bitvector(e) srl CONV_INTEGER(control)) when op = "01" else -- corrimiento lógico a la derecha
		  to_stdlogicvector(to_bitvector(e) sra CONV_INTEGER(control)) when op = "10" else -- corrimiento aritmético a la derecha
		  X"00000000";
	-- corrimiento aritmético
--	     to_stdlogicvector(to_bitvector(e) sra CONV_INTEGER(control)) when left_right = '1';	-- FUNCIONA
end RTL;


