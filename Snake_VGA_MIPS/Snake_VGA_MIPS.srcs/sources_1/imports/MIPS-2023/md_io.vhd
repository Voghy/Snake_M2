library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.general.all;
entity md_io is
    Port (
        clk125mhz : in  STD_LOGIC;
        address   : in  STD_LOGIC_VECTOR (31 downto 0);
        writedata : in  STD_LOGIC_VECTOR (31 downto 0);
        memwrite  : in  STD_LOGIC;
        memread   : in  STD_LOGIC;
        tipoAcc   : in  STD_LOGIC_VECTOR (2 downto 0);
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        botones   : in  std_logic_vector(3 downto 0);
        llaves    : in  std_logic_vector(3 downto 0);
        salida    : out std_logic_vector(3 downto 0);
        readdata  : out STD_LOGIC_VECTOR (31 downto 0);
        
        -- ? NUEVAS SALIDAS PARA VGA
        hsync     : out std_logic;
        vsync     : out std_logic;
        rgb       : out std_logic_vector(15 downto 0)
    );
end md_io;

architecture Behavioral of md_io is

    COMPONENT entrada
        Port (
            btn    : in  STD_LOGIC_VECTOR(3 downto 0);
            sw     : in  STD_LOGIC_VECTOR(3 downto 0);
            alMIPS : out STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;

    COMPONENT decodificador
        Port (
            ent       : in  STD_LOGIC_VECTOR (31 downto 0);
            csMem     : out STD_LOGIC;
            csParPort : out STD_LOGIC;
            csEntrada : out STD_LOGIC;
            csVGA     : out STD_LOGIC
        );
    END COMPONENT;

    COMPONENT md
        Port (
            dir      : STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_DATOS -1 +2 downto 0);
            datain   : in  STD_LOGIC_VECTOR (31 downto 0);
            cs       : in  STD_LOGIC;
            memwrite : in  STD_LOGIC;
            memread  : in  STD_LOGIC;
            tipoAcc  : in  STD_LOGIC_VECTOR (2 downto 0);
            clk      : in  STD_LOGIC;
            dataout  : out STD_LOGIC_VECTOR (31 downto 0)
        );
    END COMPONENT;

    COMPONENT salida_par
        Port (
            sel        : in  STD_LOGIC;
            write_cntl : in  STD_LOGIC;
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            data       : in  STD_LOGIC_VECTOR(3 downto 0);
            salida     : out STD_LOGIC_VECTOR(3 downto 0)
        );
    END COMPONENT;
    
      COMPONENT vga_demo_snake_btn
        generic (
            CD : integer := 16;
            MAX_COLA : integer := 64
        );
        port (
            clk         : in  std_logic;
            head_x      : in  std_logic_vector(7 downto 0);
            head_y      : in  std_logic_vector(7 downto 0);
            cola_len    : in  std_logic_vector(7 downto 0);
            fruit_x     : out std_logic_vector(7 downto 0);
            fruit_y     : out std_logic_vector(7 downto 0);
            flags_in    : in  std_logic_vector(7 downto 0);
            flags_out   : out std_logic_vector(7 downto 0);
            hsync       : out std_logic;
            vsync       : out std_logic;
            rgb         : out std_logic_vector(15 downto 0)
        );
    END COMPONENT;


    -- Señales internas
    signal csMem       : STD_LOGIC;
    signal csSalidaPar : STD_LOGIC;
    signal csEntrada   : STD_LOGIC;
    signal datosMem    : STD_LOGIC_VECTOR (31 downto 0);
    signal datosEntrada: STD_LOGIC_VECTOR (7 downto 0);

    signal csVGA            : STD_LOGIC;
    signal hsync_i, vsync_i : std_logic;
    signal rgb_i            : std_logic_vector(15 downto 0);
    
      -- Señales Snake
    signal head_x, head_y   : std_logic_vector(7 downto 0);
    signal cola_len_reg         : std_logic_vector(7 downto 0);
    signal fruit_x, fruit_y : std_logic_vector(7 downto 0);
    signal flags_in         : std_logic_vector(7 downto 0);
    signal flags_out        : std_logic_vector(7 downto 0);
   
    signal tick             : std_logic := '0';
    signal clk_div: integer range 0 to 3000000 := 0;


begin

    -- Multiplexor de lectura
    readdata <= datosMem                                       when csMem = '1' and memread = '1' else
                x"000000" & datosEntrada                       when csEntrada = '1' and memread = '1' else
                x"0000" & fruit_x & fruit_y                    when csVGA = '1' and memread = '1' and address = x"FFFFC006" else
                x"000000" & flags_out                          when csVGA = '1' and memread = '1' and address = x"FFFFC005" else
                x"0000000" & b"000" & tick                     when csVGA = '1' and memread = '1' and address = x"FFFFC004" else 
                x"000000" & cola_len_reg                       when csVGA = '1' and memread = '1' and address = x"FFFFC002" else
                (others => '0');


    
    
    -- Entrada de botones/llaves
    Inst_entrada: entrada PORT MAP (
        btn    => botones,
        sw     => llaves,
        alMIPS => datosEntrada
    );

    -- Decodificador de dirección
    Inst_decodificador: decodificador PORT MAP (
        ent       => address,
        csMem     => csMem,
        csParPort => csSalidaPar,
        csEntrada => csEntrada,
        csVGA     => csVGA
    );

    -- Memoria de datos
    Inst_md: md PORT MAP (
        dir      => address(NUM_BITS_MEMORIA_DATOS -1+2 downto 0),
        datain   => writedata,
        cs       => csMem,
        memwrite => memwrite,
        memread  => memread,
        tipoAcc  => tipoAcc,
        clk      => clk,
        dataout  => datosMem
    );

    -- Salida paralela
    Inst_salida_par: salida_par PORT MAP (
        sel        => csSalidaPar,
        write_cntl => memwrite,
        clk        => clk,
        reset      => reset,
        data       => writedata(3 downto 0),
        salida     => salida
    );
    -- VGA Instanciada con Snake
    Inst_VGA: vga_demo_snake_btn
        generic map (
            CD => 16,
            MAX_COLA => 64
        )
        port map (
            clk       => clk125mhz,
            head_x    => head_x,
            head_y    => head_y,
            cola_len  => cola_len_reg,
            fruit_x   => fruit_x,
            fruit_y   => fruit_y,
            flags_in  => flags_in,
            flags_out => flags_out,
            hsync     => hsync_i,
            vsync     => vsync_i,
            rgb       => rgb_i
        );

    hsync <= hsync_i;
    vsync <= vsync_i;
    rgb   <= rgb_i;

    -- Escritura desde MIPS
    process(clk)
    begin
        if rising_edge(clk) then
            if memwrite = '1' and csVGA = '1' then
                case address(2 downto 0) is
                    when "000" => head_x    <= writedata(7 downto 0);
                    when "001" => head_y    <= writedata(7 downto 0);
                    when "010" => cola_len_reg  <= writedata(7 downto 0);
                    when "011" => flags_in  <= writedata(7 downto 0);
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Tick como antes (puede usarse para control externo desde MIPS)
    process(clk)
    begin
        if rising_edge(clk) then
            if csVGA = '1' and address = x"FFFFC004" and tick = '1' then 
                clk_div <= 0;
            elsif clk_div = 2999999 then
                tick <= '1';
            else 
                clk_div <= clk_div + 1;
                tick<='0';
            end if;
        end if;
    end process;

end Behavioral;
