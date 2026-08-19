----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:09:45 03/11/2020 
-- Design Name: 
-- Module Name:    uart_rx - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rx is
    Port ( rx       : in  STD_LOGIC;
			  clk      : in  STD_LOGIC;
			  resetRx  : in  STD_LOGIC;
           rxdata   : out STD_LOGIC_VECTOR (7 downto 0);
           readyRx  : out STD_LOGIC);
end uart_rx;

architecture Behavioral of uart_rx is
	-- número de ciclos a 25 MHz para alcanzar medio bit y un bit a 19200 bps
	constant HALF_BIT_CONST	:STD_LOGIC_VECTOR (10 downto 0) := "01010001011"; --X"28B";
	constant FULL_BIT_CONST :STD_LOGIC_VECTOR (10 downto 0) := "10100010110"; --X"516";
	
	signal s_reg : STD_LOGIC_VECTOR (7 downto 0);	-- registro de corrimiento
	signal corr : STD_LOGIC;	-- control del registro de corrimiento
	signal cont_ciclos : STD_LOGIC_VECTOR (10 downto 0);	-- contador de ciclos de reloj
	signal hab_cont_ciclos, cera_cont_ciclos : STD_LOGIC;	-- controles contador ciclos de reloj
	signal cont_bits : STD_LOGIC_VECTOR (3 downto 0);	-- contador de bits recibidos
	signal hab_cont_bits, cera_cont_bits : STD_LOGIC;	-- controles contador de bits recibidos
	-- máquina de estados de control
   type state_type is (st1_idle, st2_start, st3_datos, st4_stop); 
   signal state, next_state : state_type; 
	-- salida de los comparadores
	signal half_bit, full_bit, ocho_bits_rec : STD_LOGIC;
begin

-----------------------------------------------------------
-- Camino de los datos
-----------------------------------------------------------
	-- registro de corrimiento
	shift_register : process (clk, rx, corr, resetRx)
	begin
		if clk'event and clk = '1' then
			if resetRx = '1' then
				s_reg <= "00000000";
			elsif corr = '1' then
				s_reg <= rx & s_reg(7 downto 1);
			end if;
		end if;
	end process;
	
	-- contador de ciclos de reloj para bits por segundo
	contador_ciclos : process (clk, hab_cont_ciclos, cera_cont_ciclos)
	begin
		if clk'event and clk = '1' then
			if cera_cont_ciclos = '1' then
				cont_ciclos <= (others => '0');
			elsif hab_cont_ciclos = '1' then
				cont_ciclos <= std_logic_vector(unsigned(cont_ciclos) + 1);
			end if;
		end if;
	end process;

	-- contador de ciclos de reloj bits recibidos
	contador_bits : process (clk, hab_cont_bits, cera_cont_bits)
	begin
		if clk'event and clk = '1' then
			if cera_cont_bits = '1' then
				cont_bits <= (others => '0');
			elsif hab_cont_bits = '1' then
				cont_bits <= std_logic_vector(unsigned(cont_bits) + 1);
			end if;
		end if;
	end process;

-----------------------------------------------------------
-- Fin Camino de los datos
-----------------------------------------------------------

-----------------------------------------------------------
-- Control
-----------------------------------------------------------
 
   SYNC_PROC: process (clk, resetRx)
   begin
      if (clk'event and clk = '1') then
         if (resetRx = '1') then
            state <= st1_idle;
         else
            state <= next_state;
         end if;        
      end if;
   end process;
 
   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, half_bit, full_bit, ocho_bits_rec)
   begin
		-- por defecto ceramos los contadores y no contamos
		hab_cont_bits    <= '0';
		cera_cont_bits   <= '1';
		hab_cont_ciclos  <= '0';
		cera_cont_ciclos <= '1';
		readyRx          <= '0';
		corr             <= '0';

      case (state) is
			when st1_idle =>
				cera_cont_bits   <= '1';
				cera_cont_ciclos <= '1';
				readyRx          <= '0';
         when st2_start =>
				-- contamos ciclos
				hab_cont_ciclos  <= '1';
				cera_cont_ciclos <= '0';
            if half_bit = '1' then
					-- ceramos ambos contadores
					cera_cont_bits   <= '1';
					cera_cont_ciclos <= '1';
            end if;
         when st3_datos =>
				hab_cont_ciclos  <= '1';
				cera_cont_ciclos <= '0';
				cera_cont_bits   <= '0';
            if ocho_bits_rec = '0' and full_bit = '1' then
					-- ceramos contador de ciclos y cuenta contador de bits
					--cera_cont_bits   <= '0';
					hab_cont_bits    <= '1';
					cera_cont_ciclos <= '1';
					corr <= '1';
            end if;
         when st4_stop =>
				-- contamos ciclos
				hab_cont_ciclos  <= '1';
				cera_cont_ciclos <= '0';
            if full_bit = '1' then
					-- activamos ready
					readyRx <= '1';
            end if;
         when others =>

      end case;      
   end process;
 
   NEXT_STATE_DECODE: process (state, half_bit, full_bit, ocho_bits_rec, rx)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      case (state) is
         when st1_idle =>
            if rx = '0' then
               next_state <= st2_start;
            end if;
         when st2_start =>
            if half_bit = '1' then
               next_state <= st3_datos;
            end if;
         when st3_datos =>
				if ocho_bits_rec = '1' then
					next_state <= st4_stop;
				end if;
         when st4_stop =>
				if full_bit = '1' then
					next_state <= st1_idle;
				end if;
         when others =>
            next_state <= st1_idle;
      end case;      
   end process;

	-- comparadores
	half_bit <= '1' when cont_ciclos = HALF_BIT_CONST else '0';
	full_bit <= '1' when cont_ciclos = FULL_BIT_CONST else '0';
	ocho_bits_rec <= '1' when cont_bits = "1000" else '0';
	
	rxdata <= s_reg;	-- salida de datos, contiene un dato válido cuando ready es 1
				
-----------------------------------------------------------
-- Fin Control
-----------------------------------------------------------

end Behavioral;

