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
    sipo_out   : out std_logic_vector( BIT_SIZE - 1 downto 0 );
    sipo_in    : in std_logic;
    sipo_clk   : in std_logic;
    sipo_reset : in std_logic
    );
end entity sipo;

architecture RTL of sipo is
    signal sipo_out : std_logic_vector( BIT_SIZE - 1 downto 0 );
begin
    sipo_out <= sipo_reg;
    sipo_proc : process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                sipo_reg( BIT_SIZE - 1 downto 0 ) <= sipo_reg( BIT_SIZE - 2 downto 0 );
                sipo_reg <= sipo_in;
            else
                sipo_reg <= (others => '0');
            end if;
        end if;
    end process sipo_proc;
end RTL;
