----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:30:06 03/26/2010 
-- Design Name: 
-- Module Name:    mux32 - Behavioral 
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


entity mux32 is
    Port ( e0 : in  STD_LOGIC_VECTOR (31 downto 0);
           e1 : in  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (31 downto 0));
end mux32;

architecture Behavioral of mux32 is

begin
	s <= e0 when sel = '0' else
	     e1;

end Behavioral;

