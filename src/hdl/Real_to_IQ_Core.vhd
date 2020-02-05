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
    generic (RealSignalLength : integer := 16;
        ProductPartslength : integer := 40;
        FirOutputProductLenght : integer := 40);
    Port (Clock, Enable : in std_logic;
        --
	sAXIsDataTvalid : in std_logic;
	sAXIsDataTready : out std_logic;
	RealSignal : in std_logic_vector(RealSignalLength-1 downto 0);
	--
	mAXIsDataTvalid : out std_logic;
	mAXIsDataTready : in std_logic;
	InPhasePart, QuadraturePart : out std_logic_vector(ProductPartslength-1 downto 0)
	--
	);
end Real_to_IQ_Core;
----------------------------------------------------------------------------------
-- I)    Real input signal spectrum:        x[n] <=> X(exp(j*w))
--    __    ____    ____    ____  |  ____    ____    ____    __
--      \__/    |__|    \__/    |_|_|    \__/    |__|    \__/      One Real Stream x[m], K Sample/Second
--
-- II)    Theorem:          exp(j*k*m)*x[m] <=> X(j*(w-k))
-- If: k=-pi/2  then  exp(-j*(pi/2)*m)*x[m] <=> X(j*(w+pi/2))  While  exp(-j*(pi/2)*m)*x[m]=cos((pi/2)m)*x[m]-j*sin((pi/2)m)*x[m]
--      ____    ____    ____    __|__    ____    ____    ____  
--    _/    |__|    \__/    |__| _|_ \__/    |__|    \__/    |_    Two In Phase (xi[m]) and Quadrature (xq[m]) Stream, K Sample/Second
--
-- III)    Low Pass Filtering:        fcut=pi/2
--             ______          ___|___          ______         
--    ________|      |________|  _|_  |________|      |________
--
--              ____            __|__            ____          
--    _________|    \__________| _|_ \__________|    \_________    Two In Phase (xi_lpf[m]) and Quadrature (xq_lpf[m]) Stream, K Sample/Second
--
-- IV)    Decimating:        x[Mn] <=> (1/M)*X(exp(j(w/M)))
--            ________        ____|____        ________        
--           |        \      |    |    \      |        \       
--    _______|         \_____|   _|_    \_____|         \______    Two In Phase (xi_d[n]) and Quadrature (xq_d[n]) Stream, K/2 Sample/Second
----------------------------------------------------------------------------------
architecture Behavioral of Real_to_IQ_Core is
    COMPONENT fir_compiler_LowPass
      PORT (
        aclk : IN STD_LOGIC;
        aclken : IN STD_LOGIC;
        s_axis_data_tvalid : IN STD_LOGIC;
        s_axis_data_tready : OUT STD_LOGIC;
        s_axis_data_tdata : IN STD_LOGIC_VECTOR;
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tready : IN STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR
      );
    END COMPONENT;
    signal en : std_logic;
    signal real_signal, real_signal_reg : std_logic_vector(RealSignal'length-1 downto 0);
    signal real_signal_reg_p, real_signal_reg_n : std_logic_vector(RealSignal'length-1 downto 0);
    signal x_in_phase, x_quadrature : std_logic_vector(RealSignal'length-1 downto 0);
    signal s_axis_data_tvalid, s_axis_data_tready, m_axis_data_tvalid, m_axis_data_tready : std_logic;
    signal s_axis_data_tdata : std_logic_vector(2*RealSignalLength-1 downto 0);
    signal m_axis_data_tdata : std_logic_vector(2*FirOutputProductLenght-1 downto 0);
    signal StateCounter : std_logic_vector(1 downto 0);
begin
    en <= enable;
    s_axis_data_tvalid <= sAXIsDataTvalid;
    sAXIsDataTready <= s_axis_data_tready;
    real_signal <= RealSignal;
    mAXIsDataTvalid <= m_axis_data_tvalid;
    m_axis_data_tready <= mAXIsDataTready;
    InPhasePart <= m_axis_data_tdata(FirOutputProductLenght-1 downto 0);
    QuadraturePart <= m_axis_data_tdata(2*FirOutputProductLenght-1 downto FirOutputProductLenght);
    process(Clock)
    begin
        if(rising_edge(Clock)) then
            if(en='1' and s_axis_data_tvalid='1' and s_axis_data_tready='1') then
                real_signal_reg <= real_signal;
            end if;
        end if;
    end process;
    ----------------------------------------------------------------------------------
    --m                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  
    --                          ___         ___         ___         ___         ___         ___         ___         ___         _
    --                             \       /   \       /   \       /   \       /   \       /   \       /   \       /   \       / 
    --cos((pi/2)*m)                 \     /     \     /     \     /     \     /     \     /     \     /     \     /     \     /  
    --                               \___/       \___/       \___/       \___/       \___/       \___/       \___/       \___/   
    --                                   ___         ___         ___         ___         ___         ___         ___         ___ 
    --                          \       /   \       /   \       /   \       /   \       /   \       /   \       /   \       /   \
    --(-1)*sin((pi/2)*m)         \     /     \     /     \     /     \     /     \     /     \     /     \     /     \     /     
    --                            \___/       \___/       \___/       \___/       \___/       \___/       \___/       \___/      

    --StateCounter              00   01   10   11     00   01   10   11     00   01   10   11   00
    --cos((pi/2)*m)              1    0   -1    0      1    0   -1    0      1    0   -1    0    1
    --(-1)*sin((pi/2)*m)         0   -1    0    1      0   -1    0    1      0   -1    0    1    0
    ----------------------------------------------------------------------------------
    process(Clock)
    begin
        if(rising_edge(Clock)) then
            if(en='1' and s_axis_data_tvalid='1' and s_axis_data_tready='1') then
                real_signal_reg_p <= real_signal_reg;
                real_signal_reg_n <= std_logic_vector(-signed(real_signal_reg));
            end if;
        end if;
    end process;
    process(Clock)
    begin
        if(rising_edge(Clock)) then
            if(en='1' and s_axis_data_tvalid='1' and s_axis_data_tready='1') then
                StateCounter <= std_logic_vector(unsigned(StateCounter)+1);
            end if;
        end if;
    end process;
    with StateCounter select
        x_in_phase <= real_signal_reg_p when    "00",
                      real_signal_reg_n when    "10",
                      (others => '0') when    others;
    with StateCounter select
        x_quadrature <= real_signal_reg_n when    "01",
                        real_signal_reg_p when    "11",
                        (others => '0') when    others;
    ----------------------------------------------------------------------------------
    process(Clock)
    begin
        if(rising_edge(Clock)) then
            if(en='1' and s_axis_data_tvalid='1' and s_axis_data_tready='1') then
                s_axis_data_tdata(real_signal_reg'length-1 downto 0) <= x_in_phase;
                s_axis_data_tdata(2*real_signal_reg'length-1 downto real_signal_reg'length) <= x_quadrature;
            end if;
        end if;
    end process;
    fir_compiler_LowPass_instance : fir_compiler_LowPass
          PORT MAP (
            aclk => Clock,
            aclken => en,
            s_axis_data_tvalid => s_axis_data_tvalid,
            s_axis_data_tready => s_axis_data_tready,
            s_axis_data_tdata => s_axis_data_tdata,
            m_axis_data_tvalid => m_axis_data_tvalid,
            m_axis_data_tready => m_axis_data_tready,
            m_axis_data_tdata => m_axis_data_tdata
          );
end Behavioral;
