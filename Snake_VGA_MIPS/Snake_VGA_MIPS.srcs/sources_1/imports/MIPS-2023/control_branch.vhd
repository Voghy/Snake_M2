----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    16:11:50 05/11/2010 
-- Design Name: 
-- Module Name:    control_branch - Behavioral 
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

entity control_branch is
    Port ( branch : in  STD_LOGIC;
           bne : in  STD_LOGIC;
           zero : in  STD_LOGIC;
           sal : out  STD_LOGIC);
end control_branch;

architecture Behavioral of control_branch is

begin
	sal <= '1' when branch = '1' and ((bne = '1' and zero = '0') or (bne = '0' and zero = '1')) else
			 '0';
end Behavioral;

