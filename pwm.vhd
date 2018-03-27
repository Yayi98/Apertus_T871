---------------------------------------------------------------------------
-- Filename : pwm.vhd
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity pwm is
    generic (
        BIT_SIZE : integer := 8;
        INPUT_CLK : integer := 50000000;
        FREQ      : integer := 25000000
    );
    port (
        pwm_out    : out std_logic;
        dutycycle  : in std_logic_vector(BIT_SIZE - 1 downto 0);
        clk        : in std_logic;
        enable     : in std_logic
    );
end entity pwm;

architecture behavior of pwm is

    constant COUNT : integer := 2**BIT_SIZE;
    --constant pwm_step       : integer := max_freq_count / 2**BIT_SIZE;

    --signal pwm_value      : std_logic := '0';
    --signal freq_count     : integer range 0 to max_freq_count := 0;
    signal pwm_count      : integer range 0 to 2**BIT_SIZE := 0;
    signal dutycycle_count  : integer range 0 to 2**BIT_SIZE := 0;
    --signal pwm_step_count : integer range 0 to max_freq_count := 0;
begin

	dutycycle_count <= to_integer(unsigned(dutycycle));
	--pwm_out <= pwm_value;

	freq_counter : process(enable, clk)
	begin
		if rising_edge(clk) then
			if enable = '0' then
				if pwm_count < COUNT then
                    pwm_count <= pwm_count + 1;
                    if pwm_count < dutycycle_count then
                        pwm_out <= '1';
                    else
                        pwm_out <= '0';
                    end if;
                else
                    pwm_count <= 0;
                end if;
			else
 	            pwm_out <= '0';
			end if;
		end if;
	end process freq_counter;
end behavior;
