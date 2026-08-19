----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    17:21:40 04/08/2010 
-- Design Name: 
-- Module Name:    sumador32 - Behavioral 
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

entity sumador32 is
    Port ( e1 : in  STD_LOGIC_VECTOR (31 downto 0);
           e2 : in  STD_LOGIC_VECTOR (31 downto 0);
           s : out  STD_LOGIC_VECTOR (31 downto 0));
end sumador32;

architecture Behavioral of sumador32 is

begin
	s <= e1 + e2;

end Behavioral;

