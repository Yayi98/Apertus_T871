--------------------------------------------------------------------------------------
-- Filename : sipo.vhd
--
--Author : Mahesh Yayi <superchintu98@gmail.com>
--
--Copyright (c) 2018 Mahesh Yayi
--------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sipo is
    generic(
    BIT_SIZE : integer := 8
    );
    port (
    sipo_out   : out std_logic_vector(BIT_SIZE-1 downto 0);
    sipo_in    : in std_logic;
    sipo_clk   : in std_logic;
    sipo_reset : in std_logic
    );
end entity sipo;

architecture RTL of sipo is
    signal reg : std_logic_vector(BIT_SIZE-1 downto 0);
begin
    sipo_out <= reg;
    sipo_proc : process(reset, clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                reg(BIT_SIZE-1 downto 0) <= reg(BIT_SIZE-2 downto 0);
                reg <= sipo_in;
            else
                reg <= (others => '0');
            end if;
        end if;
    end process sipo_proc;
end RTL;
