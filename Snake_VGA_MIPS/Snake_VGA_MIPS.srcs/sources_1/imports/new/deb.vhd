----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2025 21:24:32
-- Design Name: 
-- Module Name: deb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity deb is
    generic(tiempo : integer := 4);
    Port ( entrada : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           FL_s : out STD_LOGIC;
           FL_b : out STD_LOGIC);
end deb;

architecture Behavioral of deb is
    signal cont, cont_siguiente : integer := 0;
    type estado_type is (e0,e1,e2,e3,e4,e5,e6);
    signal estado, estado_siguiente : estado_type := e0;
begin
    --Circuito Combinacional de estado siguiente
    NEXT_STATE:process(entrada,estado,cont)
    begin
        case estado is
            when e0 =>
                if entrada = '1' then
                    estado_siguiente <= e1;
                else
                    estado_siguiente <= e0;
                end if;
            when e1 =>
                cont_siguiente <= 0;
                if entrada = '1' then
                    estado_siguiente <= e2;
                else
                    estado_siguiente <= e0;
                end if;
            when e2 =>
                cont_siguiente <= cont + 1;
                if cont = tiempo then
                    estado_siguiente <= e3;
                elsif entrada = '1' then
                    estado_siguiente <= e2;
                else
                    estado_siguiente <= e0;
                end if;
            when e3 =>
                estado_siguiente<=e4;
            when e4 =>
                cont_siguiente <= 0;
                estado_siguiente<= e5;
            when e5 =>
                cont_siguiente <= cont + 1;
                if cont = tiempo then
                    estado_siguiente <= e6;
                elsif entrada = '0' then
                    estado_siguiente <= e5;
                else
                    estado_siguiente <= e4;
                end if;
            when e6 =>
                    estado_siguiente<=e0;
        end case;
    end process;
    
    --Circuito Secuencial de actualización de estado
    UPDATE:process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                estado <= e0;
                cont   <= 0;
                
            else 
                estado<=estado_siguiente;
                cont  <=cont_siguiente;
            end if;
        end if;
    end process;
    
    --Circuito Combinacional de salida
    OUTPUT:process(estado)
    begin
        if estado = e3 then
            FL_s <= '1';
        else
            FL_s <= '0';
        end if;
        
        if estado = e6 then
            FL_b <= '1';
        else
            FL_b <= '0';
        end if;
    end process;
    
    --FL_s <= '1' when estado = e3 else '0';
    --FL_b <= '1' when estado = e6 else '0';

end Behavioral;
