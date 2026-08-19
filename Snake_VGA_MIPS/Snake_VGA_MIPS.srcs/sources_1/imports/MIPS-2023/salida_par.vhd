----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:35:08 06/14/2017 
-- Design Name: 
-- Module Name:    salida_par - Behavioral 
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

entity salida_par is
    Port ( sel         : in  STD_LOGIC;
           write_cntl  : in  STD_LOGIC;
           clk         : in  STD_LOGIC;
           reset       : in  STD_LOGIC;
           data        : in  STD_LOGIC_VECTOR (3 downto 0);     -- dato que viene del MIPS
           salida      : out STD_LOGIC_VECTOR (3 downto 0));   -- pines externos
end salida_par;

architecture Behavioral of salida_par is

begin
	process (clk)
	begin
        if clk'event and clk = '1' then
            if reset = '1' then
                salida <= "0000";
            elsif sel = '1' and write_cntl = '1' then
                salida <= data;
            end if;
        end if;
    end process;
end Behavioral;

