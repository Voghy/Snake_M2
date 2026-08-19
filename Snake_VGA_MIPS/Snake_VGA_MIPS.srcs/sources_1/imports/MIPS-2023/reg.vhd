----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:00:15 04/08/2010 
-- Design Name: 
-- Module Name:    reg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implementa los 32 registros del MIPS. 
-- En realidad se implementa utilizando 31 posiciones de memoria de 32 bits cada una y
-- la dirección 0 es una constante que retorna el valor cero y lo que se escribe no se guarda.
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg is
    Port ( rr1      : in  STD_LOGIC_VECTOR (4 downto 0);
           rr2      : in  STD_LOGIC_VECTOR (4 downto 0);
           wr       : in  STD_LOGIC_VECTOR (4 downto 0);
           wd       : in  STD_LOGIC_VECTOR (31 downto 0);
           clk      : in  STD_LOGIC;
           regwrite : in  STD_LOGIC;
           rd1      : out STD_LOGIC_VECTOR (31 downto 0);
           rd2      : out STD_LOGIC_VECTOR (31 downto 0)
		 );
end reg;

architecture Behavioral of reg is
	type mem is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
	signal reg : mem := (others => X"00000000");
begin
	-- implementación de la lectura de los registros
	rd1 <= X"00000000" when rr1 = "00000" else
	       reg(to_integer(unsigned(rr1)));
	rd2 <= X"00000000" when rr2 = "00000" else
	       reg(to_integer(unsigned(rr2)));
	
	-- proceso para la escritura de los registros
	process (clk) is
	begin
		if clk'event and clk = '1' then
			if regwrite = '1' and wr /= "00000" then
				reg(to_integer(unsigned(wr))) <= wd;
			end if;
		end if;

	end process;
end Behavioral;

