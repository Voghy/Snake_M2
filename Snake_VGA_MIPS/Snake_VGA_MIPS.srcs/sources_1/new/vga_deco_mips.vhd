library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_controller_btn_sw is
    port (
        clk       : in  std_logic;
        btn       : in  std_logic_vector(3 downto 0); -- {der, izq, arr, abj}
        sw        : in  std_logic_vector(1 downto 0); -- sw(0) pausa, sw(1) reset

        head_x    : out std_logic_vector(7 downto 0);
        head_y    : out std_logic_vector(7 downto 0);
        cola_len  : out std_logic_vector(7 downto 0);
        flags_in  : out std_logic_vector(7 downto 0);
        fruit_x   : in  std_logic_vector(7 downto 0);
        fruit_y   : in  std_logic_vector(7 downto 0);
        flags_out : in  std_logic_vector(7 downto 0)
    );
end snake_controller_btn_sw;

architecture Behavioral of snake_controller_btn_sw is
    type dir_type is (DER, IZQ, ARR, ABJ);
    signal current_dir : dir_type := DER;

    signal x_pos : unsigned(7 downto 0) := to_unsigned(32, 8);
    signal y_pos : unsigned(7 downto 0) := to_unsigned(16, 8);
    signal counter : integer range 0 to 5000000 := 0;
    signal mover   : std_logic := '0';
begin
    -- Temporizador para mover la serpiente
    process(clk)
    begin
        if rising_edge(clk) then
            if counter < 5000000 then
                counter <= counter + 1;
                mover <= '0';
            else
                counter <= 0;
                mover <= '1';
            end if;
        end if;
    end process;

    -- Lógica de dirección
    process(clk)
    begin
        if rising_edge(clk) then
            
                if btn(0) = '1' and current_dir /= IZQ then current_dir <= DER; end if;
                if btn(1) = '1' and current_dir /= DER then current_dir <= IZQ; end if;
                if btn(2) = '1' and current_dir /= ABJ then current_dir <= ARR; end if;
                if btn(3) = '1' and current_dir /= ARR then current_dir <= ABJ; end if;
            
        end if;
    end process;

    -- Movimiento de la cabeza
    process(clk)
    begin
        if rising_edge(clk) and mover = '1' and sw(0) = '0' then
            case current_dir is
                when DER => x_pos <= x_pos + 1;
                when IZQ => x_pos <= x_pos - 1;
                when ARR => y_pos <= y_pos - 1;
                when ABJ => y_pos <= y_pos + 1;
            end case;
        end if;
    end process;

    head_x <= std_logic_vector(x_pos);
    head_y <= std_logic_vector(y_pos);
    cola_len <= x"64"; -- tamaño fijo de cola

    process(clk)
    begin
        if rising_edge(clk) then
            -- Flags entrada
            flags_in(0) <= sw(0);       -- pausa
            flags_in(1) <= sw(1);       -- reset
            flags_in(3) <= flags_out(0);-- pedir fruta si colisión
            flags_in(2) <= flags_out(1);-- fruta OK si generada
            flags_in(7 downto 4) <= (others => '0');
        end if;
    end process;

end Behavioral;
