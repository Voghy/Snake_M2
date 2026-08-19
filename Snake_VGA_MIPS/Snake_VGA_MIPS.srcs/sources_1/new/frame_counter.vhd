library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity frame_counter is
    generic (
        HMAX : integer := 640;
        VMAX : integer := 480
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        inc         : in  std_logic;
        sync_clr    : in  std_logic;
        hcount      : out std_logic_vector(10 downto 0);
        vcount      : out std_logic_vector(10 downto 0);
        frame_start : out std_logic;
        frame_end   : out std_logic
    );
end frame_counter;

architecture Behavioral of frame_counter is
    signal hc_reg, vc_reg : unsigned(10 downto 0) := (others => '0');
    signal hc_next, vc_next : unsigned(10 downto 0);
begin

    -- Register logic (secuencial)
    process(clk, reset)
    begin
        if reset = '1' then
            hc_reg <= (others => '0');
            vc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if sync_clr = '1' then
                hc_reg <= (others => '0');
                vc_reg <= (others => '0');
            else
                hc_reg <= hc_next;
                vc_reg <= vc_next;
            end if;
        end if;
    end process;

    -- Next-state logic para contador horizontal
    process(hc_reg, inc)
    begin
        if inc = '1' then
            if hc_reg = HMAX - 1 then
                hc_next <= (others => '0');
            else
                hc_next <= hc_reg + 1;
            end if;
        else
            hc_next <= hc_reg;
        end if;
    end process;

    -- Next-state logic para contador vertical
    process(vc_reg, hc_reg, inc)
    begin
        if inc = '1' and hc_reg = HMAX - 1 then
            if vc_reg = VMAX - 1 then
                vc_next <= (others => '0');
            else
                vc_next <= vc_reg + 1;
            end if;
        else
            vc_next <= vc_reg;
        end if;
    end process;

    -- Salidas
    hcount <= std_logic_vector(hc_reg);
    vcount <= std_logic_vector(vc_reg);
    frame_start <= '1' when (hc_reg = 0 and vc_reg = 0) else '0';
    frame_end   <= '1' when (hc_reg = HMAX - 1 and vc_reg = VMAX - 1) else '0';

end Behavioral;
