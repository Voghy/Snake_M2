----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    16:34:44 04/05/2010 
-- Design Name: 
-- Module Name:    mi - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.general.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mi is
    Port ( dir   : in   STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
           s     : out  STD_LOGIC_VECTOR (31 downto 0);
		   -- interfaz con el programador
		   dirMI : in   STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
		   dataS : out  STD_LOGIC_VECTOR (31 downto 0);
		   dataE : in   STD_LOGIC_VECTOR (31 downto 0);
		   writeProg : in std_logic;
		   clk   : in std_logic
		 );
end mi;

architecture Behavioral of mi is
	-- función que carga el contenido de la ROM desde un archivo
   impure function ROM_INIC (archivo : in string) return mem_instrucciones is                                                   
        FILE f      : text is in archivo;                       
        variable l  : line;                                 
        variable r  : mem_instrucciones;
        variable good : boolean;
   begin                                                        
       for I in mem_instrucciones'range loop
			  if endfile (f) then 
				  r(I) := X"00000000";	-- si el archivo se acaba antes completamos con ceros
			  else 
			     readline (f, l);	-- leemos una línea
				  hread (l, r(I));	-- convertimos a std_logic_vector
			  end if;
		 end loop;
       return r;                                                  
   end function; 

	-- creamos e inicializamos la memoria de instrucciones a partir del archivo
	signal mi : mem_instrucciones := ROM_INIC(filename);

begin
	-- puerto de lectura normal del MIPS
	s <= mi(to_integer(unsigned(dir)));
	
	-- puerto de lectura para la verificación desde el programador
	dataS <= mi(to_integer(unsigned(dirMI)));
	
	-- puerto de escritura para la programación
	puertoEscritura : process (clk, writeProg)
	begin
		if clk'event and clk = '1' then
			if writeProg = '1' then
				mi(to_integer(unsigned(dirMI))) <= dataE;
			end if;
		end if;
	end process;
end Behavioral;

