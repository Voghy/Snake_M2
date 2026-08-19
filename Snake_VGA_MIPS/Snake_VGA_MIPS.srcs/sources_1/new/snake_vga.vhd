-- snake_vga_display.vhd: muestra la cabeza, la fruta y una cola dinámica

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.types_pkg.all;

entity snake_vga_display is
    generic (
        CD       : integer := 16;
        MAX_COLA : integer := 64
    );
    port (
        clk      : in  std_logic;
        x, y     : in  std_logic_vector(10 downto 0);
        head_x   : in  std_logic_vector(5 downto 0);
        head_y   : in  std_logic_vector(5 downto 0);
        fruit_x  : in  std_logic_vector(5 downto 0);
        fruit_y  : in  std_logic_vector(5 downto 0);
        colaX    : in  cola_array;
        colaY    : in  cola_array;
        cola_len : in  integer range 0 to MAX_COLA;
        rgb_out  : out std_logic_vector(CD-1 downto 0)
    );
end snake_vga_display;

architecture Behavioral of snake_vga_display is
    signal x_u, y_u : unsigned(10 downto 0);
    signal head_x_u, head_y_u : unsigned(9 downto 0);
    signal fruit_x_u, fruit_y_u : unsigned(9 downto 0);
    signal match_cola : std_logic := '0';
begin
    x_u <= unsigned(x);
    y_u <= unsigned(y);
    head_x_u <= resize(unsigned(head_x), 10);
    head_y_u <= resize(unsigned(head_y), 10);
    fruit_x_u <= resize(unsigned(fruit_x), 10);
    fruit_y_u <= resize(unsigned(fruit_y), 10);
    
    process(x_u, y_u, colaX, colaY, cola_len, head_x_u, head_y_u, fruit_x_u, fruit_y_u)
        variable seg_x, seg_y : unsigned(10 downto 0);
        variable match : std_logic := '0';
    begin
        match := '0';
    
        for i in 0 to MAX_COLA - 1 loop
            if i < cola_len then
                seg_x := resize(unsigned(colaX(i)) * 10, 11);
                seg_y := resize(unsigned(colaY(i)) * 10, 11);           
    
                if x_u >= seg_x and x_u < seg_x + 10 and
                   y_u >= seg_y and y_u < seg_y + 10 then
                    match := '1';
                end if;
            end if;
        end loop;
    
        if x_u < 10 or x_u >= 630 or y_u < 10 or y_u >= 470 then
            rgb_out <= x"FFFF";  -- Borde blanco
        elsif x_u >= head_x_u * 10 and x_u < (head_x_u + 1) * 10 and
              y_u >= head_y_u * 10 and y_u < (head_y_u + 1) * 10 then
            rgb_out <= x"0FF0";  -- Cabeza verde
        elsif x_u >= fruit_x_u * 10 and x_u < (fruit_x_u + 1) * 10 and
              y_u >= fruit_y_u * 10 and y_u < (fruit_y_u + 1) * 10 then
            rgb_out <= x"F800";  -- Fruta roja
        elsif match = '1' then
            rgb_out <= x"03E0";  -- Cola verde clara
        else
            rgb_out <= x"0000";  -- Fondo negro
        end if;
    end process;

end Behavioral;
