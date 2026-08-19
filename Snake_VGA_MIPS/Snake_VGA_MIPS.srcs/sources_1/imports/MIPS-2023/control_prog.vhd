----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    16:27:29 03/25/2020 
-- Design Name: 
-- Module Name:    control - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.general.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_prog is
    Port ( -- Interfaz con la Memoria de Instrucciones del MIPS y el MIPS en general
	       DataDeMI : in  STD_LOGIC_VECTOR (31 downto 0);
           DataAMI  : out  STD_LOGIC_VECTOR (31 downto 0);
           DirMI    : out  STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
           writeMI  : out  STD_LOGIC;
           rstMIPS  : out  STD_LOGIC;
			  -- Interfaz con el PSOC y el UART
           Atn      : in  STD_LOGIC;
           Enviado  : in  STD_LOGIC;
           TxData   : out  STD_LOGIC_VECTOR (7 downto 0);
           ReadyTx  : out  STD_LOGIC;
           RxData   : in  STD_LOGIC_VECTOR (7 downto 0);
           ReadyRx  : in  STD_LOGIC;
           ResetTx  : out  STD_LOGIC;
           ResetRx  : out  STD_LOGIC;
			  -- Señales generales
           clk      : in  STD_LOGIC);
end control_prog;

architecture Behavioral of control_prog is
	-- Estados de la máquina de estados del control
								--- Espera comando
	type state_type is (st1_esperaAtn0, st2_esperaAtn1, st3_esperaComando,
								--- Comando C
	                    st4_C_enviaTam1, st5_C_esperaEnviaTam1, st6_C_enviaTam2, st7_C_esperaEnviaTam2,
								--- Comando P
					    st8_P_esperaTam1, st9_P_esperaTam2, st10_P_recibeDatos, st11_P_escribeMI, st12_P_enviaRespC, 
						st13_P_esperaEnviaRespC,
								--- Comando V
						st14_V_esperaTam1, st15_V_esperaTam2, st16_V_recibeDatos, st17_V_verificaMI, st18_V_recibeResto, 
						st19_V_enviaRespE, st20_V_esperaEnviaRespE, st21_V_enviaRespC, st22_V_esperaEnviaRespC); 
   -- FF de la variable de estados y señal para el estado siguiente							  
   signal state, next_state : state_type; 

	-- registro que almacena la cantidad de datos recibidos por el UART (16 its)
	signal cantMSBLSB : std_logic_vector (15 downto 0);
	signal nextCantMSB, nextCantLSB : std_logic_vector (7 downto 0);
	signal decCantMSBLSB, cargaCantMSB, cargaCantLSB : std_logic;
	-- registro que almacena la palabra recibida por el UART de cara al MIPS (32 bits)
	-- se accede por bytes en función de contBytes
	type pal32bits is array (3 downto 0) of std_logic_vector (7 downto 0);
	signal pal : pal32bits; -- para acceder pal(3), pal(2)... Para convertir std_logic_vector a entero to_integer(unsgined())
	signal nextPal : pal32bits;
	signal cargaPal : std_logic;
	-- registro que cuenta los bytes de la palabra anterior ( 2 bits)
	signal contBytes : std_logic_vector (1 downto 0);
	signal rstContBytes, incContBytes : std_logic;
	-- registro que almacena la posición de la memoria de instrucciones del MIPS que será escrito
	signal dirMIreg : std_logic_vector (NUM_BITS_MEMORIA_INSTRUCCIONES-1 downto 0);
	signal rstDirMI, incDirMI : std_logic;
--	signal numeroPosicionesMI : std_logic_vector (15 downto 0) := X"00FF";	-- Cantidad de posiciones (palabras) de la memoria del MIPS
	constant numeroPosicionesMI : std_logic_vector (15 downto 0) := std_logic_vector(to_unsigned(2**NUM_BITS_MEMORIA_INSTRUCCIONES, 16));	-- Cantidad de posiciones (palabras) de la memoria del MIPS
