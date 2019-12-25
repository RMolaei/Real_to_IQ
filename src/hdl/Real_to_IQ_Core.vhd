-- In the Name of ALLAH
-- Noon, By the pen and by what they inscribe
----------------------------------------------------------------------------------
-- Company: Yasin Developers Engineering
-- Engineer: Reza Molaei
-- 
-- Create Date: 12/25/2019 02:33:13 PM
-- Design Name: 
-- Module Name: Real_to_IQ_Core - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Real_to_IQ_Core is
    generic(RealSignalLength : integer := 16;
        ProductPartslength : integer := 32);
    Port (Clock, Enable : in std_logic;
        RealSignal : in std_logic_vector(RealSignalLength-1 downto 0);
        InPhasePart, QuadraturePart : out std_logic_vector(ProductPartslength-1 downto 0));
end Real_to_IQ_Core;

architecture Behavioral of Real_to_IQ_Core is
    signal en : std_logic;
begin
    en <= enable;
end Behavioral;