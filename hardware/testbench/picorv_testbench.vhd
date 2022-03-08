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

    component pcpi_hwswcd_hd is
        port (
            resetn : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pcpi_valid : IN STD_LOGIC;
            pcpi_insn : IN STD_LOGIC_VECTOR(32-1 downto 0);
            pcpi_rs1 : IN STD_LOGIC_VECTOR(32-1 downto 0);
            pcpi_rs2 : IN STD_LOGIC_VECTOR(32-1 downto 0);
            pcpi_wr : OUT STD_LOGIC;
            pcpi_rd : OUT STD_LOGIC_VECTOR(32-1 downto 0);
            pcpi_wait : OUT STD_LOGIC;
            pcpi_ready : OUT STD_LOGIC
        );
    end component;

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


    component picorv32 is
        generic(
            ENABLE_COUNTERS : STD_LOGIC := '1';
            ENABLE_COUNTERS64 : STD_LOGIC := '1';
            ENABLE_REGS_16_31 : STD_LOGIC := '1';
            ENABLE_REGS_DUALPORT : STD_LOGIC := '1';
            LATCHED_MEM_RDATA : STD_LOGIC := '0';
            TWO_STAGE_SHIFT : STD_LOGIC := '1';
            BARREL_SHIFTER : STD_LOGIC := '0';
            TWO_CYCLE_COMPARE : STD_LOGIC := '0';
            TWO_CYCLE_ALU : STD_LOGIC := '0';
            COMPRESSED_ISA : STD_LOGIC := '0';
            CATCH_MISALIGN : STD_LOGIC := '1';
            CATCH_ILLINSN : STD_LOGIC := '1';
            ENABLE_PCPI : STD_LOGIC := '0';
            ENABLE_MUL : STD_LOGIC := '0';
            ENABLE_FAST_MUL : STD_LOGIC := '0';
            ENABLE_DIV : STD_LOGIC := '0';
            ENABLE_IRQ : STD_LOGIC := '0';
            ENABLE_IRQ_QREGS : STD_LOGIC := '1';
            ENABLE_IRQ_TIMER : STD_LOGIC := '1';
            ENABLE_TRACE : STD_LOGIC := '0';
            REGS_INIT_ZERO : STD_LOGIC := '0';
            MASKED_IRQ : STD_LOGIC_VECTOR(31 downto 0) := x"0000_0000";
            LATCHED_IRQ : STD_LOGIC_VECTOR(31 downto 0) := x"ffff_ffff";
            PROGADDR_RESET : STD_LOGIC_VECTOR(31 downto 0) := x"0000_0000";
            PROGADDR_IRQ : STD_LOGIC_VECTOR(31 downto 0) := x"0000_0010";
            STACKADDR : STD_LOGIC_VECTOR(31 downto 0) := x"ffff_ffff"
        );
        port(
            clk : IN STD_LOGIC;
            resetn : IN STD_LOGIC;
            trap : OUT STD_LOGIC;
            mem_valid : OUT STD_LOGIC;
            mem_instr : OUT STD_LOGIC;
            mem_ready : IN STD_LOGIC;
            mem_addr : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_wdata : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_wstrb : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
            mem_rdata : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_la_read : OUT STD_LOGIC;
            mem_la_write : OUT STD_LOGIC;
            mem_la_addr : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_la_wdata : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            mem_la_wstrb : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
            pcpi_valid : OUT STD_LOGIC;
            pcpi_insn : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            pcpi_rs1 : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            pcpi_rs2 : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            pcpi_wr : IN STD_LOGIC;
            pcpi_rd : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            pcpi_wait : IN STD_LOGIC;
            pcpi_ready : IN STD_LOGIC;
            irq : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            eoi : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            trace_valid : OUT STD_LOGIC;
            trace_data : OUT STD_LOGIC_VECTOR(36-1 downto 0)
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

    signal pcpi_valid : STD_LOGIC;
    signal pcpi_insn : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal pcpi_rs1 : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal pcpi_rs2 : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal pcpi_wr : STD_LOGIC;
    signal pcpi_rd : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal pcpi_wait : STD_LOGIC;
    signal pcpi_ready : STD_LOGIC;

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
    -- pcpi - coprocessor
    -------------------------------------------------------------------------------

    hammingd_inst00: component pcpi_hwswcd_hd
        port map(
            resetn => resetn_i,
            clk => clock_i,
            pcpi_valid => pcpi_valid,
            pcpi_insn => pcpi_insn,
            pcpi_rs1 => pcpi_rs1,
            pcpi_rs2 => pcpi_rs2,
            pcpi_wr => pcpi_wr,
            pcpi_rd => pcpi_rd,
            pcpi_wait => pcpi_wait,
            pcpi_ready => pcpi_ready
        );

    -------------------------------------------------------------------------------
    -- RISC-V - PicoRV32
    -------------------------------------------------------------------------------
    picorv32_inst00: component picorv32
        generic map(
            ENABLE_COUNTERS => '1',
            ENABLE_COUNTERS64 => '1',
            ENABLE_REGS_16_31 => '1',
            ENABLE_REGS_DUALPORT => '1',
            LATCHED_MEM_RDATA => '0',
            TWO_STAGE_SHIFT => '1',
            BARREL_SHIFTER => '0',
            TWO_CYCLE_COMPARE => '0',
            TWO_CYCLE_ALU => '0',
            COMPRESSED_ISA => '0',
            CATCH_MISALIGN => '1',
            CATCH_ILLINSN => '1',
            ENABLE_PCPI => '1',
            ENABLE_MUL => '0',
            ENABLE_FAST_MUL => '0',
            ENABLE_DIV => '0',
            ENABLE_IRQ => '0',
            ENABLE_IRQ_QREGS => '1',
            ENABLE_IRQ_TIMER => '1',
            ENABLE_TRACE => '0',
            REGS_INIT_ZERO => '0',
            MASKED_IRQ => x"0000_0000",
            LATCHED_IRQ => x"ffff_ffff",
            PROGADDR_RESET => x"0000_0000",
            PROGADDR_IRQ => x"0000_0010",
            STACKADDR => x"ffff_ffff"
        )
        port map (
            clk => clock_i,
            resetn => reset_combined_n,
            mem_valid => mem_valid_i,
            mem_instr => mem_instr_i,
            mem_addr => mem_addr_i,
            mem_wdata => mem_wdata_i,
            mem_wstrb => mem_wstrb_i,
            mem_ready => mem_ready_i,
            mem_rdata => mem_rdata_i,
            mem_la_read => open, 
            mem_la_write => open, 
            mem_la_addr => open, 
            mem_la_wdata => open, 
            mem_la_wstrb => open, 
            pcpi_valid => pcpi_valid, 
            pcpi_insn => pcpi_insn, 
            pcpi_rs1 => pcpi_rs1, 
            pcpi_rs2 => pcpi_rs2, 
            pcpi_wr => pcpi_wr,
            pcpi_rd => pcpi_rd,
            pcpi_wait => pcpi_wait,
            pcpi_ready => pcpi_ready,
            irq => C_zeroes,
            trap => open,
            eoi => open,
            trace_valid => open,
            trace_data => open
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
