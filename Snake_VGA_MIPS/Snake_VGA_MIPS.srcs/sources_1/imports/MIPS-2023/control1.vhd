----------------------------------------------------------------------------------
-- Company: LED - Universidad Católica "Nuestra Señora de la Asunción"
-- Engineer: Vicente González Ayala
-- 
-- Create Date:    08:41:02 04/16/2010 
-- Design Name: MIPS - Clase de Micro 2
-- Module Name:    control1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control1 is
    Port ( op          : in STD_LOGIC_VECTOR (5 downto 0);
	        jr_detect   : in STD_LOGIC;
			  reset       : in STD_LOGIC;
			  
			  tipoAcc     : out STD_LOGIC_VECTOR (2 downto 0);
           regdst      : out STD_LOGIC_VECTOR (1 downto 0);
           branch      : out STD_LOGIC;
			  bne         : out STD_LOGIC;
           memread     : out STD_LOGIC;
           memtoreg    : out STD_LOGIC_VECTOR (1 downto 0);
           aluop       : out STD_LOGIC_VECTOR (2 downto 0);
           memwrite    : out STD_LOGIC;
           alusrc      : out STD_LOGIC;
			  lui         : out STD_LOGIC;
			  jump        : out STD_LOGIC_VECTOR (1 downto 0);
           regwrite    : out STD_LOGIC;
			  Zero_extend : out STD_LOGIC);
end control1;

architecture Behavioral of control1 is
	constant R_OP     : STD_LOGIC_VECTOR(5 downto 0) := "000000"; -- ADD, SUB, AND, OR, SLT, SLL, SRL y SRA
	constant ADDI_OP  : STD_LOGIC_VECTOR(5 downto 0) := "001000";
	constant ADDIU_OP : STD_LOGIC_VECTOR(5 downto 0) := "001001";
	constant ORI_OP   : STD_LOGIC_VECTOR(5 downto 0) := "001101";
	constant XORI_OP  : STD_LOGIC_VECTOR(5 downto 0) := "001110";
	constant ANDI_OP  : STD_LOGIC_VECTOR(5 downto 0) := "001100";
	constant SLTI_OP  : STD_LOGIC_VECTOR(5 downto 0) := "001010";
	constant SLTIU_OP : STD_LOGIC_VECTOR(5 downto 0) := "001011";
	constant JUMP_OP  : STD_LOGIC_VECTOR(5 downto 0) := "000010";
	constant BNE_OP   : STD_LOGIC_VECTOR(5 downto 0) := "000101";
	constant BEQ_OP   : STD_LOGIC_VECTOR(5 downto 0) := "000100";
	constant LW_OP    : STD_LOGIC_VECTOR(5 downto 0) := "100011";
	constant LH_OP    : STD_LOGIC_VECTOR(5 downto 0) := "100001";
	constant LHU_OP   : STD_LOGIC_VECTOR(5 downto 0) := "100101";
	constant LB_OP    : STD_LOGIC_VECTOR(5 downto 0) := "100000";
	constant LBU_OP   : STD_LOGIC_VECTOR(5 downto 0) := "100100";
	constant SW_OP    : STD_LOGIC_VECTOR(5 downto 0) := "101011";
	constant SH_OP    : STD_LOGIC_VECTOR(5 downto 0) := "101001";
	constant SB_OP    : STD_LOGIC_VECTOR(5 downto 0) := "101000";
	constant LUI_OP   : STD_LOGIC_VECTOR(5 downto 0) := "001111";
	constant JAL_OP   : STD_LOGIC_VECTOR(5 downto 0) := "000011";
