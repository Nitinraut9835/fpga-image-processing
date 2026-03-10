-- ============================================================
-- FILE:    sobel.vhd
-- DESC:    Sobel edge detector on 3x3 pixel window
-- KERNELS: Gx = [-1 0 +1; -2 0 +2; -1 0 +1]
--          Gy = [-1 -2 -1; 0 0 0; +1 +2 +1]
-- MAGNITUDE: |Gx| + |Gy| (Manhattan approximation)
-- LATENCY: 3 clock cycles (pipelined)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sobel is
    Port (
        clk       : in  STD_LOGIC;
        p00 : in STD_LOGIC_VECTOR(7 downto 0);
        p01 : in STD_LOGIC_VECTOR(7 downto 0);
        p02 : in STD_LOGIC_VECTOR(7 downto 0);
        p10 : in STD_LOGIC_VECTOR(7 downto 0);
        p11 : in STD_LOGIC_VECTOR(7 downto 0);
        p12 : in STD_LOGIC_VECTOR(7 downto 0);
        p20 : in STD_LOGIC_VECTOR(7 downto 0);
        p21 : in STD_LOGIC_VECTOR(7 downto 0);
        p22 : in STD_LOGIC_VECTOR(7 downto 0);
        valid_in  : in  STD_LOGIC;
        edge_out  : out STD_LOGIC_VECTOR(7 downto 0);
        valid_out : out STD_LOGIC
    );
end sobel;

architecture rtl of sobel is
    signal s00,s01,s02 : signed(8 downto 0);
    signal s10,s12     : signed(8 downto 0);
    signal s20,s21,s22 : signed(8 downto 0);

    signal gx_r, gy_r  : signed(11 downto 0) := (others=>'0');
    signal vld_s1       : std_logic := '0';
    signal mag_r        : unsigned(12 downto 0) := (others=>'0');
    signal vld_s2       : std_logic := '0';
    signal vld_s3       : std_logic := '0';
begin
    s00 <= signed('0' & p00);
    s01 <= signed('0' & p01);
    s02 <= signed('0' & p02);
    s10 <= signed('0' & p10);
    s12 <= signed('0' & p12);
    s20 <= signed('0' & p20);
    s21 <= signed('0' & p21);
    s22 <= signed('0' & p22);

    process(clk)
        variable abs_gx, abs_gy : unsigned(11 downto 0);
        variable r02, r00 : signed(11 downto 0);
        variable r12, r10 : signed(11 downto 0);
        variable r22, r20 : signed(11 downto 0);
        variable r01, r21 : signed(11 downto 0);
    begin
        if rising_edge(clk) then
            -- Stage 1: compute Gx and Gy
            r00 := resize(s00, 12); r01 := resize(s01, 12);
            r02 := resize(s02, 12); r10 := resize(s10, 12);
            r12 := resize(s12, 12); r20 := resize(s20, 12);
            r21 := resize(s21, 12); r22 := resize(s22, 12);

            gx_r <= (r02 - r00)
                  + shift_left(r12 - r10, 1)
                  + (r22 - r20);

            gy_r <= (-r00 - shift_left(r01, 1) - r02)
                  + ( r20 + shift_left(r21, 1) + r22);
            vld_s1 <= valid_in;

            -- Stage 2: |Gx| + |Gy|
            if gx_r(11) = '1' then abs_gx := unsigned(-gx_r);
            else                    abs_gx := unsigned(gx_r(11 downto 0)); end if;
            if gy_r(11) = '1' then abs_gy := unsigned(-gy_r);
            else                    abs_gy := unsigned(gy_r(11 downto 0)); end if;
            mag_r  <= resize(abs_gx, 13) + resize(abs_gy, 13);
            vld_s2 <= vld_s1;

            -- Stage 3: clamp to 8 bits
            if mag_r > 255 then edge_out <= x"FF";
            else edge_out <= std_logic_vector(mag_r(7 downto 0)); end if;
            vld_s3 <= vld_s2;
        end if;
    end process;

    valid_out <= vld_s3;
end rtl;
