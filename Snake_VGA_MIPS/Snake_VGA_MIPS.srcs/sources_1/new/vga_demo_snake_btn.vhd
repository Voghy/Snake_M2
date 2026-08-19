-- vga_demo_snake_btn.vhd: Snake con movimiento real de la cola controlado con botones y switches

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.types_pkg.all;

entity vga_demo_snake_btn is
    generic (
        CD        : integer := 16;  -- reducido a 12 bits RGB
        MAX_COLA  : integer := 64
    );
    port (
        clk         : in  std_logic;
        head_x      : in  std_logic_vector(7 downto 0);
        head_y      : in  std_logic_vector(7 downto 0);
        cola_len    : in  std_logic_vector(7 downto 0);

        fruit_x     : out std_logic_vector(7 downto 0);
        fruit_y     : out std_logic_vector(7 downto 0);

        flags_in    : in  std_logic_vector(7 downto 0);  -- pausa, reset, fruta_ok, pedir_fruta
        flags_out   : out std_logic_vector(7 downto 0);  -- colision, fruta_lista

        hsync, vsync: out std_logic;
        rgb         : out std_logic_vector(CD-1 downto 0)
    );
end vga_demo_snake_btn;

architecture Behavioral of vga_demo_snake_btn is
    signal hc, vc         : std_logic_vector(10 downto 0);
    signal color_snake    : std_logic_vector(CD-1 downto 0);
    signal head_x_s       : std_logic_vector(5 downto 0);
    signal head_y_s       : std_logic_vector(5 downto 0);
    signal fruit_x_s      : std_logic_vector(5 downto 0):= "010100";
    signal fruit_y_s      : std_logic_vector(5 downto 0):= "001010";
    
    signal colaX, colaY   : cola_array := (others => (others => '0'));
    signal cola_len_s     : integer range 0 to MAX_COLA := 64;
    
    signal cola_len_int : integer range 0 to MAX_COLA := 4;

    signal mover : std_logic := '0';

    signal fruta_generada     : std_logic := '0';
    signal colision_detectada : std_logic := '0';
    signal colision_fruta     : std_logic := '0';
    -- Señales para el randomizador
    signal rand_x, rand_y : std_logic := '0';
    signal read_x, read_y : std_logic := '0';
    signal done_x, done_y : std_logic;
    signal rnd_x, rnd_y   : unsigned(5 downto 0);
    
    type fruit_state_type is (IDLE, WAIT_RANDOM, VALIDATE, DONE);
    signal fruit_state : fruit_state_type := IDLE;
    
    signal colision_bits : std_logic_vector(MAX_COLA-1 downto 0);

