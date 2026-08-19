----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    08:55:47 04/12/2014 
-- Design Name: 
-- Module Name:    JR_detect - Behavioral 
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

entity JR_detect is
    Port ( funct : in  STD_LOGIC_VECTOR (5 downto 0);
           jr : out  STD_LOGIC);
end JR_detect;

architecture Behavioral of JR_detect is
	constant JR_FUNCT  : STD_LOGIC_VECTOR(5 downto 0) := "001000";
begin
	jr <= '1' when funct = JR_FUNCT else
	      '0';

end Behavioral;

