library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity randomizador is
    generic (
        N : integer := 100;
        defaultValue: natural:= 48
    );
    port (
        clk          : in  std_logic;
        rand         : in  std_logic;  --Genera un valor entre 0 y N
        chaos        : in  std_logic;  --Cambia la semilla del randomizador con respecto al procedimiento apply_chaos
        read         : in  std_logic;  --baja la señal done
        randomNumber : out unsigned(integer(ceil(log2(real(N)))) - 1 downto 0); --salida
        done         : out std_logic -- avisa que tenemos el valor solicitado listo
    );
end entity;

architecture Behavioral of randomizador is

    constant BITS_OUT : integer := integer(ceil(log2(real(N))));
    signal counter     : unsigned(31 downto 0) := (others => '0');
    signal prev_chaos  : std_logic := '0';
    signal prev_rand   : std_logic := '0';
    signal prev_read   : std_logic := '0';
    signal done_reg    : std_logic := '0';
    signal rnd_val     : unsigned(BITS_OUT - 1 downto 0):= to_unsigned(defaultValue,BITS_OUT);

    procedure apply_chaos(signal cnt: inout unsigned(31 downto 0)) is
    begin
        cnt <= (cnt xor rotate_left(cnt, 3)) + rotate_right(cnt, 5);
    end procedure;

begin

    -- Contador libre con alteración caótica
    process(clk)
    begin
        if rising_edge(clk) then
            if (prev_chaos = '0' and chaos = '1') then
                apply_chaos(counter);
            else
                counter <= counter + 1;
            end if;
            prev_chaos <= chaos;
        end if;
    end process;

    -- Generación y lectura del número aleatorio
    process(clk)
    begin
        if rising_edge(clk) then
            -- rand ↑ genera nuevo número y activa done
            if (prev_rand = '0' and rand = '1') then
                rnd_val <= to_unsigned(to_integer(counter) mod N, BITS_OUT);
                done_reg <= '1';

            -- read ↑ baja done
            elsif (prev_read = '0' and read = '1') then
                done_reg <= '0';
            end if;

            prev_rand <= rand;
            prev_read <= read;
        end if;
    end process;

    randomNumber <= rnd_val;
    done <= done_reg;

end architecture;
