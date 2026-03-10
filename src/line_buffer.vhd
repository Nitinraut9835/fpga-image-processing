-- ============================================================
-- FILE:    line_buffer.vhd
-- DESC:    3-line circular buffer producing 3x3 pixel window
--          Used as input to Sobel edge detector
-- MEMORY:  2 x LINE_W x 8 bits Block RAM
-- LATENCY: 2 clock cycles
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity line_buffer is
    generic (LINE_W : integer := 800);
    Port (
        clk       : in  STD_LOGIC;
        din       : in  STD_LOGIC_VECTOR(7 downto 0);
        valid_in  : in  STD_LOGIC;
        p00 : out STD_LOGIC_VECTOR(7 downto 0);
        p01 : out STD_LOGIC_VECTOR(7 downto 0);
        p02 : out STD_LOGIC_VECTOR(7 downto 0);
        p10 : out STD_LOGIC_VECTOR(7 downto 0);
        p11 : out STD_LOGIC_VECTOR(7 downto 0);
        p12 : out STD_LOGIC_VECTOR(7 downto 0);
        p20 : out STD_LOGIC_VECTOR(7 downto 0);
        p21 : out STD_LOGIC_VECTOR(7 downto 0);
        p22 : out STD_LOGIC_VECTOR(7 downto 0);
        valid_out : out STD_LOGIC
    );
end line_buffer;

architecture rtl of line_buffer is
    type line_t is array (0 to LINE_W-1) of std_logic_vector(7 downto 0);
    signal buf0 : line_t := (others => (others => '0'));
    signal buf1 : line_t := (others => (others => '0'));
    signal ptr  : integer range 0 to LINE_W-1 := 0;

    signal r0_a, r0_b, r0_c : std_logic_vector(7 downto 0) := (others=>'0');
    signal r1_a, r1_b, r1_c : std_logic_vector(7 downto 0) := (others=>'0');
    signal r2_a, r2_b, r2_c : std_logic_vector(7 downto 0) := (others=>'0');
    signal vld_d, vld_dd : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if valid_in = '1' then
                r0_c <= buf0(ptr);
                r1_c <= buf1(ptr);
                r2_c <= din;
                buf0(ptr) <= buf1(ptr);
                buf1(ptr) <= din;
                if ptr = LINE_W - 1 then ptr <= 0;
                else ptr <= ptr + 1; end if;
            end if;
            r0_a <= r0_b;  r0_b <= r0_c;
            r1_a <= r1_b;  r1_b <= r1_c;
            r2_a <= r2_b;  r2_b <= r2_c;
            vld_d  <= valid_in;
            vld_dd <= vld_d;
        end if;
    end process;

    p00<=r0_a; p01<=r0_b; p02<=r0_c;
    p10<=r1_a; p11<=r1_b; p12<=r1_c;
    p20<=r2_a; p21<=r2_b; p22<=r2_c;
    valid_out <= vld_dd;
end rtl;
