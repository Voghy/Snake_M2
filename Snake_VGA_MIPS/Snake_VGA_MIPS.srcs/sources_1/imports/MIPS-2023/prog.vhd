----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:56:11 04/04/2020 
-- Design Name: 
-- Module Name:    prog - Behavioral 
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

use work.general.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prog is
    Port ( dataDeMI : in  STD_LOGIC_VECTOR (31 downto 0);
           dataAMI  : out  STD_LOGIC_VECTOR (31 downto 0);
           dirMI    : out  STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
           writeMI  : out  STD_LOGIC;
           rstMIPS  : out  STD_LOGIC;
			  -- líneas de control
			  clk      : in STD_LOGIC;
			  -- puerto serial
			  rx       : in std_logic;
			  tx       : out std_logic;
			  Atn      : in std_logic);
end prog;

architecture Behavioral of prog is
	COMPONENT control_prog is
    Port ( -- Interfaz con la Memoria de Instrucciones del MIPS y el MIPS en general
	        DataDeMI : in   STD_LOGIC_VECTOR (31 downto 0);
           DataAMI  : out  STD_LOGIC_VECTOR (31 downto 0);
           DirMI    : out  STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
           writeMI  : out  STD_LOGIC;
           rstMIPS  : out  STD_LOGIC;
			  -- Interfaz con el PSOC y el UART
			  Atn		  : in   std_logic;
           Enviado  : in   STD_LOGIC;
           TxData   : out  STD_LOGIC_VECTOR (7 downto 0);
           ReadyTx  : out  STD_LOGIC;
           RxData   : in   STD_LOGIC_VECTOR (7 downto 0);
           ReadyRx  : in   STD_LOGIC;
           ResetTx  : out  STD_LOGIC;
           ResetRx  : out  STD_LOGIC;
			  -- Señales generales
           clk      : in   STD_LOGIC);
	END COMPONENT;
	COMPONENT uart_rx is
   Port ( rx       : in  STD_LOGIC;
			 clk      : in  STD_LOGIC;
			 resetRx  : in  STD_LOGIC;
			 rxdata   : out STD_LOGIC_VECTOR (7 downto 0);
			 readyRx  : out STD_LOGIC);
	END COMPONENT;
	COMPONENT uart_tx is
	Port ( clk      : in  STD_LOGIC;
			 resetTx  : in  STD_LOGIC;
			 txdata   : in  STD_LOGIC_VECTOR (7 downto 0);
			 readyTx  : in  STD_LOGIC;
			 tx       : out STD_LOGIC;
			 enviado  : out STD_LOGIC);
	END COMPONENT;

	-- señales de interconexión
--		signal DataDeMI : STD_LOGIC_VECTOR (31 downto 0);
--		signal DataAMI : STD_LOGIC_VECTOR (31 downto 0);
--		signal DirMI : STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
--		signal writeMI : std_logic;
--		signal rstMIPS : std_logic;
		-- Interfaz con el PSOC y el UART
--		signal Atn : std_logic;
		signal Enviado : std_logic;
		signal TxData : std_logic_vector (7 downto 0);
		signal ReadyTx : std_logic;
		signal RxData : std_logic_vector (7 downto 0);
		signal ReadyRx : std_logic;
		signal ResetTx : std_logic;
		signal ResetRx : std_logic;
		-- Señales generales
--		signal Reset : std_logic;
--      signal clk : std_logic;
	
begin
	Inst_control_prog :  control_prog PORT MAP(
		DataDeMI => DataDeMI,
		DataAMI  => DataAMI,
		DirMI    => DirMI,
		writeMI  => writeMI,
		rstMIPS  => rstMIPS,
		-- Interfaz con el PSOC y el UART
		Atn      => Atn,
		Enviado  => Enviado,
		TxData   => TxData,
		ReadyTx  => ReadyTx,
		RxData   => RxData,
		ReadyRx  => ReadyRx,
		ResetTx  => ResetTx,
		ResetRx  => ResetRx,
		-- Señales generales
      clk      => clk
	);

	inst_uart_tx : uart_tx PORT MAP (
		clk      => clk,
		resetTx  => resetTx,
		txdata   => txdata,
		readyTx  => readyTx,
		tx       => tx,
		enviado  => enviado
	);
	
	inst_uart_rx : uart_rx PORT MAP (
		rx       => rx,
		clk      => clk,
		resetRx  => resetRx,
		rxdata   => rxdata,
		readyRx  => readyRx
	);
	
end Behavioral;

