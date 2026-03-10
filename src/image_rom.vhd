-- ============================================================
-- FILE:    image_rom.vhd
-- DESC:    On-chip Block RAM storing 320x240 RGB image
--          Initialized from image_data.mif
--          Generate MIF with: python scripts/convert_to_mif.py
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity image_rom is
    port (
        clk   : in  STD_LOGIC;
        addr  : in  STD_LOGIC_VECTOR(16 downto 0);
        r_out : out STD_LOGIC_VECTOR(7 downto 0);
        g_out : out STD_LOGIC_VECTOR(7 downto 0);
        b_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end image_rom;

architecture rtl of image_rom is
    type rom_t is array (0 to 76799) of std_logic_vector(23 downto 0);
    signal mem : rom_t;
    attribute ram_init_file : string;
    attribute ram_init_file of mem : signal is "image_data.mif";
    signal data_reg : std_logic_vector(23 downto 0) := (others=>'0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            data_reg <= mem(to_integer(unsigned(addr)));
        end if;
    end process;

    r_out <= data_reg(23 downto 16);
    g_out <= data_reg(15 downto  8);
    b_out <= data_reg( 7 downto  0);
end rtl;
