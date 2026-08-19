library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync_demo is
    generic (
        CD : integer := 16  -- color depth
    );
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        vga_si_rgb : in  std_logic_vector(CD-1 downto 0);
        hsync      : out std_logic;
        vsync      : out std_logic;
        rgb        : out std_logic_vector(CD-1 downto 0);
        hc, vc     : out std_logic_vector(10 downto 0)
    );
end vga_sync_demo;

architecture Behavioral of vga_sync_demo is

    -- Parámetros VGA 640x480 @60Hz
    constant HD : integer := 640;
    constant HF : integer := 16;   -- Front porch
    constant HB : integer := 96;   -- Back porch
    constant HR : integer := 48;   -- HSync pulse width
    constant HT : integer := HD + HF + HB + HR;
    
    constant VD : integer := 480;
    constant VF : integer := 10;   -- Front porch
    constant VB : integer := 33;   -- Back porch
    constant VR : integer := 2;    -- VSync pulse width
    constant VT : integer := VD + VF + VB + VR;


    -- Señales internas
    signal q_reg      : unsigned(1 downto 0) := (others => '0');
    signal tick_25M   : std_logic;
    signal x, y       : std_logic_vector(10 downto 0);
    signal hsync_i, vsync_i, video_on_i : std_logic;
    signal hsync_reg, vsync_reg         : std_logic := '1';
    signal rgb_reg                      : std_logic_vector(CD-1 downto 0);

begin

    -- Divisor de reloj: genera tick cada 4 ciclos (25 MHz)
    process(clk)
    begin
        if rising_edge(clk) then
            q_reg <= q_reg + 1;
        end if;
    end process;

    tick_25M <= '1' when q_reg = "11" else '0';

    -- Instancia del frame_counter 
    frame_unit: entity work.frame_counter
        generic map (
            HMAX => HT,
            VMAX => VT
        )
        port map (
            clk         => clk,
            reset       => reset,
            sync_clr    => '0',
            inc         => tick_25M,
            hcount      => x,
            vcount      => y,
            frame_start => open,
            frame_end   => open
        );

    -- Decodificación horizontal
    hsync_i <= '0' when (to_integer(unsigned(x)) >= HD + HF and to_integer(unsigned(x)) < HD + HF + HR) else '1';

    -- Decodificación vertical
    vsync_i <= '0' when (to_integer(unsigned(y)) >= VD + VF and to_integer(unsigned(y)) < VD + VF + VR) else '1';

    -- Video ON: solo dentro del área visible
    video_on_i <= '1' when (to_integer(unsigned(x)) < HD and to_integer(unsigned(y)) < VD) else '0';

    -- Registro de salida con máscara de video_on
    process(clk)
    begin
        if rising_edge(clk) then
            hsync_reg <= hsync_i;
            vsync_reg <= vsync_i;
            if video_on_i = '1' then
                rgb_reg <= vga_si_rgb;
            else
                rgb_reg <= (others => '0');
            end if;
        end if;
    end process;

    -- Salidas
    hsync <= hsync_reg;
    vsync <= vsync_reg;
    rgb   <= rgb_reg;
    hc    <= x;
    vc    <= y;

end Behavioral;
