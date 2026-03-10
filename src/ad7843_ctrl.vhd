-- ============================================================
-- FILE:    ad7843_ctrl.vhd
-- DESC:    SPI controller for AD7843 touch screen ADC
-- BOARD:   Terasic TRDB-LTM (connected via GPIO_1)
-- SPI:     Mode 0, MSB first, 12-bit result
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ad7843_ctrl is
    Port (
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
end ad7843_ctrl;

architecture rtl of ad7843_ctrl is
    type state_t is (IDLE, START_X, CONV_X, READ_X,
                     START_Y, CONV_Y, READ_Y, DONE);
    signal state    : state_t := IDLE;
    signal spi_cnt  : integer range 0 to 31 := 0;
    signal clk_div  : integer range 0 to 15 := 0;
    signal spi_clk  : std_logic := '0';
    signal x_reg    : std_logic_vector(11 downto 0) := (others=>'0');
    signal y_reg    : std_logic_vector(11 downto 0) := (others=>'0');
    signal shift_r  : std_logic_vector(11 downto 0) := (others=>'0');
    signal cmd_x    : std_logic_vector(7 downto 0) := x"D0";
    signal cmd_y    : std_logic_vector(7 downto 0) := x"90";
    signal cmd_shift: std_logic_vector(7 downto 0) := (others=>'0');
    signal bit_cnt  : integer range 0 to 15 := 0;
begin
    adc_dclk <= spi_clk;

    process(clk_33, rst_n)
    begin
        if rst_n = '0' then
            state       <= IDLE;
            touch_valid <= '0';
            adc_din     <= '0';
            spi_clk     <= '0';
            clk_div     <= 0;
        elsif rising_edge(clk_33) then
            touch_valid <= '0';
            clk_div <= clk_div + 1;

            if clk_div = 15 then
                clk_div <= 0;
                spi_clk <= not spi_clk;

                case state is
                    when IDLE =>
                        if penirq_n = '0' then
                            cmd_shift <= cmd_x;
                            bit_cnt   <= 0;
                            state     <= START_X;
                        end if;

                    when START_X =>
                        adc_din <= cmd_shift(7);
                        cmd_shift <= cmd_shift(6 downto 0) & '0';
                        bit_cnt <= bit_cnt + 1;
                        if bit_cnt = 7 then
                            bit_cnt <= 0;
                            state   <= CONV_X;
                        end if;

                    when CONV_X =>
                        if adc_busy = '0' then
                            state <= READ_X;
                        end if;

                    when READ_X =>
                        shift_r <= shift_r(10 downto 0) & adc_dout;
                        bit_cnt <= bit_cnt + 1;
                        if bit_cnt = 11 then
                            x_reg   <= shift_r(10 downto 0) & adc_dout;
                            bit_cnt <= 0;
                            cmd_shift <= cmd_y;
                            state   <= START_Y;
                        end if;

                    when START_Y =>
                        adc_din <= cmd_shift(7);
                        cmd_shift <= cmd_shift(6 downto 0) & '0';
                        bit_cnt <= bit_cnt + 1;
                        if bit_cnt = 7 then
                            bit_cnt <= 0;
                            state   <= CONV_Y;
                        end if;

                    when CONV_Y =>
                        if adc_busy = '0' then
                            state <= READ_Y;
                        end if;

                    when READ_Y =>
                        shift_r <= shift_r(10 downto 0) & adc_dout;
                        bit_cnt <= bit_cnt + 1;
                        if bit_cnt = 11 then
                            y_reg   <= shift_r(10 downto 0) & adc_dout;
                            state   <= DONE;
                        end if;

                    when DONE =>
                        touch_x     <= x_reg;
                        touch_y     <= y_reg;
                        touch_valid <= '1';
                        state       <= IDLE;
                end case;
            end if;
        end if;
    end process;
end rtl;
