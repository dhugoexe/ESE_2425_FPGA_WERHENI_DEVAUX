library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library pll;
use pll.all;

entity DE10_Nano_HDMI_TX is
    port (
        -- ADC
        ADC_CONVST         : out STD_LOGIC;
        ADC_SCK            : out STD_LOGIC;
        ADC_SDI            : out STD_LOGIC;
        ADC_SDO            : in STD_LOGIC;

        -- ARDUINO
        ARDUINO_IO         : inout STD_LOGIC_VECTOR(15 downto 0);
        ARDUINO_RESET_N    : inout STD_LOGIC;

        -- FPGA
        FPGA_CLK1_50       : in STD_LOGIC;
        FPGA_CLK2_50       : in STD_LOGIC;
        FPGA_CLK3_50       : in STD_LOGIC;

        -- GPIO
        GPIO_0             : inout STD_LOGIC_VECTOR(35 downto 0);
        GPIO_1             : inout STD_LOGIC_VECTOR(35 downto 0);

        -- HDMI
        HDMI_I2C_SCL       : inout STD_LOGIC;
        HDMI_I2C_SDA       : inout STD_LOGIC;
        HDMI_I2S           : inout STD_LOGIC;
        HDMI_LRCLK         : inout STD_LOGIC;
        HDMI_MCLK          : inout STD_LOGIC;
        HDMI_SCLK          : inout STD_LOGIC;
        HDMI_TX_CLK        : out STD_LOGIC;
        HDMI_TX_D          : out STD_LOGIC_VECTOR(23 downto 0);
        HDMI_TX_DE         : out STD_LOGIC;
        HDMI_TX_HS         : out STD_LOGIC;
        HDMI_TX_INT        : in STD_LOGIC;
        HDMI_TX_VS         : out STD_LOGIC;

        -- KEY
        KEY                : in STD_LOGIC_VECTOR(1 downto 0);

        -- LED
        LED                : out STD_LOGIC_VECTOR(7 downto 0);

        -- SW
        SW                 : in STD_LOGIC_VECTOR(3 downto 0)
    );
end entity DE10_Nano_HDMI_TX;

architecture rtl of DE10_Nano_HDMI_TX is
    component I2C_HDMI_Config 
        port (
            iCLK : in std_logic;
            iRST_N : in std_logic;
            I2C_SCLK : out std_logic;
            I2C_SDAT : inout std_logic;
            HDMI_TX_INT  : in std_logic
        );
     end component;
     
    component pll 
        port (
            refclk : in std_logic;
            rst : in std_logic;
            outclk_0 : out std_logic;
            locked : out std_logic
        );
    end component;
	 
	 component dpram is
        generic (
            mem_size    : natural := 95 * 95;
            data_width  : natural := 8
        );
        port (   
            i_clk_a     : in std_logic;
            i_clk_b     : in std_logic;
            i_data_a    : in std_logic_vector(data_width-1 downto 0);
            i_data_b    : in std_logic_vector(data_width-1 downto 0);
            i_addr_a    : in natural range 0 to mem_size-1;
            i_addr_b    : in natural range 0 to mem_size-1;
            i_we_a      : in std_logic := '1';
            i_we_b      : in std_logic := '1';
            o_q_a       : out std_logic_vector(data_width-1 downto 0);
            o_q_b       : out std_logic_vector(data_width-1 downto 0)
        );
    end component;

	 CONSTANT h_res : NATURAL := 720;
    CONSTANT v_res : NATURAL := 480;
	 
    signal vpg_pclk : std_logic;        -- 27MHz
    signal reset_n : std_logic;
    signal pixel_en : std_logic;
    SIGNAL pixel_address : NATURAL RANGE 0 TO (h_res * v_res);
    SIGNAL x_counter : NATURAL RANGE 0 TO (h_res - 1);
    SIGNAL y_counter : NATURAL RANGE 0 TO (v_res - 1);
	 SIGNAL new_frame : STD_LOGIC;
	 
	 constant LOGO_WIDTH  : natural := 95;
    constant LOGO_HEIGHT : natural := 95;
    signal ram_addr : natural range 0 to (LOGO_WIDTH * LOGO_HEIGHT - 1);
    signal ram_data : std_logic_vector(7 downto 0);
    signal in_logo_area : boolean;
    
begin
    HDMI_TX_CLK <= vpg_pclk;
    
    -- Generates the clock required for HDMI
    pll0 : component pll 
        port map (
            refclk => FPGA_CLK2_50,
            rst => not(KEY(0)),
            outclk_0 => vpg_pclk,
            locked => reset_n
        );
    
    -- Generates the signals for HDMI IC
    -- Gives an address for the frame buffer
    -- Or x/y coordinates for the sprite generator
    hdmi_generator0 : entity work.hdmi_generator 
        port map (                                    
            i_clk => vpg_pclk,
            i_reset_n => reset_n,
            o_hdmi_hs => HDMI_TX_HS,
            o_hdmi_vs => HDMI_TX_VS,
            o_hdmi_de => HDMI_TX_DE,
            o_pixel_en => pixel_en,
            o_pixel_address => pixel_address,
            o_x_counter => x_counter,
            o_y_counter => y_counter,
            o_new_frame => new_frame
        );
		  
	logo_ram : dpram
        generic map (
            mem_size => LOGO_WIDTH * LOGO_HEIGHT,
            data_width => 8
        )
        port map (
            i_clk_a  => vpg_pclk,
            i_clk_b  => vpg_pclk,
            i_data_a => (others => '0'),
            i_data_b => (others => '0'),
            i_addr_a => ram_addr,
            i_addr_b => 0,
            i_we_a   => '0',
            i_we_b   => '0',
            o_q_a    => ram_data,
            o_q_b    => open
        );

       -- Logique pour déterminer si on est dans la zone du logo
    in_logo_area <= (x_counter < LOGO_WIDTH) and (y_counter < LOGO_HEIGHT);

    -- Calcul de l'adresse RAM pour le logo
    ram_addr <= y_counter * LOGO_WIDTH + x_counter when in_logo_area else 0;

    -- Processus pour l'affichage
    process(vpg_pclk)
    begin
        if rising_edge(vpg_pclk) then
            if in_logo_area then
                HDMI_TX_D <= ram_data & ram_data & ram_data;
            else
                HDMI_TX_D <= std_logic_vector(to_unsigned(y_counter, 8)) & x"00" & std_logic_vector(to_unsigned(x_counter, 8));
            end if;
        end if;
    end process;
    
    -- Configures the HDMI IC through I2C. It's verilog, thanks Terasic (but you don't want to see the code...)
    I2C_HDMI_Config0 : component I2C_HDMI_Config 
        port map (
            iCLK => FPGA_CLK1_50,
            iRST_N => reset_n,
            I2C_SCLK => HDMI_I2C_SCL,
            I2C_SDAT => HDMI_I2C_SDA,
            HDMI_TX_INT => HDMI_TX_INT
     );
end architecture rtl;
