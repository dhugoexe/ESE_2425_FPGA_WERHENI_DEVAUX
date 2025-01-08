LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hdmi_generator_tb IS
END hdmi_generator_tb;

ARCHITECTURE tb OF hdmi_generator_tb IS
    
    -- Constantes pour test rapide
    CONSTANT h_res_test : NATURAL := 20; -- Valeurs réduites pour test
    CONSTANT h_fp_test : NATURAL := 2;
    CONSTANT h_sync_test : NATURAL := 4;
    CONSTANT h_bp_test : NATURAL := 2;

    CONSTANT v_res_test : NATURAL := 5; -- Valeurs réduites pour test
    CONSTANT v_fp_test : NATURAL := 1;
    CONSTANT v_sync_test : NATURAL := 1;
    CONSTANT v_bp_test : NATURAL := 1;

    -- Signaux de test
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset_n : STD_LOGIC := '0';
    SIGNAL hdmi_hs : STD_LOGIC;
    SIGNAL hdmi_vs : STD_LOGIC;
    SIGNAL hdmi_de : STD_LOGIC;
    SIGNAL pixel_address : NATURAL RANGE 0 TO (h_res_test * v_res_test);
    SIGNAL x_counter : NATURAL RANGE 0 TO (h_res_test - 1);
    SIGNAL y_counter : NATURAL RANGE 0 TO (v_res_test - 1);
    SIGNAL new_frame : STD_LOGIC;

BEGIN
    -- Instanciation du DUT avec valeurs de test
    dut : ENTITY work.hdmi_generator
        GENERIC MAP(
            h_res => h_res_test,
            h_fp => h_fp_test,
            h_sync => h_sync_test,
            h_bp => h_bp_test,
            v_res => v_res_test,
            v_fp => v_fp_test,
            v_sync => v_sync_test,
            v_bp => v_bp_test
        )
        PORT MAP(
            i_clk => clk,
            i_reset_n => reset_n,
            o_hdmi_hs => hdmi_hs,
            o_hdmi_vs => hdmi_vs,
            o_hdmi_de => hdmi_de,
            o_pixel_address => pixel_address,
            o_x_counter => x_counter,
            o_y_counter => y_counter,
            o_new_frame => new_frame
        );

    -- Génération de l'horloge
    clk <= NOT clk AFTER 5 ns;

    -- Process de stimuli
    PROCESS
    BEGIN
        -- Reset initial
        reset_n <= '0';
        WAIT FOR 100 ns;
        reset_n <= '1';

        -- Attente de quelques cycles horizontaux complets
        WAIT FOR 1000 ns;

        WAIT;
    END PROCESS;

END ARCHITECTURE tb;