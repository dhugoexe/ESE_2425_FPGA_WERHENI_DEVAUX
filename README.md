# TP_FPGA


## 1 Tutoriel Quartus

On commence par créer et configurer un projet pour la carte Terasic DE10-Nano.

On prends également soin de configurer le fichier de contrainte selon les indications dz la documentation de la carte. Ci-dessous, l"asignation des PIN pour le programme allumant 4 LEDs:

![image](https://github.com/user-attachments/assets/72220766-b14f-4aa6-ab01-1595c39c6b59)


Maintenant, on veux faire clignoter des LEDs. Le problème est que nous ne pouvons pas faire clignoter des LEDs à la fréquence d'horloge (50MHz, clignotement invisible). On veux odnc pouvoir régler la fréquence de clignotment. Ainsi, on réalise le programme `led-blink.vhd`. Ci-dessous, le résultat de l'exécution:

![image](https://github.com/user-attachments/assets/a40e2239-99dc-4947-acaf-565a3860d827)

## 1.6 Faire clignoter une LED

Ce code semble être conçu pour faire clignoter une LED en créant une temporisation. Le compteur jusqu'à 500000 est utilisé pour créer un délai entre chaque changement d'état de la LED

![image](https://github.com/user-attachments/assets/7c03e5a5-3465-483f-abb9-26794036d51c)

## configuration de pin

Nous allons présente une table de configuration des broches (pins) pour un circuit intégré ou un FPGA. Elle détaille les spécifications pour trois signaux principaux : i_clk, i_rst_n et i_led. Ces signaux sont configurés avec des caractéristiques précises : i_clk et i_rst_n sont définis comme des entrées tandis que i_led est configuré comme une sortie. Ils sont respectivement assignés aux emplacements physiques PIN_AH17, PIN_W13 et PIN_W15 sur le composant. 

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

### Chenillard

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
```

## TP2 Petit projet : Bouncing ENSEA Logo

# Analysez l’entity :

Paramètres de résolution :

h_res = 720 : Résolution horizontale, soit le nombre de pixels visibles par ligne
v_res = 480 : Résolution verticale, soit le nombre de lignes visibles dans l'image


Paramètres de timing horizontal :

h_sync = 61 : Durée de l'impulsion de synchronisation horizontale
h_fp = 58 : Front porch horizontal (temps d'attente avant la synchro)
h_bp = 18 : Back porch horizontal (temps d'attente après la synchro)


Paramètres de timing vertical :

v_sync = 5 : Durée de l'impulsion de synchronisation verticale
v_fp = 30 : Front porch vertical (nombre de lignes d'attente avant la synchro)
v_bp = 9 : Back porch vertical (nombre de lignes d'attente après la synchro)

# 2.1.1 Écriture du composant

* un compteur horizontal (h_count) qui boucle de 0 à h_total, et qui génère le signal de synchronisation horizontal (o_hdmi_hs).
![image](https://github.com/user-attachments/assets/2c9241a5-8d39-4920-8788-51a8ce3418ab)


![image](https://github.com/user-attachments/assets/d5f4f7dd-a768-4cb0-8d5b-5a556dd77f33)


