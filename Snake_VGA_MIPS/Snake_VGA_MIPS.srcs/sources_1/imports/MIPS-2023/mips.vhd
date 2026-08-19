----------------------------------------------------------------------------------
-- Company: Universidad Catolica
-- Engineer: Vicente Gonz�lez
-- 
-- Create Date:    17:23:17 04/08/2010 
-- Design Name: MIPS
-- Module Name:    mips - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 13/6/2016
-- Revision 0.01 - File Created
-- Additional Comments: 
-- Se modific� este archivo para que la constante declarada en general.vhd, que define el tama�o de la 
-- ROM de instrucciones, afecte tambi�n aqu�. Lo mismo se hizo para la memoria de datos. 
-- 
--
-- ERRORES CONOCIDOS:
----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.general.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mips is
	port (
		clk         : in std_logic;
		-- pines de reset externos los pines west y east de alrededor de la perilla de la placa
		reset_boton : in std_logic;
		-- entrada de los dos pulsadores de alrededor de la perilla de la placa
		salida      : out std_logic_vector(3 downto 0);
		botones     : in  std_logic_vector(3 downto 0);
		llaves      : in  std_logic_vector(3 downto 0);
		-- puerto serial
		rx          : in std_logic;
		tx          : out std_logic;
		atn         : in std_logic;
		
		hsync     : out std_logic;
        vsync     : out std_logic;
        rgb       : out std_logic_vector(15 downto 0)

    );
end mips;