begin
	regdst   <= "01" when op = R_OP and jr_detect = '0' and reset = '0' else	-- en instrucciones formato R
					"10" when op = JAL_OP and reset = '0' else -- en instrucciones JAL
					--'11' when else -- combinación que no se usa
	            "00";	-- en todas las demás, incluido el caso de que reset sea '1'
	branch   <= '1' when (op = BEQ_OP or op = BNE_OP) and reset = '0' else	-- en beq o bne
	            '0';
	bne	   <= '1' when op = BNE_OP and reset = '0' else
	            '0';
	memread  <= '1' when (op = LW_OP or op = LB_OP or op = LBU_OP or op = LH_OP or op = LHU_OP) and reset = '0' else	-- en lw o lb o lbu o lh o lhu
	            '0';
	memtoreg <= "01" when (op = LW_OP or op = LB_OP or op = LBU_OP or op = LH_OP or op = LHU_OP) and reset = '0' else	-- en lw o lb o lbu o lh o lhu
					"10" when op = LUI_OP and reset = '0' else -- en lui
					"11" when op = JAL_OP and reset = '0' else  -- en JAL
	            "00";  -- para todos los demás casos
	aluop    <= "000" when (op = LW_OP or op = LB_OP or op = LBU_OP or op = LH_OP or op = LHU_OP or op = SW_OP or op = SB_OP or op = SH_OP or op = ADDI_OP or OP = ADDIU_OP) and reset = '0' else	-- en lw, lb, lbu, lh, lhu, sw, sb, sh o addi
					"001" when (op = BEQ_OP or op = BNE_OP) and reset = '0' else	-- en beq o bne
					"010" when (op = R_OP and jr_detect = '0') and reset = '0' else	-- en instrucciones formato R
					"011" when op = ORI_OP and reset = '0' else -- en la instrucción ORI
					"100" when op = ANDI_OP and reset = '0' else -- en la instrucción ANDI
					"110" when op = XORI_OP and reset = '0' else -- en la instrucción XORI
					"101" when op = SLTI_OP and reset = '0' else -- en la instrucción SLTI
					"111" when op = SLTIU_OP and reset = '0' else -- en la instrucción SLTIU
					"000"; -- si no se cumple ninguna de las condiciones anteriores 
	memwrite <= '1' when (op = SW_OP or op = SB_OP or op = SH_OP) and reset = '0' else	-- en sw, sb, sh
	            '0';
	alusrc   <= '1' when (op = LW_OP or op = LB_OP or op = LBU_OP or op = LH_OP or op = LHU_OP or op = SW_OP or op = SB_OP or op = SH_OP or op = ADDI_OP or op = ADDIU_OP or op = ORI_OP or op = XORI_OP or op = ANDI_OP or op = SLTI_OP or op = SLTIU_OP) and reset = '0' else	-- en lw, lb, lbu, lh, lhu, sw, sb, sh, ori o addi
	            '0';
	regwrite <= '1' when ((op = R_OP and jr_detect = '0') or op = LW_OP or op = LB_OP or op = LBU_OP or op = LH_OP or op = LHU_OP or op = LUI_OP or op = ADDI_OP or op = ADDIU_OP or op = ORI_OP or op = XORI_OP or op = ANDI_OP or op = SLTI_OP or op = SLTIU_OP or op = JAL_OP) and reset = '0' else	-- en instrucciones formato R, lw, lb, lbu, lh, lhu, lui, ori o addi
	            '0';
	lui      <= '1' when op = LUI_OP and reset = '0' else	-- en instrucción lui
			      '0';
	jump     <= "01" when (op = JUMP_OP or op = JAL_OP)and reset = '0' else  -- en jump y jal
	            "10" when op = R_OP and jr_detect = '1' and reset = '0' else  -- en instrucción jr
	            "00";
	Zero_extend <= '1' when (op = ANDI_OP or op = ORI_OP or op = XORI_OP) and reset = '0' else -- en andi, xori y ori
	               '0';
	tipoAcc <= "000" when (op = LW_OP  or op = SW_OP) and reset = '0' else
	           "001" when (op = LHU_OP or op = SH_OP) and reset = '0' else
				  "011" when (op = LH_OP  or op = SH_OP) and reset = '0' else
				  "010" when (op = LBU_OP or op = SB_OP) and reset = '0' else
				  "100" when (op = LB_OP  or op = SB_OP) and reset = '0' else
	           "111";
				  
end Behavioral;

