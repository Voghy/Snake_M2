library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_vga_demo_snake_btn is
end tb_vga_demo_snake_btn;

architecture sim of tb_vga_demo_snake_btn is

    constant CLK_PERIOD : time := 10 ns;

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal head_x      : std_logic_vector(7 downto 0) := (others => '0');
    signal head_y      : std_logic_vector(7 downto 0) := (others => '0');
    signal cola_len    : std_logic_vector(7 downto 0) := (others => '0');
    signal fruit_x     : std_logic_vector(7 downto 0);
    signal fruit_y     : std_logic_vector(7 downto 0);
    signal flags_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal flags_out   : std_logic_vector(7 downto 0);
    signal hsync       : std_logic;
    signal vsync       : std_logic;
    signal rgb         : std_logic_vector(15 downto 0);

begin

    uut: entity work.vga_demo_snake_btn
        generic map (
            CD => 16,
            MAX_COLA => 64
        )
        port map (
            clk         => clk,
            reset       => reset,
            head_x      => head_x,
            head_y      => head_y,
            cola_len    => cola_len,
            fruit_x     => fruit_x,
            fruit_y     => fruit_y,
            flags_in    => flags_in,
            flags_out   => flags_out,
            hsync       => hsync,
            vsync       => vsync,
            rgb         => rgb
        );

    -- Clock generator
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';

        -- Set cola_len
        cola_len <= x"20";  -- 32 segmentos

        -- Colocar cabeza
        head_x <= x"10";
        head_y <= x"08";
        wait for 100 ns;

        -- Solicitar fruta
        flags_in(3) <= '1';  -- pedir_fruta
        wait for 20 ns;
        flags_in(3) <= '0';
        wait for 100 ns;

        -- Mover cabeza hacia la fruta
        for i in 0 to 10 loop
            head_x <= std_logic_vector(unsigned(head_x) + 1);
            wait for 40 ns;
        end loop;

        -- Simular aceptación de fruta
        flags_in(2) <= '1';  -- fruta_ok
        wait for 20 ns;
        flags_in(2) <= '0';

        -- Pausa
        flags_in(0) <= '1';  -- pause
        wait for 200 ns;
        flags_in(0) <= '0';

        wait for 500 ns;
        assert false report "Simulation finished" severity failure;
    end process;

end sim;
