library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_snake_btn_sw is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        btn     : in  std_logic_vector(3 downto 0); -- {der, izq, arr, abj}
        sw      : in  std_logic_vector(1 downto 0); -- sw(0)=pausa, sw(1)=reset
        hsync   : out std_logic;
        vsync   : out std_logic;
        rgb     : out std_logic_vector(15 downto 0)
    );
end top_snake_btn_sw;

architecture Behavioral of top_snake_btn_sw is

    signal head_x      : std_logic_vector(7 downto 0);
    signal head_y      : std_logic_vector(7 downto 0);
    signal cola_len    : std_logic_vector(7 downto 0);
    signal flags_in    : std_logic_vector(7 downto 0);
    signal fruit_x     : std_logic_vector(7 downto 0);
    signal fruit_y     : std_logic_vector(7 downto 0);
    signal flags_out   : std_logic_vector(7 downto 0);

begin

    
    controller: entity work.snake_controller_btn_sw
        port map (
            clk       => clk,
            btn       => btn,
            sw        => sw,
            head_x    => head_x,
            head_y    => head_y,
            cola_len  => cola_len,
            flags_in  => flags_in,
            fruit_x   => fruit_x,
            fruit_y   => fruit_y,
            flags_out => flags_out
        );

    vga_snake: entity work.vga_demo_snake_btn
        generic map (
            CD => 16,
            MAX_COLA => 64
        )
        port map (
            clk       => clk,
            head_x    => head_x,
            head_y    => head_y,
            cola_len  => cola_len,
            fruit_x   => fruit_x,
            fruit_y   => fruit_y,
            flags_in  => flags_in,
            flags_out => flags_out,
            hsync     => hsync,
            vsync     => vsync,
            rgb       => rgb
        );

end Behavioral;
