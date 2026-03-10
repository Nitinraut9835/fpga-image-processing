-- ============================================================
-- FILE:    rgb_to_gray.vhd
-- DESC:    RGB to Grayscale converter
-- FORMULA: Gray = (306*R + 601*G + 117*B) >> 10
--          Approximates: 0.299R + 0.587G + 0.114B
-- LATENCY: 3 clock cycles (pipelined)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rgb_to_gray is
    Port (
        clk       : in  STD_LOGIC;
        r_in      : in  STD_LOGIC_VECTOR(7 downto 0);
        g_in      : in  STD_LOGIC_VECTOR(7 downto 0);
        b_in      : in  STD_LOGIC_VECTOR(7 downto 0);
        valid_in  : in  STD_LOGIC;
        gray_out  : out STD_LOGIC_VECTOR(7 downto 0);
        valid_out : out STD_LOGIC
    );
end rgb_to_gray;

architecture rtl of rgb_to_gray is
    signal r_prod   : unsigned(17 downto 0) := (others=>'0');
    signal g_prod   : unsigned(17 downto 0) := (others=>'0');
    signal b_prod   : unsigned(17 downto 0) := (others=>'0');
    signal valid_s1 : std_logic := '0';
    signal sum_s2   : unsigned(19 downto 0) := (others=>'0');
    signal valid_s2 : std_logic := '0';
    signal valid_s3 : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Stage 1: multiply
            r_prod   <= unsigned(r_in) * to_unsigned(306, 10);
            g_prod   <= unsigned(g_in) * to_unsigned(601, 10);
            b_prod   <= unsigned(b_in) * to_unsigned(117, 10);
            valid_s1 <= valid_in;

            -- Stage 2: add
            sum_s2   <= resize(r_prod, 20) + resize(g_prod, 20)
                        + resize(b_prod, 20);
            valid_s2 <= valid_s1;

            -- Stage 3: shift right 10 bits
            gray_out  <= std_logic_vector(sum_s2(17 downto 10));
            valid_s3  <= valid_s2;
        end if;
    end process;

    valid_out <= valid_s3;
end rtl;
