----------------------------------------------------------------------------------
-- Company: Universidad Cat�lica
-- Engineer: Vicente Gonz�lez
-- 
-- Create Date:    14:28:41 06/14/2017 
-- Design Name: 
-- Module Name:    decodificador - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decodificador is
    Port (
        ent       : in  STD_LOGIC_VECTOR (31 downto 0);
        csMem     : out STD_LOGIC;
        csParPort : out STD_LOGIC;
        csEntrada : out STD_LOGIC;
        csVGA     : out STD_LOGIC  -- nuevo
    );
end decodificador;

architecture Behavioral of decodificador is

begin
	-- memoria
	csMem     <= '1' when ent(31 downto 16) = X"1001" else
	             '0';
	
	-- Puerto paralelo de salida
	csParPort <= '1' when ent = X"FFFF8000" else
	             '0';

	-- habilitador de lectura de las llaves
	csEntrada <= '1' when ent = X"FFFFD000" else
					 '0';
					 
    csVGA <= '1' when ent(31 downto 16) = X"FFFF" and ent(15 downto 0) >= X"C000" 
    and ent(15 downto 0) <= X"C006" else '0';

end Behavioral;

