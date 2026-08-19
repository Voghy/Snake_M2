----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:36:22 06/14/2017 
-- Design Name: 
-- Module Name:    lcd - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd is
    Port ( -- Interfaz con el MIPS
		     dataOut : in  STD_LOGIC_VECTOR (8 downto 0);
           memWrite : in  STD_LOGIC;
           cs : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  -- Interfaz con el LCD
           E : out  STD_LOGIC;
           RS : out  STD_LOGIC;
           RW : out  STD_LOGIC;
           DB: out  STD_LOGIC_VECTOR (7 downto 0));
end lcd;

architecture Behavioral of lcd is

-- señales internas para interconectar módulos
--signal DBTmp : STD_LOGIC_VECTOR(9 downto 0);

--signal dataInTmp : STD_LOGIC_VECTOR(8 downto 0) := "000000000";

signal enableWrite : STD_LOGIC := '0';
signal dataOutWrite : STD_LOGIC := '0';

signal enableWrite_i : STD_LOGIC := '0';
signal E_i : STD_LOGIC := '0';

type state_type is (EsperaCS, EsperaAntesE1, EsperaAntesE2, ActivaE, EsperaE1, 
                    EsperaE2, EsperaE3, EsperaE4, EsperaE5, EsperaE6, EsperaE7, 
						  EsperaE8, EsperaE9, EsperaE10, EsperaE11, EsperaFinal); 
signal state, next_state : state_type; 

begin

dataOutWrite <= '1' when memWrite = '1' and CS = '1' and enableWrite = '1' else 
                '0';

regDataOut: process (clk)
begin  
   if (clk'event and clk = '1') then
		if (dataOutWrite = '1') then
			DB <= dataOut(7 downto 0);
			RS <= dataOut(8);
		end if;
   end if;
end process;

-- solo se puede escribir en el LCD
RW <= '0';

--------------------------------------------------
-- Secuencial de control
--------------------------------------------------
control: process (clk)
begin
   if (clk'event and clk = '1') then
      if (reset = '1') then
         state <= EsperaCS;
			-- Salidas
			enableWrite <= '1';
         E <= '0';
		else
			state <= next_state;
			
         enableWrite <= enableWrite_i;
         E <= E_i;
      end if;        
   end if;
end process;

--MOORE State-Machine - Outputs based on state only
CONTROL_OUTPUT_DECODE: process (state)
begin
	--insert statements to decode internal output signals
	--below is simple example
	if state = EsperaCS then
		-- CS = 0, no hace nada, permite escritura
		enableWrite_i <= '1';
		E_i <= '0';
	elsif state = EsperaAntesE1 then
		-- el MIPS escribió un valor que se debe enviar al LCD, y ya no puede volver a escribir
		-- esperamos un ciclo de dos
		enableWrite_i <= '1';	-- el clock de este dispositivo es el doble del MIPS.
		E_i <= '0';
	elsif state = EsperaAntesE2 then
		-- esperamos dos de dos ciclos
		enableWrite_i <= '0';
		E_i <= '0';
	elsif state = ActivaE then
		-- activa E
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE1 then
		-- esperamos uno de doce ciclos
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE2 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE3 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE4 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE5 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE6 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE7 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE8 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE9 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE10 then
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaE11 then
		-- se escribe dataIn
		enableWrite_i <= '0';
		E_i <= '1';
	elsif state = EsperaFinal then
		-- desactiva E
		enableWrite_i <= '0';
		E_i <= '0';
	end if;
end process;

CONTROL_NEXT_STATE_DECODE: process (state, memWrite, CS)
begin
	--declare default state for next_state to avoid latches
	next_state <= state;  --default is to stay in current state
	--insert statements to decode next_state
	--below is a simple example
	case (state) is
		when EsperaCS =>
			if CS = '1' and memWrite = '1' then
				next_state <= EsperaAntesE1;
			else 
				next_state <= EsperaCS;
			end if;
		when EsperaAntesE1 =>
			next_state <= EsperaAntesE2;
		when EsperaAntesE2 =>
			next_state <= ActivaE;
		when ActivaE =>
			next_state <= EsperaE1;
		when EsperaE1 =>
			next_state <= EsperaE2;
		when EsperaE2 =>
			next_state <= EsperaE3;
		when EsperaE3 =>
			next_state <= EsperaE4;
		when EsperaE4 =>
			next_state <= EsperaE5;
		when EsperaE5 =>
			next_state <= EsperaE6;
		when EsperaE6 =>
			next_state <= EsperaE7;
		when EsperaE7 =>
			next_state <= EsperaE8;
		when EsperaE8 =>
			next_state <= EsperaE9;
		when EsperaE9 =>
			next_state <= EsperaE10;
		when EsperaE10 =>
			next_state <= EsperaE11;
		when EsperaE11 =>
			next_state <= EsperaFinal;
		when EsperaFinal =>
			next_state <= EsperaCS;
		when others =>
			next_state <= EsperaCS;
	end case;      
end process;

end Behavioral;