begin
	-- Camino de los datos
	contadorBytes : process (rstContBytes, incContBytes, clk)
	begin
		if clk'event and clk = '1' then
			if rstContBytes = '1' then
				contBytes <= "00";
			elsif incContBytes = '1' then
				contBytes <= std_logic_vector(unsigned(contBytes) + 1);
			end if;
		end if;
	end process;

	contadorDirMI : process (rstDirMI, incDirMI, clk)
	begin
		if clk'event and clk = '1' then
			if rstDirMI = '1' then
				dirMIreg <= (others => '0');
			elsif incDirMI = '1' then
				dirMIreg <= std_logic_vector(unsigned(dirMIreg) + 1);
			end if;
		end if;
	end process;
	-- conectamos dirMIreg a la salida de direcciones
	DirMI <= dirMIreg;
	
	cantidadMSBLSB : process (decCantMSBLSB, cargaCantMSB, cargaCantLSB, clk)
	begin
		if clk'event and clk = '1' then
			if decCantMSBLSB = '1' then
				cantMSBLSB <= std_logic_vector(unsigned(cantMSBLSB) - 1);
			elsif cargaCantMSB = '1' then
				cantMSBLSB <= nextCantMSB & cantMSBLSB(7 downto 0);
			elsif cargaCantLSB = '1' then
				cantMSBLSB <= cantMSBLSB(15 downto 8) & nextCantLSB;
			end if;
		end if;
	end process;

	palabraASerEscritaEnMI : process (cargaPal, clk)
	begin
		if clk'event and clk = '1' then
			if cargaPal = '1' then
				pal <= nextPal;
			end if;
		end if;
	end process;
	dataAMI <= (pal(0) & pal(1) & pal(2) & pal(3));

	-- Fin Camino de los datos
	
	-- Control
	estados : process (next_state, clk)
	begin
		if clk'event and clk = '1' then
			state <= next_state;
		end if;
	end process;
	
	-- circuito de salida Mealy y Moore
   OUTPUT_DECODE: process (state, atn, readyRx, rxData, pal, cantMSBLSB, contBytes)
   begin
		-- salidas por defecto para evitar latches
		resetTx <= '0';	-- no reset del UART TX
		readyTx <= '0';	-- No se transmite por el UART TX
		txData  <= X"00";	-- Dato a transmitir por UART TX es 00000000
		resetRx <= '0';	-- no reset del UART RX
		rstMIPS <= '0';	-- no hacemos reset al MIPS
		writeMI <= '0';	-- no escribimos en la MI del MIPS
		rstDirMI <= '0';	-- no reset a Direccion de MI del MIPS
		incDirMI <= '0';	-- no incrementa la dirección del MI del MIPS
		rstContBytes <= '0';	-- no reset a ContBytes 
		incContBytes <= '0';	-- no se incrementa ContBytes 
		cargaCantLSB <= '0';	-- no cargamos CantMSBLSB
		cargaCantMSB <= '0';
		decCantMSBLSB <= '0';	-- no decrementamos CantMSBLSB
		-- CantMSBLSB conserva su valor por defecto
		nextCantMSB <= CantMSBLSB(15 downto 8);
		nextCantLSB <= CantMSBLSB(7 downto 0);
		-- pal conserva su valor por defecto
		cargaPal <= '0';
		nextPal(0) <= pal(0);
		nextPal(1) <= pal(1);
		nextPal(2) <= pal(2);
		nextPal(3) <= pal(3);
		
      case (state) is
			---------- Espera Comando
         when st1_esperaAtn0 =>
				resetTx <= '1';	-- reset al UART
				resetRx <= '1';
				rstDirMI <= '1';	-- reset a Direccion de MI del MIPS
         when st2_esperaAtn1 =>
				resetTx <= '1';	-- reset al UART
				resetRx <= '1';
            if atn = '1' then
               resetTx <= '0';	-- esperamos recibir y transmitir datos
					resetRx <= '0';
            end if;
         when st3_esperaComando =>
				-- no hay salidas asociadas a este estado
				
			--------- Comando C
			when st4_C_enviaTam1 =>
				txData <= numeroPosicionesMI(15 downto 8);	-- enviamos MSB del tamaño
				readyTx <= '1';
			when st5_C_esperaEnviaTam1 =>	-- no hace nada, espera envio
				txData <= numeroPosicionesMI(15 downto 8);
			when st6_C_enviaTam2 =>
				txData <= numeroPosicionesMI(7 downto 0);	-- enviamos LSB del tamaño
				readyTx <= '1';
			when st7_C_esperaEnviaTam2 =>	-- no hace nada, espera envio
				txData <= numeroPosicionesMI(7 downto 0);
			
			--------- Comando P
			when st8_P_esperaTam1 =>
				if readyRx = '1' then
					cargaCantMSB <= '1';
					nextCantMSB <= rxData;
				end if;
			when st9_P_esperaTam2 =>
				if readyRx = '1' then
					cargaCantLSB <= '1';
					nextCantLSB <= rxData;
					rstDirMI <= '1';	-- Direccion de MI del MIPS es 0
					rstContBytes <= '1';	-- Contador de bytes recibidos es 0
				end if;
			when st10_P_recibeDatos =>
				rstMIPS <= '1';
				if readyRx = '1' then
					cargaPal <= '1';
					nextPal(to_integer(unsigned(contBytes))) <= rxData;
					incContBytes <= '1';
					decCantMSBLSB <= '1';
				end if;
			when st11_P_escribeMI =>
				writeMI <= '1';
				incDirMI <= '1';
				rstMIPS <= '1';
			when st12_P_enviaRespC =>
				txData <= std_logic_vector(to_unsigned(character'pos('c'), 8));
				readyTx <= '1';	-- transmitimos respuesta
			when st13_P_esperaEnviaRespC =>
				-- no hay salidas asociadas a este estado
			
			--------- Comando V
			when st14_V_esperaTam1 =>
				if readyRx = '1' then
					cargaCantMSB <= '1';
					nextCantMSB <= rxData;
				end if;
			when st15_V_esperaTam2=>
				if readyRx = '1' then
					cargaCantLSB <= '1';
					nextCantLSB <= rxData;
					rstDirMI <= '1';	-- Direccion de MI del MIPS es 0
					rstContBytes <= '1';	-- Contador de bytes recibidos es 0
				end if;
			when st16_V_recibeDatos =>
				if readyRx = '1' then
					cargaPal <= '1';
					nextPal(to_integer(unsigned(contBytes))) <= rxData;
					incContBytes <= '1';
					decCantMSBLSB <= '1';
				end if;
			when st17_V_verificaMI=>
				incDirMI <= '1';
			when st18_V_recibeResto =>
				if readyRx = '1' then
					decCantMSBLSB <= '1';
				end if;
			when st19_V_enviaRespE =>
				txData <= std_logic_vector(to_unsigned(character'pos('e'), 8));
				readyTx <= '1';	-- transmitimos respuesta
			when st20_V_esperaEnviaRespE =>
			when st21_V_enviaRespC =>
				txData <= std_logic_vector(to_unsigned(character'pos('c'), 8));
				readyTx <= '1';	-- transmitimos respuesta
			when st22_V_esperaEnviaRespC =>
				-- no hay salidas asociadas a este estado
      end case;      
   end process;
 
	-- circuito del estado siguiente
   NEXT_STATE_DECODE: process (state, DataDeMI, atn, enviado, readyRx, rxData, contBytes, cantMSBLSB, pal)
   begin
      next_state <= state;  -- por defecto en el mismo estado

      case (state) is
			---------- Espera Comando
         when st1_esperaAtn0 =>
            if atn = '0' then
               next_state <= st2_esperaAtn1;
            end if;
         when st2_esperaAtn1 =>
            if atn = '1' then
               next_state <= st3_esperaComando;
            end if;
         when st3_esperaComando =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' then
					if rxData = std_logic_vector(to_unsigned(character'pos('C'), 8)) then
						next_state <= st4_C_enviaTam1;
					elsif rxData = std_logic_vector(to_unsigned(character'pos('P'), 8)) then
						next_state <= st8_P_esperaTam1;
					elsif rxData = std_logic_vector(to_unsigned(character'pos('V'), 8)) then
						next_state <= st14_V_esperaTam1;
					end if;
            end if;
			--------- Comando C
			when st4_C_enviaTam1 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				else
					next_state <= st5_C_esperaEnviaTam1;
				end if;
			when st5_C_esperaEnviaTam1 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif enviado = '1' then
					next_state <= st6_C_enviaTam2;
				end if;
			when st6_C_enviaTam2 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				else
					next_state <= st7_C_esperaEnviaTam2;
				end if;
			when st7_C_esperaEnviaTam2 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif enviado = '1' then
					next_state <= st1_esperaAtn0;	-- volvemos al estado inicial
				end if;
			--------- Comando P
			when st8_P_esperaTam1 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' then
					next_state <= st9_P_esperaTam2;
				end if;
			when st9_P_esperaTam2 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' then
					next_state <= st10_P_recibeDatos;
				end if;
			when st10_P_recibeDatos =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' and contBytes = "11" then
					next_state <= st11_P_escribeMI;	-- escribe en memoria
				end if;
			when st11_P_escribeMI =>
				if cantMSBLSB = X"0000" then
					next_state <= st12_P_enviaRespC;
				else
					next_state <= st10_P_recibeDatos;
				end if;
			when st12_P_enviaRespC =>
				next_state <= st13_P_esperaEnviaRespC;
			when st13_P_esperaEnviaRespC =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif enviado = '1' then
					next_state <= st1_esperaAtn0;
				end if;
			--------- Comando V
			when st14_V_esperaTam1 =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' then
					next_state <= st15_V_esperaTam2;
				end if;
			when st15_V_esperaTam2=>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' then
					next_state <= st16_V_recibeDatos;
				end if;
			when st16_V_recibeDatos =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' and contBytes = "11" then
					next_state <= st17_V_verificaMI;
				end if;
			when st17_V_verificaMI=>
				if dataDeMI /= (pal(0) & pal(1) & pal(2) & pal(3)) then
					if cantMSBLSB = X"0000" then
						next_state <= st19_V_enviaRespE;
					else
						next_state <= st18_V_recibeResto;
					end if;
				elsif cantMSBLSB = X"0000" then
					next_state <= st21_V_enviaRespC;
				else
					next_state <= st16_V_recibeDatos;
				end if;
			when st18_V_recibeResto =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif readyRx = '1' and cantMSBLSB = X"0001" then
					next_state <= st19_V_enviaRespE;
				end if;
			when st19_V_enviaRespE =>
				next_state <= st20_V_esperaEnviaRespE;
			when st20_V_esperaEnviaRespE =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif enviado = '1' then
					next_state <= st1_esperaAtn0;
				end if;
			when st21_V_enviaRespC =>
				next_state <= st22_V_esperaEnviaRespC;
			when st22_V_esperaEnviaRespC =>
				if atn = '0' then
					next_state <= st2_esperaAtn1;	-- reiniciamos esta máquina
				elsif enviado = '1' then
					next_state <= st1_esperaAtn0;
				end if;
				
			--------- Estado por defecto
         when others =>
            next_state <= st1_esperaAtn0;
      end case;      
   end process;

end Behavioral;

