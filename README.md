# TP_FPGA


## 1 Tutoriel Quartus

On commence par créer et configurer un projet pour la carte Terasic DE10-Nano.

On prends également soin de configurer le fichier de contrainte selon les indications dz la documentation de la carte. Ci-dessous, l"asignation des PIN pour le programme allumant 4 LEDs:

![image](https://github.com/user-attachments/assets/72220766-b14f-4aa6-ab01-1595c39c6b59)


Maintenant, on veux faire clignoter des LEDs. Le problème est que nous ne pouvons pas faire clignoter des LEDs à la fréquence d'horloge (50MHz, clignotement invisible). On veux odnc pouvoir régler la fréquence de clignotment. Ainsi, on réalise le programme `led-blink.vhd`. Ci-dessous, le résultat de l'exécution:

![image](https://github.com/user-attachments/assets/a40e2239-99dc-4947-acaf-565a3860d827)

## 1.6 Faire clignoter une LED

![image](https://github.com/user-attachments/assets/7c03e5a5-3465-483f-abb9-26794036d51c)

## configuration de pin

![image](https://github.com/user-attachments/assets/2c41af27-b401-4f13-9826-b1f5842105db)


## schéma correspond au nouveau code 

![image](https://github.com/user-attachments/assets/6da09687-44ad-43d6-98c0-350fa83cf1b6)

### BLINKS

![image](https://github.com/user-attachments/assets/2eb44609-affe-491a-8975-51583d10f687)

```
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
 signal r_led_enable : std_logic_vector(3 downto 0) := "0000";
begin
 process(i_clk, i_rst_n)
   variable counter : natural range 0 to 5000000 := 0;
 begin
   if (i_rst_n = '0') then
       counter := 0;
       r_led_enable <= "0000";
   elsif (rising_edge(i_clk)) then
     if (counter = 5000000) then
         counter := 0;
         r_led_enable <= not r_led_enable;
     else
        counter := counter + 1;
     end if;
   end if;
 end process;
 o_led <= r_led_enable;
end architecture rtl;
```
