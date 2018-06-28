library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY lattice;
USE lattice.components.all;

LIBRARY machxo2;
USE machxo2.all;

entity serializer8_1 is
    port (
        pdataIn  : in std_logic_vector(9 downto 0);
        sclk     : in std_logic; -- 100MHz
        clk      : in std_logic; -- 25 MHz
        reset    : in std_logic
        sdataOut : out std_logic
    );
end serializer8_1;

architecture rtl of serializer8_1 is
    signal serial1tomux : std_logic := '0';
    signal serial2tomux : std_logic := '0';
    signal muxout       : std_logic := '0';
    signal mux_select   : std_logic := '0';
begin
    serializer_inst1 : ODDRX4B
    generic map (
        GSR => "ENABLED"
    )
    port map (
        DO   => pdataIn(0),
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
        Q    => serial1tomux
    );

    serializer_inst2 : ODDRX4B
    generic map (
        GSR => "ENABLED"
    )
    port map (
    DO   => '0',
    D1   => '0',
    D2   => '0',
    D3   => '0',
    D4   => '0',
    D5   => '0',
    D6   => pdataIn(8),
    D7   => pdataIn(9),
    ECLK => sclk,
    SCLK => clk,
    RST  => reset,
    Q    => serial2tomux
    );

    counterproc : process(sclk,reset)
    signal temp1 : integer range 0 to 9 := 9; -- temp1 is initiated with 9 because the counting must start from 0
    signal temp2 : std_logic := '0';
    begin
        if reset = '1' then
            temp1 <= 0;
        elsif sclk'event and sclk = '1' then
            temp1 <= temp1 + 1;
        end if;
        case temp1 is
            when 8 | 9 => temp2 <= '1';
            when others => temp2 <= '0';
        end case;
    end process;

    mux_select <= temp2;

    mux : process(serial1tomux,serial2tomux,mux_select)
    begin
        if mux_select = '0' then
            muxout <= serial1tomux;
        else
            muxout <= serial2tomux;
        end if;
    end process;

    sdataOut <= muxout;

end rtl;