architecture Behavioral of mips is
--    COMPONENT divisorCLK is
--        Port ( clk50mhz : in  STD_LOGIC;
--               clk : out  STD_LOGIC);
--        end component;
    
    component clk_wiz_1 is
    port(
            clk:in std_logic;
            reset:in std_logic;
            locked: out std_logic;
            clk50mhz: out std_logic;
            clk125mhz: out std_logic
        );
    end component;
    
    COMPONENT prog is
        Port (  dataDeMI : in  STD_LOGIC_VECTOR (31 downto 0);
                dataAMI  : out  STD_LOGIC_VECTOR (31 downto 0);
                dirMI    : out  STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
                writeMI  : out  STD_LOGIC;
                rstMIPS  : out  STD_LOGIC;
                -- l�neas de control
                clk      : in STD_LOGIC;
                -- puerto serial
                rx       : in std_logic;
                tx       : out std_logic;
                atn      : in std_logic
             );
   END COMPONENT;
    
   COMPONENT JR_detect
   PORT( 
		funct : IN  STD_LOGIC_VECTOR (5 downto 0);
		jr    : OUT  STD_LOGIC
		);
	END COMPONENT;
	COMPONENT antirebote
	PORT(
		boton1 : IN std_logic;
		boton2 : IN std_logic;
		clk    : IN std_logic;          
		reset  : OUT std_logic
		);
	END COMPONENT;
	COMPONENT pc	-- Program Counter
	PORT(
		e     : IN std_logic_vector(31 downto 0);
		reset : IN std_logic;
		clk   : IN std_logic;          
		s     : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	COMPONENT suma_4	-- sumador para realizar PC + 4
	PORT(
		e : IN std_logic_vector(31 downto 0);          
		s : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	COMPONENT mi	-- Memoria de Instrucciones
	PORT(
		dir       : IN std_logic_vector(NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
		s         : OUT std_logic_vector(31 downto 0);
			  -- interfaz con el programador
		dirMI     : in   STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
		dataS     : out  STD_LOGIC_VECTOR (31 downto 0);
		dataE     : in   STD_LOGIC_VECTOR (31 downto 0);
		writeProg : in std_logic;
		clk       : in std_logic
		);
	END COMPONENT;
	COMPONENT mux5_4a1
	PORT(
		e0      : IN std_logic_vector(4 downto 0);
		e1      : IN std_logic_vector(4 downto 0);
		e2      : IN std_logic_vector(4 downto 0);
		e3      : IN std_logic_vector(4 downto 0);
		control : IN std_logic_vector (1 downto 0);          
		s       : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;
	COMPONENT reg
	Port ( rr1      : in  STD_LOGIC_VECTOR (4 downto 0);
           rr2      : in  STD_LOGIC_VECTOR (4 downto 0);
           wr       : in  STD_LOGIC_VECTOR (4 downto 0);
           wd       : in  STD_LOGIC_VECTOR (31 downto 0);
           clk      : in  STD_LOGIC;
           regwrite : in  STD_LOGIC;
           rd1      : out STD_LOGIC_VECTOR (31 downto 0);
           rd2      : out STD_LOGIC_VECTOR (31 downto 0)
		 );
	END COMPONENT;
	COMPONENT shift_left16
	PORT(
		ent : IN std_logic_vector(15 downto 0);
		sal : OUT std_logic_vector(31 downto 0)       
		);
	END COMPONENT;
	COMPONENT alu
	Port ( 
		op1     : in  STD_LOGIC_VECTOR (31 downto 0);
		op2     : in  STD_LOGIC_VECTOR (31 downto 0);
		control : in  STD_LOGIC_VECTOR (3 downto 0);
		shiftamt: in  STD_LOGIC_VECTOR (4 downto 0);
		s       : out STD_LOGIC_VECTOR (31 downto 0);
		zero    : out STD_LOGIC
		);
	END COMPONENT;
	COMPONENT control_branch
	PORT(
		branch : IN std_logic;
		bne    : IN std_logic;
		zero   : IN std_logic;          
		sal    : OUT std_logic
		);
	END COMPONENT;
	COMPONENT exten_signo_cero
	PORT(
		e      : IN std_logic_vector(15 downto 0);
      cero_ext : in STD_LOGIC;		
		s      : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT md_io
	Port ( 
	       clk125mhz : in  STD_LOGIC;
	       address   : in  STD_LOGIC_VECTOR (31 downto 0);
           writedata : in  STD_LOGIC_VECTOR (31 downto 0);
           memwrite  : in  STD_LOGIC;
           memread   : in  STD_LOGIC;
		   tipoAcc   : in STD_LOGIC_VECTOR (2 downto 0); --tipo de operaci�n a realizar, cargar bytes, half word y word
           clk       : in  STD_LOGIC;
		   reset     : in STD_LOGIC;
		   botones   : in  std_logic_vector(3 downto 0);
		   llaves    : in  std_logic_vector(3 downto 0);
           salida    : out std_logic_vector(3 downto 0);
           readdata  : out  STD_LOGIC_VECTOR (31 downto 0);
           
           -- VGA interface
            hsync         : out std_logic;
            vsync         : out std_logic;
            rgb           : out std_logic_vector(15 downto 0)
         );
	END COMPONENT;
	
	COMPONENT mux32
	PORT(
		e0  : IN std_logic_vector(31 downto 0);
		e1  : IN std_logic_vector(31 downto 0);
		sel : IN std_logic;          
		s   : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	COMPONENT mux32_4a1
	PORT(
		e0 : IN std_logic_vector(31 downto 0);
		e1 : IN std_logic_vector(31 downto 0);
		e2 : IN std_logic_vector(31 downto 0);
		e3 : IN std_logic_vector(31 downto 0);
		sel : IN std_logic_vector(1 downto 0);          
		s : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	COMPONENT shift_left
	PORT(
		e : IN std_logic_vector(29 downto 0);          
		s : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	COMPONENT shift_left_j
   PORT( 
		ent : IN  STD_LOGIC_VECTOR (25 downto 0);
		sal : OUT STD_LOGIC_VECTOR (27 downto 0)
		);
	END COMPONENT;
	COMPONENT sumador32
	PORT(
		e1 : IN std_logic_vector(31 downto 0);
		e2 : IN std_logic_vector(31 downto 0);          
		s  : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	-- unidades de control
	COMPONENT alu_control
	PORT(
		aluop : IN std_logic_vector(2 downto 0);
		funct : IN std_logic_vector(5 downto 0);          
		s     : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	COMPONENT control1
	PORT(
		op          : in  STD_LOGIC_VECTOR (5 downto 0);
	    jr_detect   : in STD_LOGIC;
		reset       : in STD_LOGIC;
		 
		tipoAcc     : out STD_LOGIC_VECTOR (2 downto 0);
        regdst      : out  STD_LOGIC_VECTOR (1 downto 0);
        branch      : out  STD_LOGIC;
		bne         : out STD_LOGIC;
        memread     : out  STD_LOGIC;
        memtoreg    : out  STD_LOGIC_VECTOR (1 downto 0);
        aluop       : out  STD_LOGIC_VECTOR (2 downto 0);
        memwrite    : out  STD_LOGIC;
        alusrc      : out  STD_LOGIC;
		lui         : out STD_LOGIC;
		jump        : out STD_LOGIC_VECTOR (1 downto 0);
        regwrite    : out  STD_LOGIC;
		Zero_extend : out STD_LOGIC
		);
	END COMPONENT;


	-- Definimos se�ales para interconexi�n
	signal nuevo_pc : std_logic_vector(31 downto 0);
	signal dir_ins : std_logic_vector(31 downto 0);
	signal instruccion : std_logic_vector(31 downto 0);
	signal pc_mas_4 : std_logic_vector(31 downto 0);
	signal lee_reg1 : std_logic_vector(31 downto 0);
	signal lee_reg2 : std_logic_vector(31 downto 0);
	signal salida_alu : std_logic_vector(31 downto 0);
	signal salida_mem : std_logic_vector(31 downto 0);
	signal escribe_reg : std_logic_vector(31 downto 0);
	signal mem_o_alu : std_logic_vector(31 downto 0);
	signal ext_signo : std_logic_vector(31 downto 0);
	signal corr_izq : std_logic_vector(31 downto 0);
	signal dir_branch : std_logic_vector(31 downto 0);
	signal dir_jump : std_logic_vector(31 downto 0);
	signal dir_jump28 : std_logic_vector(27 downto 0);
	signal dir_branch_o_PC_4 : std_logic_vector(31 downto 0);
	signal shift_16 : std_logic_vector(31 downto 0);
	signal tipoAcc : STD_LOGIC_VECTOR (2 downto 0);
	signal dir_esc_reg : std_logic_vector(4 downto 0);
	
	signal alu_cntl : std_logic_vector(3 downto 0);
	
	signal cero : std_logic;
	
	signal sal_mult_alu : std_logic_vector(31 downto 0);

	signal dirMIprog : std_logic_vector(NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
	signal dataDeMI : std_logic_vector(31 downto 0);
	signal dataAMI : std_logic_vector(31 downto 0);
	signal writeMIProg : std_logic;
	signal rstMIPSProg : std_logic;
	
	-- se�ales de control
	signal regdst : STD_LOGIC_VECTOR (1 downto 0);
	signal branch : std_logic;
	signal bne : std_logic;
	signal memread : std_logic;
	signal memtoreg : STD_LOGIC_VECTOR (1 downto 0);
	signal aluop : STD_LOGIC_VECTOR (2 downto 0);
	signal memwrite : std_logic;
	signal alusrc : std_logic;
	signal regwrite : std_logic;
	signal sel_mux_branch : std_logic;
	signal lui : std_logic;
	signal jump : std_logic_vector(1 downto 0);
	signal Zero_extend : STD_LOGIC;
	signal jr_detect_sig : std_logic;
	
	--signal reset_boton : std_logic;
	signal reset : std_logic;
	signal clk50mhz : std_logic;
	signal clk125mhz : std_logic;
    
    signal locked: std_logic;
	signal resetLock: std_logic;
	
    signal hsync_i, vsync_i : std_logic;
    signal rgb_i            : std_logic_vector(15 downto 0);


begin
    inst_divisor : clk_wiz_1 PORT MAP (
        clk50mhz => clk50mhz,
        clk125mhz => clk125mhz,
        clk => clk,
        locked => locked,
        reset =>reset
    );

    inst_prog : prog PORT MAP (
		dataDeMI => dataDeMI,
		dataAMI  => dataAMI,
		dirMI    => dirMIprog,
		writeMI  => writeMIProg,
		rstMIPS  => rstMIPSProg,
		-- l�neas de control
		clk      => clk50mhz,
		-- puerto serial
		rx       => rx,
		tx       => tx,
		atn      => atn
	);
	
	-- el reset del MIPS se activa o por los botones de reset externos 
	-- o por el reset del circuito de programaci�n
	reset <= reset_boton or rstMIPSProg;
	resetLock <= reset or not locked;
	
	Inst_pc: pc PORT MAP(
		e     => nuevo_pc,
		s     => dir_ins,
		reset => reset,
		clk   => clk50mhz
	);
	Inst_suma_4: suma_4 PORT MAP(
		e => dir_ins,
		s => pc_mas_4
	);
	Inst_mi: mi PORT MAP(
		dir       => dir_ins(NUM_BITS_MEMORIA_INSTRUCCIONES-1+2 downto 2),
		s         => instruccion,
		-- interfaz con el programador
		dirMI     => dirMIprog,
		dataS     => dataDeMI,
		dataE     => dataAMI,
		writeProg => writeMIProg,
		clk       => clk50mhz
	);
	Inst_mux5_4a1: mux5_4a1 PORT MAP(
		e0      => instruccion(20 downto 16),
		e1      => instruccion(15 downto 11),
		e2      => B"11111",
		e3      => B"11111",
		control => regdst,
		s       => dir_esc_reg
	);
	Inst_reg: reg PORT MAP(
		rr1      => instruccion(25 downto 21),
		rr2      => instruccion(20 downto 16),
		wr       => dir_esc_reg,
		wd       => escribe_reg,
		clk      => clk50mhz,
		regwrite => regwrite,
		rd1      => lee_reg1,
		rd2      => lee_reg2
	);
	Inst_shift_left16: shift_left16 PORT MAP(
		ent => instruccion(15 downto 0),
		sal => shift_16
	);
	Inst_alu: alu PORT MAP(
		op1      => lee_reg1,
		op2      => sal_mult_alu,
		control  => alu_cntl,
		shiftamt => instruccion(10 downto 6),
		s        => salida_alu,
		zero     => cero
	);
	Inst_exten_signo_cero: exten_signo_cero PORT MAP(
		e        => instruccion(15 downto 0),
		cero_ext => Zero_extend,
		s        => ext_signo
	);
	Inst_control_branch: control_branch PORT MAP(
		branch => branch,
		bne    => bne,
		zero   => cero,
		sal    => sel_mux_branch
	);
	Inst_md_io : md_io PORT MAP (
	    clk125mhz => clk,
		address   => salida_alu,
		writedata => lee_reg2,
		memwrite  => memwrite,
		memread   => memread,
		tipoAcc   => tipoAcc,
		clk       => clk50mhz,
		reset     => reset,
		botones   => botones,
		llaves    => llaves,
		readdata  => salida_mem,
		salida    => salida,
		hsync     => hsync_i,
        vsync     => vsync_i,
        rgb       => rgb_i
	);
	Inst_mux32_branch: mux32 PORT MAP(
		e0  => pc_mas_4,
		e1  => dir_branch,
		sel => sel_mux_branch,
		s   => dir_branch_o_PC_4
	);
	Inst_mux32_4a1_jump: mux32_4a1 PORT MAP(
		e0  => dir_branch_o_PC_4,
		e1  => dir_jump,
		e2  => lee_reg1,
		e3  => lee_reg1,
		sel => jump,
		s   => nuevo_pc
	);
	Inst_mux32_4a1_mem: mux32_4a1 PORT MAP(
		e0  => salida_alu,
		e1  => salida_mem,
		e2  => shift_16,
		e3  => pc_mas_4,
		sel => memtoreg,
		s   => mem_o_alu
	);
	Inst_mux32_lui: mux32 PORT MAP(
		e0  => mem_o_alu,
		e1  => shift_16,
		sel => lui,
		s   => escribe_reg
	);
	Inst_mux32_ALU: mux32 PORT MAP(
		e0  => lee_reg2,
		e1  => ext_signo,
		sel => alusrc,
		s   => sal_mult_alu
	);
	Inst_shift_left: shift_left PORT MAP(
		e => ext_signo(29 downto 0),
		s => corr_izq
	);
	Inst_shift_left_jump: shift_left_j PORT MAP(
		ent => instruccion(25 downto 0),
		sal => dir_jump28
	);
	dir_jump <= pc_mas_4(31 downto 28) & dir_jump28;
	Inst_sumador32: sumador32 PORT MAP(
		e1 => pc_mas_4,
		e2 => corr_izq,
		s  => dir_branch
	);
	Inst_alu_control: alu_control	PORT MAP(
		aluop => aluop,
		funct => instruccion(5 downto 0),
		s     => alu_cntl
	);
	Inst_jr_detect: JR_detect PORT MAP(
		funct => instruccion(5 downto 0),
		jr    => jr_detect_sig
	);
	Inst_control1: control1 PORT MAP(
		op          => instruccion(31 downto 26),
		jr_detect   => jr_detect_sig,
		reset       => reset,
		tipoAcc     => tipoAcc,
		regdst      => regdst,
		branch      => branch,
		bne         => bne,
		memread     => memread,
		memtoreg    => memtoreg,
		aluop       => aluop,
		memwrite    => memwrite,
		alusrc      => alusrc,
		lui         => lui,
		jump        => jump,
		regwrite    => regwrite,
		Zero_extend => Zero_extend
	);
	-- Conectar salidas internas a los puertos externos
    hsync <= hsync_i;
    vsync <= vsync_i;
    rgb   <= rgb_i;


end Behavioral;

