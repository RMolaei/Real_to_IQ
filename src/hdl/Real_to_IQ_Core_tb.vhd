-- In the Name of ALLAH
-- Noon, By the pen and by what they inscribe
----------------------------------------------------------------------------------
-- Company: Yasin Developers Engineering
-- Engineer: Reza Molaei
-- 
-- Create Date: 01/08/2020 01:38:20 PM
-- Design Name: 
-- Module Name: Real_to_IQ_Core_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Real_to_IQ_Core_tb is
--  Port ( );
end Real_to_IQ_Core_tb;

architecture Behavioral of Real_to_IQ_Core_tb is
    shared variable T : real := 2.0e-9;
    shared variable T_Clock : time := 2.0 ns;
    shared variable SinValuLength : integer := 16;
    signal Clock : std_logic := '0';
    signal SinValu : std_logic_vector(SinValuLength-1 downto 0);
begin
    Clock <= not Clock after 0.5*T_Clock;
    process(Clock)
		variable n : real :=0.0;
		variable w : real :=10001.0;
		variable valu : integer;
    begin
		if(rising_edge(Clock)) then
			valu := integer(sin(w*T*n)*10000.0);
			n := n+1.0;
			if((0.125*n*T)>((2.0*3.14)/w)) then
				w := w*2.1;
				n := 0.0;
			end if;
			if(2*T>((2.0*3.14)/w)) then
				w := 10001.0;
			end if;
			SinValu <= std_logic_vector(to_signed(valu,SinValuLength));
		end if;
    end process;
end Behavioral;