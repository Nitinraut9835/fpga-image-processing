-- ============================================================
-- FILE:    test_pattern.vhd
-- DESC:    8-bar colour test pattern generator
-- BARS:    White Yellow Cyan Green Magenta Red Blue Black
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_pattern is
    Port (
        pixel_x  : in  STD_LOGIC_VECTOR(9 downto 0);
        pixel_y  : in  STD_LOGIC_VECTOR(9 downto 0);
        active   : in  STD_LOGIC;
        r_out    : out STD_LOGIC_VECTOR(7 downto 0);
        g_out    : out STD_LOGIC_VECTOR(7 downto 0);
        b_out    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end test_pattern;

architecture rtl of test_pattern is
    signal x : integer range 0 to 1023;
begin
    x <= to_integer(unsigned(pixel_x));

    process(active, x, pixel_y)
    begin
        if active = '0' then
            r_out <= x"00"; g_out <= x"00"; b_out <= x"00";
        else
            if    x < 100 then r_out<=x"FF"; g_out<=x"FF"; b_out<=x"FF";  -- White
            elsif x < 200 then r_out<=x"FF"; g_out<=x"FF"; b_out<=x"00";  -- Yellow
            elsif x < 300 then r_out<=x"00"; g_out<=x"FF"; b_out<=x"FF";  -- Cyan
            elsif x < 400 then r_out<=x"00"; g_out<=x"FF"; b_out<=x"00";  -- Green
            elsif x < 500 then r_out<=x"FF"; g_out<=x"00"; b_out<=x"FF";  -- Magenta
            elsif x < 600 then r_out<=x"FF"; g_out<=x"00"; b_out<=x"00";  -- Red
            elsif x < 700 then r_out<=x"00"; g_out<=x"00"; b_out<=x"FF";  -- Blue
            else                r_out<=x"00"; g_out<=x"00"; b_out<=x"00";  -- Black
            end if;
        end if;
    end process;
end rtl;
