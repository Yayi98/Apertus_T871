---------------------------------------------------------------------------
-- Filename : piso.vhd
--
--Author : Mahesh Yayi <superchintu98@gmail.com>
--
--Copyright (c) 2018 Mahesh Yayi
--GNU GENERAL PUBLIC LICENSE
--                       Version 3, 29 June 2007

 --Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 --Everyone is permitted to copy and distribute verbatim copies
 --of this license document, but changing it is not allowed.
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity piso is
    generic(
    BIT_SIZE : integer := 8
    );
    port(
    piso_clk   : in std_logic;
    piso_reset : in std_logic;
    piso_in    : in std_logic_vector(BIT_SIZE-1 downto 0);
    piso_out   : out std_logic
    );
end entity piso;


architecture RTL of piso is
begin

    piso_proc : process (piso_reset, piso_clk) is
    variable temp : std_logic_vector(BIT_SIZE-1 downto 0);
    begin
        if piso_reset = '1' then
            temp := (others=>'0');
        elsif rising_edge(piso_clk) then
            temp := piso_in;
            if temp = piso_in then
                piso_out <= temp(BIT_SIZE-1);
            else
                piso_out <= (others => '0');
            end if;
            if piso_out = temp(BIT_SIZE-1) then
                temp := temp(BIT_SIZE-2 downto 0) & '0';
            else
                temp := (others => '0');
            end if;
        end if;
    end process piso_proc;
end RTL;
