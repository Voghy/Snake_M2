----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    16:29:52 04/05/2010 
-- Design Name: 
-- Module Name:    suma_4 - Behavioral 
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

entity suma_4 is
    Port ( e : in  STD_LOGIC_VECTOR (31 downto 0);
           s : out  STD_LOGIC_VECTOR (31 downto 0));
end suma_4;

architecture Behavioral of suma_4 is

begin
	s <= e + X"00000004";

end Behavioral;

