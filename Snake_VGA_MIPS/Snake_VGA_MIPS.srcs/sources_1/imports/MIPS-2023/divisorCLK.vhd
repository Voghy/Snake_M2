----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:53:12 06/24/2019 
-- Design Name: MIPS
-- Module Name:    divisorCLK - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Divisor de frecuencia obtener 25 MHz apartir del clock de 50 MHz de la
-- placa Spartan-3AN Starter Kit. El dispositivo no puede correr a 50 Mhz.
-- 
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

entity divisorCLK is
    Port ( clk50mhz : in  STD_LOGIC;
           clk : out  STD_LOGIC);
end divisorCLK;

-- Divisor de Frecuencia para el MIPS.
-- La frecuencia de 50 MHz es dividida por 2.
architecture Behavioral of divisorCLK is
    signal tmp: std_logic := '0';
begin
	process (clk50mhz)
	begin
		if clk50mhz'event and clk50mhz = '1' then
			tmp <= not tmp;
		end if;
	end process;

   clk <= tmp;

end Behavioral;

