----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:25:15 06/14/2017 
-- Design Name: MIPS
-- Module Name:    md - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Memoria de datos del MIPS, implementa la lectura de un byte, una media palabra (16 bits)
-- y una palabra (32 bits). Las dos primeras con o sin signo.
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
use work.general.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity md is
    Port ( dir      : in  STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_DATOS -1 +2 downto 0);
           datain   : in  STD_LOGIC_VECTOR (31 downto 0);
           cs       : in  STD_LOGIC;
           memwrite : in  STD_LOGIC;
           memread  : in  STD_LOGIC;
           clk      : in  STD_LOGIC;
		     -- 000 una palabra, 
		     -- 001 16 bits sin signo, 010 8 bits sin signo, 
		     -- 011 16 bits con signo y 100 8 bits con signo.
		     tipoAcc  : in STD_LOGIC_VECTOR (2 downto 0);
           dataout  : out  STD_LOGIC_VECTOR (31 downto 0));
end md;

architecture Behavioral of md is
	type mem_byte is array (0 to 2**NUM_BITS_MEMORIA_DATOS -1) of STD_LOGIC_VECTOR(7 downto 0);
	signal mem00 : mem_byte;	-- bytes menos significativos
	signal mem01 : mem_byte;
	signal mem10 : mem_byte;
	signal mem11 : mem_byte;	-- bytes mas significativos
	-- señales intermedias para medias palabras
	signal hwtemp1 : STD_LOGIC_VECTOR (15 downto 0);
	signal hwtemp2 : STD_LOGIC_VECTOR (15 downto 0);
begin
	-- creamos las medias palabras (16 bits)
	hwtemp1 <= mem01(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & mem00(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
	hwtemp2 <= mem11(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & mem10(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
	
	leer : process (dir, memread, cs, mem00, mem01, mem10, mem11, tipoAcc, hwtemp1, hwtemp2) is
	begin
		if cs = '1' and memread = '1' then
			case tipoAcc is
				when "000" => -- lectura de una palabra
					dataout <= mem11(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & 
					           mem10(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & 
							     mem01(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & 
							     mem00(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
				when "001" => -- lectura de media palabra sin signo
					case dir(1 downto 0) is
						when "00" =>
							dataout <= X"0000" & mem01(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & 
							                     mem00(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
						when "10" =>
							dataout <= X"0000" & mem11(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) & 
							                     mem10(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
						when others =>
							dataout <= X"00000000";
					end case;
				when "010" => -- lectura de un byte
					case dir(1 downto 0) is
						when "00" =>
							dataout <= X"000000" & mem00(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
						when "01" =>
							dataout <= X"000000" & mem01(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
						when "10" =>
							dataout <= X"000000" & mem10(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
						when "11" =>
							dataout <= X"000000" & mem11(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))));
						when others =>
							dataout <= X"00000000";
					end case;
				when "011" => -- lectura de media palabra con signo
					case dir(1 downto 0) is
						when "00" =>
							dataout <= std_logic_vector(resize(signed(hwtemp1), dataout'length));
						when "10" =>
							dataout <= std_logic_vector(resize(signed(hwtemp2), dataout'length));
						when others =>
							dataout <= X"00000000";
					end case;
				when "100" => -- lectura de un byte con signo
					case dir(1 downto 0) is
						when "00" =>
							dataout <= std_logic_vector(resize(signed(mem00(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))))), dataout'length));
						when "01" =>
							dataout <= std_logic_vector(resize(signed(mem01(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))))), dataout'length));
						when "10" =>
							dataout <= std_logic_vector(resize(signed(mem10(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))))), dataout'length));
						when "11" =>
							dataout <= std_logic_vector(resize(signed(mem11(to_integer(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2))))), dataout'length));
						when others =>
							dataout <= X"00000000";
					end case;
				when others => -- no debe ocurrir
					dataout <= X"00000000";
			end case;
			
		else
			dataout <= X"00000000";
		end if;
	end process leer;

	escribir : process (clk) is
	begin
		if clk'event and clk = '1' then 
			if cs = '1' and memwrite = '1' then
				case tipoAcc is
					when "000" => -- una palabra
						mem00(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(7  downto  0);
						mem01(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(15 downto  8);
						mem10(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(23 downto 16);
						mem11(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(31 downto 24);
					when "001" | "011" => -- media palabra
						case dir(1 downto 0) is
							when "00" =>
								mem00(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain( 7 downto 0);
								mem01(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(15 downto 8);
							when "10" =>
								mem10(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain( 7 downto 0);
								mem11(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(15 downto 8);
							when others =>
						end case;
					when "010" | "100" => -- un byte
						case dir(1 downto 0) is
							when "00" =>
								mem00(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(7 downto 0);
							when "01" =>
								mem01(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(7 downto 0);
							when "10" =>
								mem10(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(7 downto 0);
							when "11" =>
								mem11(TO_INTEGER(unsigned(dir(NUM_BITS_MEMORIA_DATOS -1 +2 downto 2)))) <= datain(7 downto 0);
							when others =>
						end case;
					when others =>
				end case;
			end if;
		end if;
	end process escribir;
end Behavioral;

