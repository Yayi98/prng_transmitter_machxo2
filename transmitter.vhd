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

entity transmitter is

    generic (
    SEED : std_logic_vector (31 downto 0)
            := "10101010110011001111000001010011"
    );

    port (
        sclk  : in std_logic; -- sclk_freq = clk_freq * 10
        clk   : in std_logic;
        ce    : in std_logic;
        load  : in std_logic; -- It must be a synchronous signal with 1/8 times the frequency of sclk. The duty cycle must as low as possible.
        reset : in std_logic;
        sdata : out std_logic
    );

end transmitter;

architecture rtl of transmitter is

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

    -- outputs of serializer
    signal serial  : std_logic;

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

    piso_inst : entity work.serializer8_1
    port map (
        sclk  => sclk,
        clk   => clk,
        reset => reset,

        pdataIn(9) => JO,
        pdataIn(8) => IO,
        pdataIn(7) => HO,
        pdataIn(6) => GO,
        pdataIn(5) => FO,
        pdataIn(4) => EO,
        pdataIn(3) => DO,
        pdataIn(2) => CO,
        pdataIn(1) => BO,
        pdataIn(0) => AO,
        sdataOut => sdata
        );

end rtl;
