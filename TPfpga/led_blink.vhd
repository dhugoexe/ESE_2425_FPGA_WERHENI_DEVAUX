library ieee;
use ieee.std_logic_1164.all;

entity led_blink is
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;
        o_led : out std_logic_vector(3 downto 0)
    );
end entity led_blink;

architecture rtl of led_blink is
    signal r_led_enable : std_logic_vector(3 downto 0) := "1000";
    signal r_direction : std_logic := '1';  -- '1' for right, '0' for left
begin
    process(i_clk, i_rst_n)
        variable counter : natural range 0 to 5000000 := 0;
    begin
        if (i_rst_n = '0') then
            counter := 0;
            r_led_enable <= "1000";
            r_direction <= '1';
        elsif (rising_edge(i_clk)) then
            if (counter = 5000000) then
                counter := 0;
                
                -- Update LED pattern based on direction
                if r_direction = '1' then
                    -- Shift right
                    if r_led_enable = "0001" then
                        r_led_enable <= "1000";
                    else
                        r_led_enable <= r_led_enable(3 downto 1) & '0';
                    end if;
                else
                    -- Shift left
                    if r_led_enable = "1000" then
                        r_led_enable <= "0001";
                    else
                        r_led_enable <= '0' & r_led_enable(2 downto 0);
                    end if;
                end if;
                
                -- Change direction when reaching the end
                if r_led_enable = "0001" or r_led_enable = "1000" then
                    r_direction <= not r_direction;
                end if;
            else
                counter := counter + 1;
            end if;
        end if;
    end process;
    
    o_led <= r_led_enable;
end architecture rtl;