----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:17:31 05/12/2010 
-- Design Name: 
-- Module Name:    antirebote - Behavioral 
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

entity antirebote is
    Port ( boton1 : in  STD_LOGIC;
           boton2 : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : out  STD_LOGIC  := '0');
end antirebote;

architecture Behavioral of antirebote is

begin
	process (clk)
	begin
		if clk'event and clk = '1' then
			if boton1 = '1' then
				reset <= '1';
			elsif boton2 = '1' then
				reset <= '0';
			end if;
		end if;
	end process;
end Behavioral;

