----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    12:05:38 04/14/2014 
-- Design Name: 
-- Module Name:    shift_left_j - Behavioral 
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

entity shift_left_j is
    Port ( ent : in  STD_LOGIC_VECTOR (25 downto 0);
           sal : out  STD_LOGIC_VECTOR (27 downto 0));
end shift_left_j;

architecture Behavioral of shift_left_j is

begin
	sal <= ent & "00";

end Behavioral;

