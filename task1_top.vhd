---------------------------------------------------------------------------
-- Filename : task1_top.vhd
--
--Author : Mahesh Yayi <superchintu98@gmail.com>
--
--Copyright (c) 2018 Mahesh Yayi
---------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity i2c_pwm is
    generic(
    ADDR      : std_logic_vector(6 downto 0);
    REG1_ADDR : std_logic_vector(7 downto 0);
    REG2_ADDR : std_logic_vector(7 downto 0);
    BIT_SIZE  : integer := 8
    );
    port(
    sda     : inout std_logic;
    scl     : inout std_logic;
    clk     : in std_logic;
    reset   : in std_logic;
    pwm_out : out std_logic
    );
end entity i2c_pwm;

architecture structure of i2c_pwm is

    signal temp_reg : std_logic_vector(7 downto 0) := (others => '0');

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

    pwm1 : entity work.pwm1
    generic map (
        BIT_SIZE => BIT_SIZE
    );
    port map (
        clk       => clk;
        reset     => reset;
        dutycycle => temp_reg;
        pwm_out   => pwm_out
    );

    i2c_slave1 : entity work.i2c_slave
    generic map (
        ADDR => ADDR;
        REG1_ADDR => REG1_ADDR;
        REG2_ADDR => REG2_ADDR
    );
    port map (
        clk   => clk;
        reset => reset;
        sda   => sda;
        scl   => scl;
        ack   => ack
    );
begin
    top_module_proc : process(reset, clk)
    begin
        if rising_edge(clk) then
            dutycycle <= temp_reg;
        else
            dutycycle <= (others => '0');
        end if;
    end process top_module_proc;
end structure;
