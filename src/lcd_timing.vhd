-- ============================================================
-- FILE:    lcd_timing.vhd
-- PROJECT: FPGA Image Processing System
-- BOARD:   Terasic ADC-SoC (Cyclone V 5CSEMA4U23C6N)
-- LCD:     Terasic TRDB-LTM 4.3" 800x480
-- DESC:    Generates HD, VD, DEN, pixel_x, pixel_y for LCD
-- CLOCK:   33.25 MHz pixel clock (from PLL)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_timing is
    Port (
        clk_pix  : in  STD_LOGIC;
        rst_n    : in  STD_LOGIC;
        lcd_hd   : out STD_LOGIC;
        lcd_vd   : out STD_LOGIC;
        lcd_den  : out STD_LOGIC;
        pixel_x  : out STD_LOGIC_VECTOR(9 downto 0);
        pixel_y  : out STD_LOGIC_VECTOR(9 downto 0);
        active   : out STD_LOGIC
    );
end lcd_timing;

architecture rtl of lcd_timing is
    constant H_ACTIVE : integer := 800;
    constant H_FP     : integer := 40;
    constant H_SYNC   : integer := 1;
    constant H_BP     : integer := 215;
    constant H_TOTAL  : integer := 1056;

    constant V_ACTIVE : integer := 480;
    constant V_FP     : integer := 10;
    constant V_SYNC   : integer := 1;
    constant V_BP     : integer := 34;
    constant V_TOTAL  : integer := 525;

    signal h_cnt : integer range 0 to H_TOTAL-1 := 0;
    signal v_cnt : integer range 0 to V_TOTAL-1 := 0;
    signal h_active_s : std_logic;
    signal v_active_s : std_logic;
begin
    process(clk_pix, rst_n)
    begin
        if rst_n = '0' then
            h_cnt <= 0;
            v_cnt <= 0;
        elsif rising_edge(clk_pix) then
            if h_cnt = H_TOTAL - 1 then
                h_cnt <= 0;
                if v_cnt = V_TOTAL - 1 then
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
                end if;
            else
                h_cnt <= h_cnt + 1;
            end if;
        end if;
    end process;

    h_active_s <= '1' when h_cnt < H_ACTIVE else '0';
    v_active_s <= '1' when v_cnt < V_ACTIVE else '0';
    active     <= h_active_s and v_active_s;
    lcd_den    <= h_active_s and v_active_s;

    lcd_hd <= '0' when (h_cnt >= H_ACTIVE + H_FP and
                        h_cnt <  H_ACTIVE + H_FP + H_SYNC)
              else '1';

    lcd_vd <= '0' when (v_cnt >= V_ACTIVE + V_FP and
                        v_cnt <  V_ACTIVE + V_FP + V_SYNC)
              else '1';

    pixel_x <= std_logic_vector(to_unsigned(h_cnt, 10))
               when h_cnt < H_ACTIVE else (others => '0');
    pixel_y <= std_logic_vector(to_unsigned(v_cnt, 10))
               when v_cnt < V_ACTIVE else (others => '0');
end rtl;
