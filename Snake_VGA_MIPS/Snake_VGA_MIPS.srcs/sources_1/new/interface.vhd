-- snake_interface.vhd: interfaz entre el procesador MIPS y el sistema de video VGA Snake

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_interface is
    port (
        clk        : in  std_logic;
        addr       : in  std_logic_vector(7 downto 0);  -- dirección de registro
        we         : in  std_logic;                     -- write enable
        re         : in  std_logic;                     -- read enable
        wdata      : in  std_logic_vector(31 downto 0); -- datos de escritura
        rdata      : out std_logic_vector(31 downto 0); -- datos de lectura

        -- Entradas desde GPIO
        btn        : in  std_logic_vector(3 downto 0);
        sw         : in  std_logic_vector(1 downto 0);

        -- Salidas hacia VGA
        head_x     : out std_logic_vector(7 downto 0);
        head_y     : out std_logic_vector(7 downto 0);
        cola_len   : out std_logic_vector(7 downto 0);
        flags_in   : out std_logic_vector(7 downto 0);

        -- Entradas desde VGA
        fruit_x    : in  std_logic_vector(7 downto 0);
        fruit_y    : in  std_logic_vector(7 downto 0);
        flags_out  : in  std_logic_vector(7 downto 0)
    );
end snake_interface;

architecture Behavioral of snake_interface is
    signal reg_head_x    : std_logic_vector(7 downto 0) := x"20";
    signal reg_head_y    : std_logic_vector(7 downto 0) := x"10";
    signal reg_cola_len  : std_logic_vector(7 downto 0) := x"20";
    signal reg_flags_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_puntaje   : std_logic_vector(7 downto 0) := (others => '0');

    signal rdata_reg     : std_logic_vector(31 downto 0);

    constant HEAD_X_ADDR     : std_logic_vector(7 downto 0) := x"00";
    constant HEAD_Y_ADDR     : std_logic_vector(7 downto 0) := x"04";
    constant COLA_LEN_ADDR   : std_logic_vector(7 downto 0) := x"08";
    constant FLAGS_IN_ADDR   : std_logic_vector(7 downto 0) := x"0C";
    constant FRUIT_X_ADDR    : std_logic_vector(7 downto 0) := x"10";
    constant FRUIT_Y_ADDR    : std_logic_vector(7 downto 0) := x"14";
    constant FLAGS_OUT_ADDR  : std_logic_vector(7 downto 0) := x"18";
    constant PUNTAJE_ADDR    : std_logic_vector(7 downto 0) := x"1C";
    constant BTN_SW_ADDR     : std_logic_vector(7 downto 0) := x"20";

begin

    -- Escritura
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                case addr is
                    when HEAD_X_ADDR => reg_head_x <= wdata(7 downto 0);
                    when HEAD_Y_ADDR => reg_head_y <= wdata(7 downto 0);
                    when COLA_LEN_ADDR => reg_cola_len <= wdata(7 downto 0);
                    when FLAGS_IN_ADDR => reg_flags_in <= wdata(7 downto 0);
                    when PUNTAJE_ADDR => reg_puntaje <= wdata(7 downto 0);
                    when others => null;
                end case;
            end if;

            -- Lógica interna: si colision con fruta, aumenta puntaje
            if flags_out(0) = '1' then
                reg_puntaje <= std_logic_vector(unsigned(reg_puntaje) + 1);
            end if;
        end if;
    end process;

    -- Lectura
    process(all)
    begin
        case addr is
            when HEAD_X_ADDR    => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= reg_head_x;
            when HEAD_Y_ADDR    => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= reg_head_y;
            when COLA_LEN_ADDR  => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= reg_cola_len;
            when FLAGS_IN_ADDR  => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= reg_flags_in;
            when FRUIT_X_ADDR   => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= fruit_x;
            when FRUIT_Y_ADDR   => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= fruit_y;
            when FLAGS_OUT_ADDR => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= flags_out;
            when PUNTAJE_ADDR   => rdata_reg <= (others => '0'); rdata_reg(7 downto 0) <= reg_puntaje;
            when BTN_SW_ADDR    => rdata_reg <= (others => '0'); rdata_reg(3 downto 0) <= btn; rdata_reg(5 downto 4) <= sw;
            when others         => rdata_reg <= (others => '0');
        end case;
    end process;

    rdata <= rdata_reg;

    -- Salidas
    head_x    <= reg_head_x;
    head_y    <= reg_head_y;
    cola_len  <= reg_cola_len;
    flags_in  <= reg_flags_in;

end Behavioral;
