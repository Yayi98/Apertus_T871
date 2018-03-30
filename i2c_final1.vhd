---------------------------------------------------------------------------
-- Filename : i2c_final1.vhd
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity i2c_final1 is
    generic(
    ADDR      : std_logic_vector(6 downto 0) := "1111000";
    REG1_ADDR : std_logic_vector(7 downto 0) := "11001100";
    BIT_SIZE  : integer := 8
    );
    port(
    --clk   : in std_logic;
    reset    : in std_logic;
    sda      : inout std_logic;
    temp_reg : buffer std_logic_vector(7 downto 0);
    scl      : in std_logic
    );
end entity i2c_final1;

architecture RTL of i2c_final1 is
signal rw_bit         : std_logic;
signal temp_reg1      : std_logic_vector(7 downto 0) := (others => '0');
signal slave_check    : std_logic := '0';
signal reg_check      : std_logic := '0';
signal start_counter  : std_logic := '0';
signal overflow       : std_logic := '0';
signal counter        : integer   := 0;
begin
    sipo_shiftreg : entity work.sipo
    generic map(
    	BIT_SIZE => BIT_SIZE
    )
    port map(
    	sipo_out   => temp_reg1,
        sipo_in    => sda,
        sipo_clk   => scl,
        sipo_reset => reset
    );

    piso_shiftreg : entity work.piso
    generic map(
        BIT_SIZE => BIT_SIZE
    )
    port map(
        piso_clk   => scl,
        piso_reset => reset,
        piso_in    => temp_reg1,
        piso_out   => sda
    );
    counter_proc : process(reset, start_counter, scl)
    begin
        if rising_edge(scl) then
            if reset = '0' then
                if start_counter = '1' then
                    if counter < 9 then
                        counter <= counter + 1;
                    else
                        counter  <= 0;
                        overflow <= '1';
                    end if;
                end if;
            else
                counter       <= 0;
                overflow      <= '0';
                start_counter <= '0';
            end if;
        end if;
    end process counter_proc;

	slave_selection_proc : process(reset, scl)
	begin
		if reset = '0' and falling_edge(sda) and scl = '1' then
            if slave_check = '0' then
    			start_counter <= '1';
                if overflow = '1' then
                    rw_bit <= temp_reg1(0);
                    if temp_reg1(7 downto 1) = ADDR then
                        slave_check <= '1';
                    else
                        slave_check <= '0';
                    end if;
                    if slave_check = '1' then
                        if falling_edge(scl) then
                            sda <= '0';
                            if rising_edge(scl) then
                                sda <= '1';
                            end if;
                        end if;
                    end if;
                end if;
            else
                slave_check   <= '0';
                temp_reg1     <= (others => '0');
				start_counter <= '0';
            end if;
        else
            start_counter <= '0';
            temp_reg1     <= (others => '0');
            slave_check   <= '0';
        end if;
    end process slave_selection_proc;

    reg_selection_proc : process(reset, slave_check)
    begin
        if reset = '0' and slave_check = '1' then
            start_counter <= '1';
            if overflow = '1' then
                if temp_reg1 = REG1_ADDR then
                    reg_check <= '1';
                end if;
                if falling_edge(scl) then
                    sda <= '0';
                    if rising_edge(scl) then
                        sda <= '1';
                    end if;
                end if;
            end if;
        else
            reg_check <= '0';
            temp_reg1 <= (others => '0');
        end if;
    end process reg_selection_proc;

    data_write_proc : process(reset, reg_check)
    begin
        if reset = '0' and rw_bit = '0' and reg_check = '1' then
            start_counter <= '1';
            if overflow = '1' then
                if falling_edge(scl) then
                    sda <= '0';
                    if rising_edge(scl) then
                        sda <= '1';
                    end if;
                end if;
            end if;
        else
            temp_reg1 <= (others => '0');
        end if;
    end process data_write_proc;
end RTL;