begin
    head_x_s <= head_x(5 downto 0);
    head_y_s <= head_y(5 downto 0);
    cola_len_s <= to_integer(unsigned(cola_len));
    --cola_len_s <= 64;
    fruit_x <= "00" & fruit_x_s;
    fruit_y <= "00" & fruit_y_s;

    flags_out(0) <= colision_detectada;
    flags_out(1) <= fruta_generada;
    flags_out(2) <= colision_fruta;
    flags_out(7 downto 3) <= (others => '0');

    sync_unit: entity work.vga_sync_demo
        generic map (CD => CD)
        port map (
            clk        => clk,
            reset      => '0',
            vga_si_rgb => color_snake,
            hsync      => hsync,
            vsync      => vsync,
            rgb        => rgb,
            hc         => hc,
            vc         => vc
        );

    display_snake: entity work.snake_vga_display
        generic map (
            CD => CD,
            MAX_COLA => MAX_COLA
        )
        port map (
            clk      => clk,
            x        => hc,
            y        => vc,
            head_x   => head_x_s,
            head_y   => head_y_s,
            fruit_x  => fruit_x_s,
            fruit_y  => fruit_y_s,
            colaX    => colaX,
            colaY    => colaY,
            cola_len => cola_len_int,
            rgb_out  => color_snake
        );
    -- Instancias del randomizador
    rand_x_unit: entity work.randomizador
        generic map (N => 64, defaultValue => 12)
        port map (
            clk           => clk,
            rand          => rand_x,
            chaos         => head_x_s(0),
            read          => read_x,
            randomNumber  => rnd_x,
            done          => done_x
        );

    rand_y_unit: entity work.randomizador
        generic map (N => 48, defaultValue => 24)
        port map (
            clk           => clk,
            rand          => rand_y,
            chaos         => head_y_s(0),
            read          => read_y,
            randomNumber  => rnd_y,
            done          => done_y
        );
    
    process(clk)
        variable en_cola : boolean := false;
    begin
        if rising_edge(clk) then

            -- Reseteo total
            if flags_in(1) = '1' then
                fruta_generada     <= '0';
                colision_detectada <= '0';
                colision_fruta     <= '0';
                colaX <= (others => (others => '0'));
                colaY <= (others => (others => '0'));
                fruit_x_s <= "010100";
                fruit_y_s <= "001010";
                fruit_state <= IDLE;
                cola_len_int <= 4;
            end if;

            -- Movimiento habilitado
            if head_x_s /= colaX(0) or head_y_s /= colaY(0) then
                mover <= '1';
            else
                mover <= '0';
            end if;

            -- FSM para generación de fruta
            case fruit_state is
                when IDLE =>
                    fruta_generada <= '0';
                    read_x <= '0';
                    read_y <= '0';
                    rand_x <= '0';
                    rand_y <= '0';

                    if flags_in(0) = '0' and mover = '1' then
                        for i in MAX_COLA-1 downto 1 loop
                            if i < cola_len_int then
                                colaX(i) <= colaX(i - 1);
                                colaY(i) <= colaY(i - 1);
                                if head_x_s = colaX(i) and head_y_s = colaY(i) then
                                    colision_detectada <= '1';
                                end if;
                            end if;
                        end loop;
                        colaX(0) <= head_x_s;
                        colaY(0) <= head_y_s;

                        if head_x_s = fruit_x_s and head_y_s = fruit_y_s then
                            colision_fruta <= '1';
                            rand_x <= '1';
                            rand_y <= '1';
                            cola_len_int <= cola_len_int + 1;
                            fruit_state <= WAIT_RANDOM;
                        end if;
                    end if;

                when WAIT_RANDOM =>
                    if done_x = '1' and done_y = '1' then
                        rand_x <= '0';
                        rand_y <= '0';
                        fruit_state <= VALIDATE;
                    end if;

                when VALIDATE =>
                    en_cola := false;

                    if rnd_x > 0 and rnd_x < 63 and rnd_y > 0 and rnd_y < 47 then
                        if rnd_x /= unsigned(head_x_s) or rnd_y /= unsigned(head_y_s) then
                            for i in 0 to MAX_COLA-1 loop
                                if i < cola_len_int then
                                    if rnd_x = unsigned(colaX(i)) and rnd_y = unsigned(colaY(i)) then
                                        en_cola := true;
                                    end if;
                                end if;
                            end loop;

                            if not en_cola then
                                fruit_x_s <= std_logic_vector(rnd_x);
                                fruit_y_s <= std_logic_vector(rnd_y);
                                fruta_generada <= '1';
                                read_x <= '1';
                                read_y <= '1';
                                fruit_state <= DONE;
                            else
                                rand_x <= '1';
                                rand_y <= '1';
                                fruit_state <= WAIT_RANDOM;
                            end if;
                        else
                            rand_x <= '1';
                            rand_y <= '1';
                            fruit_state <= WAIT_RANDOM;
                        end if;
                    else
                        rand_x <= '1';
                        rand_y <= '1';
                        fruit_state <= WAIT_RANDOM;
                    end if;

                when DONE =>
                    read_x <= '0';
                    read_y <= '0';
                    fruit_state <= IDLE;
            end case;

            -- Reset de colisión con fruta desde el procesador
            if flags_in(2) = '1' then
                colision_fruta <= '0';
            end if;

        end if;
    end process;
    
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            colision_detectada <= '0';
--            for i in 1 to cola_len_int - 1 loop
--                if colaX(i) = head_x_s and colaY(i) = head_y_s then
--                    colision_detectada <= '1';
--                end if;
--            end loop;
--        end if;
--    end process;


end Behavioral;
