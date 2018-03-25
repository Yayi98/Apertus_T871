--------------------------------------------------------------------------------------
-- Filename : i2c_final1.vhd
--
--Author : Mahesh Yayi <superchintu98@gmail.com>
--
--Copyright (c) 2018 Mahesh Yayi
--------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity i2c_slave is
    generic(
    ADDR      : std_logic_vector( 6 downto 0 );
    REG1_ADDR : std_logic_vector( 7 downto 0 );
    BIT_SIZE  : integer := 8
    );
    port(
    clk   : in std_logic;
    reset : in std_logic;
    sda   : inout std_logic;
    scl   : inout std_logic
    );
end entity i2c_slave;

architecture RTL of i2c is
--signal temp_reg2      : std_logic_vector( 6 downto 0 ) := (others => '0');
signal rw_bit         : std_logic;
--signal reg_slave_full : std_logic_vector( 7 downto 0 ) := ( others => '0' );
--signal reg_addr       : std_logic_vector( 7 downto 0 ) := ( others => '0' );
--signal data_reg       : std_logic_vector( 7 downto 0 ) := ( others => '0' );
signal temp_reg1      : std_logic_vector( 7 downto 0 ) := (others => '0');
signal slave_check    : std_logic := '0';
signal reg_check      : std_logic := '0';
signal start_counter  : std_logic := '0';
signal overflow       : std_logic := '0';
signal counter        : std_logic_vector( 3 downto 0 ) := (others => '0');

sipo_shiftreg : entity work.sipo
generic map (
	BIT_SIZE => BIT_SIZE
);
port map (
	sipo_out   => temp_reg;
    sipo_in    => sda;
    sipo_clk   => clk;
    sipo_reset => reset
);

piso_shiftreg : entity work.piso_shiftreg
generic map (
    BIT_SIZE => BIT_SIZE
);
port map (
    piso_clk   => clk;
    piso_reset => reset;
    piso_in    => temp_reg1;
    piso_out   => sda
);
begin
    counter_proc : process( clk )
    begin
        if start_counter = '1' then
            if rising_edge(clk) and counter <= "1000" then
                counter  <= counter + '1';
                overflow <= '1' when counter = "1000";
            else
                counter  <= (others => '0');
            end if;
        end if;
    end process counter_proc;

	slave_selection_proc : process( reset, clk )
	begin
		if reset = '0' and falling_edge(sda) and scl = '1' then
			start_counter <= '1';
            if overflow = '1' then
                rw_bit <= temp_reg1(0); --store last bit of temp_reg1 in rw_bit
                if temp_reg1( 7 downto 1 ) = ADDR then
                    slave_check <= '1';
                else
                    slave_check <= '0';
                end if;
                if slave_check = '1' then
                    sda <= '0';--send ack
                    if rising_edge(scl) then
                        sda <= '1';
                    end if;
                end if;
            end if;
        else--else vs elsif rising_edge(clk) then. What are the differences? What are pros and cons of each?
            slave_check <= '0';
            temp_reg1 <= (others => '0');
        end if;
    end process slave_selection_proc;

    reg_selection_proc : process( reset, slave_check ) -- This process executes if slave_check changes
    begin
        if reset = '0' and slave_check = '1' then
            start_counter <= '1';
            if overflow = '1' then
                reg_check <= '1' when temp_reg1 = REG1_ADDR;
                sda <= '0';--send ack
                if rising_edge(scl) then
                    sda <= '1';
                end if;
            end if;
        else
            reg_check <= '0';
            temp_reg1 <= (others => '0');
        end if;
    end process reg_selection_proc;

    data_write_proc : process( reset, reg_check )
    begin
        if reset = '0' and rw_bit = '0' and reg_check = '1' then
            start_counter <= '1';
            if overflow = '1' then
                sda <= '0';
                if rising_edge(scl);
                    sda <= '1';
                end if;
            end if;
        else
            temp_reg1 <= (others => '0');
        end if;
    end process data_write_proc;

--    data_read_proc : process( reset, reg_check )
--    begin
--        if reset = '0' and rw_bit = '1' and reg_check = '1' then
--            for i in 0 to 7 loop
--                wait until rising_edge(clk);
--            end loop;
--            wait until falling_edge(sda);--wait for ack from master
--        else
--            null; --Using else and null instead of just if-endif with no else to avoid latch creation during synthesis
--        end if;
--    end process data_read_proc;
end RTL;
