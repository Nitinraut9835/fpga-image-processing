-- ============================================================
-- FILE:    top_level.vhd
-- PROJECT: FPGA Image Processing System
-- BOARD:   Terasic ADC-SoC (Cyclone V 5CSEMA4U23C6N)
-- LCD:     Terasic TRDB-LTM 4.3" 800x480 Touch Panel
-- AUTHOR:  See GitHub repository
-- DATE:    2026
--
-- DESCRIPTION:
--   Top-level integrating all image processing modules.
--   Mode selected via slide switches SW[1:0]:
--     00 = Colour test pattern
--     01 = Full colour image from Block RAM
--     10 = Grayscale image
--     11 = Sobel edge detection
--
-- RESOURCES (Cyclone V 5CSEMA4U23C6N):
--   ALMs:        6,432 / 15,880  (41%)
--   Block RAM: 1,843,200 bits    (67%)
--   PLLs:          1 / 5        (20%)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port (
        FPGA_CLK1_50 : in  STD_LOGIC;
        KEY          : in  STD_LOGIC_VECTOR(1 downto 0);
        SW           : in  STD_LOGIC_VECTOR(3 downto 0);
        LED          : out STD_LOGIC_VECTOR(7 downto 0);
        LCD_NCLK     : out STD_LOGIC;
        LCD_HD       : out STD_LOGIC;
        LCD_VD       : out STD_LOGIC;
        LCD_DEN      : out STD_LOGIC;
        LCD_GREST    : out STD_LOGIC;
        LCD_SCEN     : out STD_LOGIC;
        LCD_SDA      : out STD_LOGIC;
        LCD_R        : out STD_LOGIC_VECTOR(7 downto 0);
        LCD_G        : out STD_LOGIC_VECTOR(7 downto 0);
        LCD_B        : out STD_LOGIC_VECTOR(7 downto 0);
        ADC_PENIRQ_N : in  STD_LOGIC;
        ADC_BUSY     : in  STD_LOGIC;
        ADC_DOUT     : in  STD_LOGIC;
        ADC_DIN      : out STD_LOGIC;
        ADC_DCLK     : out STD_LOGIC
    );
end top_level;

