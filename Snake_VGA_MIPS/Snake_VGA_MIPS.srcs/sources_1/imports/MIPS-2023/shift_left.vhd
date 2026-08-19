----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:26:14 04/09/2010 
-- Design Name: 
-- Module Name:    shift_left - Behavioral 
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

entity shift_left is
    Port ( e : in  STD_LOGIC_VECTOR (29 downto 0);
           s : out  STD_LOGIC_VECTOR (31 downto 0));
end shift_left;

architecture Behavioral of shift_left is

begin
	s <= e & B"00";

end Behavioral;

