----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:23:16 04/09/2010 
-- Design Name: 
-- Module Name:    exten_signo - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
Use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity exten_signo_cero is
    Port ( e        : in  STD_LOGIC_VECTOR (15 downto 0);
	        cero_ext : in STD_LOGIC;
           s        : out  STD_LOGIC_VECTOR (31 downto 0));
end exten_signo_cero;

architecture Behavioral of exten_signo_cero is

begin
	s <= std_logic_vector(resize(unsigned (e), s'length)) when cero_ext = '1' else
	     std_logic_vector(resize(signed (e), s'length))   when cero_ext = '0' else
		  X"00000000";
--	s <= X"0000" & e when cero_ext = '1' else
--	     X"0000" & e when e(15) = '0' and cero_ext = '0' else
--	     X"FFFF" & e when e(15) = '1' and cero_ext = '0' else
--		  X"0000" & e;
end Behavioral;