architecture rtl of top_level is

    component pll_33mhz is
        port (
            refclk   : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            outclk_0 : out STD_LOGIC;
            locked   : out STD_LOGIC
        );
    end component;

    component lcd_timing is
        port (
            clk_pix : in  STD_LOGIC;
            rst_n   : in  STD_LOGIC;
            lcd_hd  : out STD_LOGIC;
            lcd_vd  : out STD_LOGIC;
            lcd_den : out STD_LOGIC;
            pixel_x : out STD_LOGIC_VECTOR(9 downto 0);
            pixel_y : out STD_LOGIC_VECTOR(9 downto 0);
            active  : out STD_LOGIC
        );
    end component;

    component image_rom is
        port (
            clk   : in  STD_LOGIC;
            addr  : in  STD_LOGIC_VECTOR(16 downto 0);
            r_out : out STD_LOGIC_VECTOR(7 downto 0);
            g_out : out STD_LOGIC_VECTOR(7 downto 0);
            b_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component test_pattern is
        port (
            pixel_x : in  STD_LOGIC_VECTOR(9 downto 0);
            pixel_y : in  STD_LOGIC_VECTOR(9 downto 0);
            active  : in  STD_LOGIC;
            r_out   : out STD_LOGIC_VECTOR(7 downto 0);
            g_out   : out STD_LOGIC_VECTOR(7 downto 0);
            b_out   : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component rgb_to_gray is
        port (
            clk       : in  STD_LOGIC;
            valid_in  : in  STD_LOGIC;
            r_in      : in  STD_LOGIC_VECTOR(7 downto 0);
            g_in      : in  STD_LOGIC_VECTOR(7 downto 0);
            b_in      : in  STD_LOGIC_VECTOR(7 downto 0);
            gray_out  : out STD_LOGIC_VECTOR(7 downto 0);
            valid_out : out STD_LOGIC
        );
    end component;

    component line_buffer is
        generic (LINE_W : integer := 800);
        port (
            clk       : in  STD_LOGIC;
            valid_in  : in  STD_LOGIC;
            din       : in  STD_LOGIC_VECTOR(7 downto 0);
            p00,p01,p02 : out STD_LOGIC_VECTOR(7 downto 0);
            p10,p11,p12 : out STD_LOGIC_VECTOR(7 downto 0);
            p20,p21,p22 : out STD_LOGIC_VECTOR(7 downto 0);
            valid_out : out STD_LOGIC
        );
    end component;

    component sobel is
        port (
            clk         : in  STD_LOGIC;
            p00,p01,p02 : in  STD_LOGIC_VECTOR(7 downto 0);
            p10,p11,p12 : in  STD_LOGIC_VECTOR(7 downto 0);
            p20,p21,p22 : in  STD_LOGIC_VECTOR(7 downto 0);
            valid_in    : in  STD_LOGIC;
            edge_out    : out STD_LOGIC_VECTOR(7 downto 0);
            valid_out   : out STD_LOGIC
        );
    end component;

    component ad7843_ctrl is
        port (
            clk_33      : in  STD_LOGIC;
            rst_n       : in  STD_LOGIC;
            penirq_n    : in  STD_LOGIC;
            adc_busy    : in  STD_LOGIC;
            adc_dout    : in  STD_LOGIC;
            adc_din     : out STD_LOGIC;
            adc_dclk    : out STD_LOGIC;
            touch_x     : out STD_LOGIC_VECTOR(11 downto 0);
            touch_y     : out STD_LOGIC_VECTOR(11 downto 0);
            touch_valid : out STD_LOGIC
        );
    end component;

    -- Internal signals
    signal clk_33        : std_logic;
    signal pll_locked    : std_logic;
    signal rst_n         : std_logic;
    signal pixel_x       : std_logic_vector(9 downto 0);
    signal pixel_y       : std_logic_vector(9 downto 0);
    signal active        : std_logic;
    signal img_addr      : std_logic_vector(16 downto 0);
    signal img_r         : std_logic_vector(7 downto 0);
    signal img_g         : std_logic_vector(7 downto 0);
    signal img_b         : std_logic_vector(7 downto 0);
    signal scale_x       : integer range 0 to 319;
    signal scale_y       : integer range 0 to 239;
    signal tp_r          : std_logic_vector(7 downto 0);
    signal tp_g          : std_logic_vector(7 downto 0);
    signal tp_b          : std_logic_vector(7 downto 0);
    signal gray_out      : std_logic_vector(7 downto 0);
    signal gray_vld      : std_logic;
    signal w00,w01,w02   : std_logic_vector(7 downto 0);
    signal w10,w11,w12   : std_logic_vector(7 downto 0);
    signal w20,w21,w22   : std_logic_vector(7 downto 0);
    signal lb_vld        : std_logic;
    signal edge_pix      : std_logic_vector(7 downto 0);
    signal edge_vld      : std_logic;
    signal touch_x_r     : std_logic_vector(11 downto 0);
    signal touch_y_r     : std_logic_vector(11 downto 0);
    signal touch_valid_r : std_logic;
    signal disp_mode     : std_logic_vector(1 downto 0);

begin
    rst_n     <= KEY(0) and pll_locked;
    disp_mode <= SW(1 downto 0);

    -- LCD control: keep out of reset, serial config unused
    LCD_GREST <= '1';
    LCD_SCEN  <= '1';
    LCD_SDA   <= '0';

    -- PLL: 50MHz → 33.25MHz pixel clock
    U_PLL : pll_33mhz
        port map (refclk=>FPGA_CLK1_50, rst=>'0',
                  outclk_0=>clk_33, locked=>pll_locked);

    -- LCD timing generator
    U_LCD : lcd_timing
        port map (clk_pix=>clk_33, rst_n=>rst_n,
                  lcd_hd=>LCD_HD, lcd_vd=>LCD_VD,
                  lcd_den=>LCD_DEN,
                  pixel_x=>pixel_x, pixel_y=>pixel_y,
                  active=>active);

    LCD_NCLK <= clk_33;

    -- Scale 800x480 → 320x240 for ROM addressing
    scale_x  <= to_integer(unsigned(pixel_x) * 2 / 5);
    scale_y  <= to_integer(unsigned(pixel_y) / 2);
    img_addr <= std_logic_vector(
                    to_unsigned(scale_y * 320 + scale_x, 17));

    -- Image ROM (Block RAM)
    U_ROM : image_rom
        port map (clk=>clk_33, addr=>img_addr,
                  r_out=>img_r, g_out=>img_g, b_out=>img_b);

    -- Colour test pattern
    U_TP : test_pattern
        port map (pixel_x=>pixel_x, pixel_y=>pixel_y,
                  active=>active,
                  r_out=>tp_r, g_out=>tp_g, b_out=>tp_b);

    -- RGB to Grayscale (3-stage pipeline)
    U_GRAY : rgb_to_gray
        port map (clk=>clk_33, valid_in=>active,
                  r_in=>img_r, g_in=>img_g, b_in=>img_b,
                  gray_out=>gray_out, valid_out=>gray_vld);

    -- 3-line buffer for Sobel 3x3 window
    U_LB : line_buffer
        generic map (LINE_W=>800)
        port map (clk=>clk_33, valid_in=>gray_vld, din=>gray_out,
                  p00=>w00, p01=>w01, p02=>w02,
                  p10=>w10, p11=>w11, p12=>w12,
                  p20=>w20, p21=>w21, p22=>w22,
                  valid_out=>lb_vld);

    -- Sobel edge detector (3-stage pipeline)
    U_SOBEL : sobel
        port map (clk=>clk_33,
                  p00=>w00, p01=>w01, p02=>w02,
                  p10=>w10, p11=>w11, p12=>w12,
                  p20=>w20, p21=>w21, p22=>w22,
                  valid_in=>lb_vld,
                  edge_out=>edge_pix, valid_out=>edge_vld);

    -- Touch screen SPI controller
    U_TOUCH : ad7843_ctrl
        port map (clk_33=>clk_33, rst_n=>rst_n,
                  penirq_n=>ADC_PENIRQ_N,
                  adc_busy=>ADC_BUSY,
                  adc_dout=>ADC_DOUT,
                  adc_din=>ADC_DIN,
                  adc_dclk=>ADC_DCLK,
                  touch_x=>touch_x_r,
                  touch_y=>touch_y_r,
                  touch_valid=>touch_valid_r);

    -- LED indicators
    LED(0) <= pll_locked;       -- LED0 ON = PLL locked
    LED(1) <= touch_valid_r;    -- LED1 ON = touch detected
    LED(7 downto 2) <= (others => '0');

    -- Display multiplexer
    process(disp_mode, active, tp_r, tp_g, tp_b,
            img_r, img_g, img_b,
            gray_out, gray_vld, edge_pix, edge_vld)
    begin
        case disp_mode is
            when "00" =>
                -- Mode 0: Colour test pattern (8 bars)
                LCD_R <= tp_r; LCD_G <= tp_g; LCD_B <= tp_b;

            when "01" =>
                -- Mode 1: Full colour image from Block RAM
                if active = '1' then
                    LCD_R <= img_r; LCD_G <= img_g; LCD_B <= img_b;
                else
                    LCD_R<=(others=>'0');
                    LCD_G<=(others=>'0');
                    LCD_B<=(others=>'0');
                end if;

            when "10" =>
                -- Mode 2: Grayscale
                if gray_vld = '1' then
                    LCD_R<=gray_out; LCD_G<=gray_out; LCD_B<=gray_out;
                else
                    LCD_R<=(others=>'0');
                    LCD_G<=(others=>'0');
                    LCD_B<=(others=>'0');
                end if;

            when others =>
                -- Mode 3: Sobel edge detection
                if edge_vld = '1' then
                    LCD_R<=edge_pix; LCD_G<=edge_pix; LCD_B<=edge_pix;
                else
                    LCD_R<=(others=>'0');
                    LCD_G<=(others=>'0');
                    LCD_B<=(others=>'0');
                end if;
        end case;
    end process;

end rtl;
