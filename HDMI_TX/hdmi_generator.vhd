LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY hdmi_generator IS
	GENERIC (
		-- Resolution
		h_res : NATURAL := 720;
		v_res : NATURAL := 480;
		-- Timings magic values (480p)
		h_sync : NATURAL := 61;
		h_fp : NATURAL := 58;
		h_bp : NATURAL := 18;
		v_sync : NATURAL := 5;
		v_fp : NATURAL := 30;
		v_bp : NATURAL := 9
	);
	PORT (
		i_clk : IN STD_LOGIC;
		i_reset_n : IN STD_LOGIC;
		o_hdmi_hs : OUT STD_LOGIC;
		o_hdmi_vs : OUT STD_LOGIC;
		o_hdmi_de : OUT STD_LOGIC;
		o_pixel_en : OUT STD_LOGIC;
		o_pixel_address : OUT NATURAL RANGE 0 TO (h_res * v_res - 1);
		o_x_counter : OUT NATURAL RANGE 0 TO (h_res - 1);
		o_y_counter : OUT NATURAL RANGE 0 TO (v_res - 1);
		o_pixel_pos_x : OUT NATURAL RANGE 0 TO (h_res - 1);
		o_pixel_pos_y : OUT NATURAL RANGE 0 TO (v_res - 1);
		o_new_frame : OUT STD_LOGIC
	);
END hdmi_generator;
ARCHITECTURE rtl OF hdmi_generator IS
	-- Constantes
	CONSTANT h_total : NATURAL := h_res + h_fp + h_sync + h_bp;
	CONSTANT v_total : NATURAL := v_res + v_fp + v_sync + v_bp;
	-- Signaux internes
	SIGNAL h_count : NATURAL RANGE 0 TO h_total - 1;
	SIGNAL v_count : NATURAL RANGE 0 TO v_total - 1;
	SIGNAL h_act : STD_LOGIC;
	SIGNAL v_act : STD_LOGIC;

	SIGNAL r_pixel_counter : NATURAL RANGE 0 TO (h_res * v_res);

BEGIN
	-- Process des compteurs
	PROCESS (i_clk, i_reset_n)
BEGIN
    IF i_reset_n = '0' THEN
        h_count <= 0;
        v_count <= 0;
        h_act <= '0';
        v_act <= '0';
        r_pixel_counter <= 0;
    ELSIF rising_edge(i_clk) THEN
        -- Compteur horizontal
        IF h_count = h_total - 1 THEN
            h_count <= 0;
            -- Compteur vertical
            IF v_count = v_total - 1 THEN
                v_count <= 0;
            ELSE
                v_count <= v_count + 1;
            END IF;
        ELSE
            h_count <= h_count + 1;
        END IF;

        -- Zone active horizontale
        IF h_count < h_res THEN
            h_act <= '1';
        ELSE
            h_act <= '0';
        END IF;

        -- Zone active verticale
        IF v_count < v_res THEN
            v_act <= '1';
        ELSE
            v_act <= '0';
        END IF;

        -- Compteur pixel_de
        IF h_act = '1' AND v_act = '1' THEN
            IF r_pixel_counter = (h_res * v_res - 1) THEN
                r_pixel_counter <= 0;
            ELSE
                r_pixel_counter <= r_pixel_counter + 1;
            END IF;
        ELSIF h_count = 0 AND v_count = 0 THEN
            r_pixel_counter <= 0;
        END IF;
    END IF;
END PROCESS;

	-- Signaux de synchronisation
	o_hdmi_hs <= '0' WHEN (h_count >= (h_res + h_fp) AND h_count < (h_res + h_fp + h_sync)) ELSE
		'1';
	o_hdmi_vs <= '0' WHEN (v_count >= (v_res + v_fp) AND v_count < (v_res + v_fp + v_sync)) ELSE
		'1';
	o_hdmi_de <= '1' WHEN (h_act = '1' AND v_act = '1') ELSE
		'0';



		o_pixel_address <= r_pixel_counter;

	o_x_counter <= h_count WHEN h_count < h_res ELSE
		0;
	o_y_counter <= v_count WHEN v_count < v_res ELSE
		0;
	o_pixel_pos_x <= h_count WHEN h_count < h_res ELSE
		0;
	o_pixel_pos_y <= v_count WHEN v_count < v_res ELSE
		0;

	o_new_frame <= '1' WHEN h_count = 0 AND v_count = 0 ELSE
		'0';
END ARCHITECTURE rtl;