----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    16:14:58 05/11/2010 
-- Design Name: 
-- Module Name:    shift_left16 - Behavioral 
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

entity shift_left16 is
    Port ( ent : in  STD_LOGIC_VECTOR (15 downto 0);
           sal : out STD_LOGIC_VECTOR (31 downto 0));
end shift_left16;

architecture Behavioral of shift_left16 is

begin
	sal <= ent & X"0000";

end Behavioral;

