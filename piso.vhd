library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity piso is
    port(
        sclk   : in STD_LOGIC;
        reset : in STD_LOGIC;
        load  : in STD_LOGIC;
        pdata : in STD_LOGIC_VECTOR(9 downto 0);
        sdata : out STD_LOGIC
        );
end piso;


architecture rtl of piso is
begin
    piso_proc : process (sclk, reset, load, pdata) is
        variable temp : std_logic_vector (pdata'range);
    begin
        if reset='1' then
            temp := (others=>'0');
        elsif load='1' then
            temp := pdata ;
        elsif rising_edge (sclk) then
            sdata <= temp(9);
            temp := temp(8 downto 0) & '0';
        end if;
    end process piso_proc;

end rtl;
