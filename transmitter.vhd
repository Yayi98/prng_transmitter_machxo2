----------------------------------------------------------------------------
--  transmitter.vhd
--	Version 1.0
--
--  Copyright (C) 2018 Mahesh Chandra Yayi
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY machxo2;
USE machxo2.all;

entity transmitter is

    generic (
    SEED : std_logic_vector (31 downto 0)
            := "10101010110011001111000001010011"
    );

    port (
        sclk  : in std_logic; -- sclk_freq = clk_freq * 10
        clk   : in std_logic;
        ce    : in std_logic;
        reset : in std_logic;
        sdata : out std_logic
    );

end transmitter;

architecture rtl of transmitter is

    signal tempreg  : std_logic_vector (9 downto 0) := (others => '0');
    signal regfull  : std_logic_vector (2 downto 0) := (others => '0');

    -- output ports of prng32
    signal rng   : std_logic_vector (31 downto 0);

    -- inputs of 8b10b_enc
    signal KI       : std_logic := '0'; -- Control (K) input(active high)
    signal AI       : std_logic := '0'; --MSB
    signal BI       : std_logic := '0';
    signal CI       : std_logic := '0';
    signal DI       : std_logic := '0';
    signal EI       : std_logic := '0';
    signal FI       : std_logic := '0';
    signal GI       : std_logic := '0';
    signal HI       : std_logic := '0'; --LSB

    -- ouputs of 8b10b_enc
    signal JO       : std_logic := '0'; --MSB
    signal HO       : std_logic := '0';
    signal GO       : std_logic := '0';
    signal FO       : std_logic := '0';
    signal IO       : std_logic := '0';
    signal EO       : std_logic := '0';
    signal DO       : std_logic := '0';
    signal CO       : std_logic := '0';
    signal BO       : std_logic := '0';
    signal AO       : std_logic := '0'; --LSB

    --reg40
    signal reg40    : std_logic_vector (39 downto 0) := (others => '0');

    --mux signal input
    signal mux_in     : std_logic_vector (7 downto 0) := (others => '0');

    --serializer data input
    signal pdataIn  : std_logic_vector (7 downto 0) := (others => ''0');

    -- outputs of serializer
    signal sdataOut  : std_logic;

    component ODDRX4B
    generic (
        GSR : string
    );
    port (
        D0,D1,D2,D3,D4,D5,D6,D7,ECLK,SCLK,RST : in std_logic;
        Q : out std_logic
    );
	end component;

begin

    prng_inst : entity work.prng32
    generic map (
        SEED => SEED
    )
    port map (
        clk   => clk,
        ce    => ce,
        reset => reset,
        rng   => rng
    );

    enc_inst : entity work.enc_8b10b
    port map (
        KI => KI,
        AI => rng(31),
        BI => rng(30),
        CI => rng(29),
        DI => rng(28),
        EI => rng(27),
        FI => rng(26),
        GI => rng(25),
        HI => rng(24),
        JO => JO,
        HO => HO,
        GO => GO,
        FO => FO,
        IO => IO,
        EO => EO,
        DO => DO,
        CO => CO,
        BO => BO,
        AO => AO,
        RESET    => reset,
        SBYTECLK => clk
    );

    serializer_inst : ODDRX4B
    generic map (
        GSR => "ENABLED"
    )
    port map (
        D0   => pdataIn(0),
        D1   => pdataIn(1),
        D2   => pdataIn(2),
        D3   => pdataIn(3),
        D4   => pdataIn(4),
        D5   => pdataIn(5),
        D6   => pdataIn(6),
        D7   => pdataIn(7),
        ECLK => sclk,
        SCLK => clk,
        RST  => reset,
        Q    => sdata
    );

    load_reg40 : process(clk,reset)
    variable temp1 : integer range 0 to 4 := 4;
    begin
        if reset = '0' then
            if clk'event and clk = '1' then
                if temp1 = 3 then
                    temp1 := 0;
                else
                    temp1 := temp1 + 1;
                end if;
            end if;
        else
            reg40 <= (others => '0');
        end if;
        case temp1 is
            when 0 =>
                reg40 (39) <= JO;
                reg40 (38) <= IO;
                reg40 (37) <= HO;
                reg40 (36) <= GO;
                reg40 (35) <= FO;
                reg40 (34) <= EO;
                reg40 (33) <= DO;
                reg40 (32) <= CO;
                reg40 (31) <= BO;
                reg40 (30) <= AO;
                regfull    <= "000";
            when 1 =>
                reg40 (29) <= JO;
                reg40 (28) <= IO;
                reg40 (27) <= HO;
                reg40 (26) <= GO;
                reg40 (25) <= FO;
                reg40 (24) <= EO;
                reg40 (23) <= DO;
                reg40 (22) <= CO;
                reg40 (21) <= BO;
                reg40 (20) <= AO;
                regfull    <= "001";
            when 2 =>
                reg40 (19) <= JO;
                reg40 (18) <= IO;
                reg40 (17) <= HO;
                reg40 (16) <= GO;
                reg40 (15) <= FO;
                reg40 (14) <= EO;
                reg40 (13) <= DO;
                reg40 (12) <= CO;
                reg40 (11) <= BO;
                reg40 (10) <= AO;
                regfull    <= "010";
            when 3 =>
                reg40 (9) <= JO;
                reg40 (8) <= IO;
                reg40 (7) <= HO;
                reg40 (6) <= GO;
                reg40 (5) <= FO;
                reg40 (4) <= EO;
                reg40 (3) <= DO;
                reg40 (2) <= CO;
                reg40 (1) <= BO;
                reg40 (0) <= AO;
                regfull    <= "011";
            when 4 =>
                tempreg(9) <= JO;
                tempreg(8) <= IO;
                tempreg(7) <= HO;
                tempreg(6) <= GO;
                tempreg(5) <= FO;
                tempreg(4) <= EO;
                tempreg(3) <= DO;
                tempreg(2) <= CO;
                tempreg(1) <= BO;
                tempreg(0) <= AO;
                regfull    <= "100";
        end case;
    end process;

    unload_reg40 : process(clk,reset)
    variable temp2 : integer range 0 to 4 := 4;
    begin
        if reset = '0' then
            if clk'event and clk = '1' then
                if temp2 = 4 then
                    temp2 := 0;
                else
                    temp2 := temp2 + 1;
                end if;
            end if;
        else
            reg40 <= (others => '0');
        end if;
        case temp2 is
            when 0 =>
                if regfull = "000" then
                    padataIn <= reg40 (39 downto 32);
                end if;
            when 1 =>
                if regfull = "001" then
                    padataIn             <= reg40 (31 downto 24);
                    reg40 (39 downto 32) <= (others => '0');
                end if;
            when 2 =>
                if regfull = "010" then
                    padataIn             <= reg40 (23 downto 16);
                    reg40 (31 downto 24) <= (others => '0');
                end if;
            when 3 =>
                if regfull = "011" then
                    padataIn             <= reg40 (15 downto 8);
                    reg40 (23 downto 16) <= (others => '0');
                end if;
            when 4 =>
                if regfull = "100" then
                    padataIn             <= reg40 (7 downto 0);
                    reg40 (15 downto 8)  <= (others => '0');
                end if;
        end case;
    end process;

end rtl;
