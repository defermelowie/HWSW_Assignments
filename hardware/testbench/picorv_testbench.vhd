--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     picorv_testbench - Behavioural
-- Project Name:    Testbench for PicoRV32
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20211218   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    -- use IEEE.NUMERIC_STD.ALL;


entity picorv_testbench is
    generic (
        G_DATA_WIDTH : integer := 32
    );
end entity picorv_testbench;

architecture Behavioural of picorv_testbench is

    component picorv_mem_model is
        generic (
            G_DATA_WIDTH : integer := 32;
            FNAME_HEX : string := "data.dat";
            FNAME_OUT : string := "data.dat"
        );
        port (
            resetn : IN STD_LOGIC;
            clock : IN STD_LOGIC;
            load_file : IN STD_LOGIC;
            load_file_done : OUT STD_LOGIC;
            mem_valid : IN STD_LOGIC;
            mem_instr : IN STD_LOGIC;
            mem_addr : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_wdata : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_wstrb : IN STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
            mem_ready : OUT STD_LOGIC;
            mem_rdata : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
        );
    end component;

    component top is
        generic (
            G_DATA_WIDTH : integer := 32
        );
        port (
            resetn, reset_processor_n, reset_combined_n : IN STD_LOGIC;
            clock : IN STD_LOGIC;
            mem_valid : OUT STD_LOGIC;
            mem_instr : OUT STD_LOGIC;
            mem_addr : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_wdata : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_wstrb : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
            mem_ready : IN STD_LOGIC;
            mem_rdata : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
        );
    end component;

    signal resetn_i, reset_processor_ni, reset_combined_n : STD_LOGIC;
    signal clock_i : STD_LOGIC;
    signal load_file_i : STD_LOGIC;
    signal load_file_done_i : STD_LOGIC;
    signal mem_valid_i : STD_LOGIC;
    signal mem_instr_i : STD_LOGIC;
    signal mem_addr_i : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal mem_wdata_i : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal mem_wstrb_i : STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
    signal mem_ready_i : STD_LOGIC;
    signal mem_rdata_i : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);

    constant C_zeroes : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0) := (others => '0');
    constant clock_period : time := 10 ns;

begin

    -------------------------------------------------------------------------------
    -- STIMULI
    -------------------------------------------------------------------------------
    reset_combined_n <= resetn_i and reset_processor_ni;
    PSTIM: process
    begin
        resetn_i <= '0';
        reset_processor_ni <= '0';
        load_file_i <= '0';
        wait for clock_period * 10;

        resetn_i <= '1';
        wait for clock_period * 10;

        load_file_i <= '1';
        wait until load_file_done_i = '1';
        wait for clock_period;
        load_file_i <= '0';
        wait for clock_period;

        reset_processor_ni <= '1';

        wait;
    end process;

    -------------------------------------------------------------------------------
    -- top module
    -------------------------------------------------------------------------------
    top_inst00: component top
        generic map (
            G_DATA_WIDTH => G_DATA_WIDTH
        ) port map (
            resetn => resetn_i,
            reset_processor_n => reset_processor_ni,
            reset_combined_n => reset_combined_n,
            clock => clock_i,
            mem_valid => mem_valid_i,
            mem_instr => mem_instr_i,
            mem_addr => mem_addr_i,
            mem_wdata => mem_wdata_i,
            mem_wstrb => mem_wstrb_i,
            mem_ready => mem_ready_i,
            mem_rdata => mem_rdata_i
        );

    -------------------------------------------------------------------------------
    -- MEMORY MODEL
    -------------------------------------------------------------------------------
    picorv_mem_model_inst00: component picorv_mem_model 
        generic map (
            G_DATA_WIDTH => G_DATA_WIDTH, 
            FNAME_HEX => "/home/lowie/Documents/IIW/S8/HW_SW_Codesign/exercises/software/target/firmware.hex",
            FNAME_OUT => "/home/lowie/Documents/IIW/S8/HW_SW_Codesign/exercises/software/target/simulation_output.dat"
        ) port map (
            resetn => resetn_i,
            clock => clock_i,
            load_file => load_file_i,
            load_file_done => load_file_done_i,
            mem_valid => mem_valid_i,
            mem_instr => mem_instr_i,
            mem_addr => mem_addr_i,
            mem_wdata => mem_wdata_i,
            mem_wstrb => mem_wstrb_i,
            mem_ready => mem_ready_i,
            mem_rdata => mem_rdata_i
        );

    -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    PCLK: process
    begin
        clock_i <= '1';
        wait for clock_period/2;
        clock_i <= '0';
        wait for clock_period/2;
    end process PCLK;

end Behavioural;
