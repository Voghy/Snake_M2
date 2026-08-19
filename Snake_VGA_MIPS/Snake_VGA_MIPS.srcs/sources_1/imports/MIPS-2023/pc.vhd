----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    15:54:20 04/05/2010 
-- Design Name: 
-- Module Name:    pc - Behavioral 
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

entity pc is
    Port ( e : in  STD_LOGIC_VECTOR (31 downto 0);
           s : out  STD_LOGIC_VECTOR (31 downto 0);
		   reset : in STD_LOGIC;
           clk : in  STD_LOGIC);
end pc;

architecture Behavioral of pc is

begin
	process (clk) is
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				s <= X"00400000";
			else
				s <= e;
			end if;
		end if;
	end process;
end Behavioral;

