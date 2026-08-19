----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:28:32 04/11/2014 
-- Design Name: 
-- Module Name:    mux_3a1 - Behavioral 
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

entity mux5_4a1 is
    Port ( e0 : in  STD_LOGIC_VECTOR (4 downto 0);
           e1 : in  STD_LOGIC_VECTOR (4 downto 0);
           e2 : in  STD_LOGIC_VECTOR (4 downto 0);
           e3 : in  STD_LOGIC_VECTOR (4 downto 0);
           control : in  STD_LOGIC_VECTOR (1 downto 0);
           s : out  STD_LOGIC_VECTOR (4 downto 0));
end mux5_4a1;

architecture Behavioral of mux5_4a1 is

begin

	s <= e0 when control = "00" else
	     e1 when control = "01" else
		  e2 when control = "10" else
		  e3;

--	process (e0, e1, e2, e3) is
--	begin
--		case control is
--			when "00"   => s <= e0;
--			when "01"   => s <= e1;
--			when "10"   => s <= e2;
--			when "11"   => s <= e3;
--			when others => s <= e0;
--		end case;	
--	end process;

end Behavioral;

