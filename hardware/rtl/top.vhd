---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: top.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 10 March 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    -- use IEEE.NUMERIC_STD.ALL;

entity top is
    generic (
        G_DATA_WIDTH : integer := 32
    );
    port (
        resetn, reset_processor_n, reset_combined_n : IN STD_LOGIC;
        clock : IN STD_LOGIC;
        mem_valid : OUT STD_LOGIC;
        mem_instr : OUT STD_LOGIC;
        mem_ready : IN STD_LOGIC;
        mem_addr : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
        mem_wdata : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
        mem_wstrb : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
        mem_rdata : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
    );
end entity top;

architecture rtl of top is

    -- component pcpi_avg is
    --     port (
    --         resetn : IN STD_LOGIC;
    --         clk : IN STD_LOGIC;
    --         pcpi_valid : IN STD_LOGIC;
    --         pcpi_insn : IN STD_LOGIC_VECTOR(32-1 downto 0);
    --         pcpi_rs1 : IN STD_LOGIC_VECTOR(32-1 downto 0);
    --         pcpi_rs2 : IN STD_LOGIC_VECTOR(32-1 downto 0);
    --         pcpi_wr : OUT STD_LOGIC;
    --         pcpi_rd : OUT STD_LOGIC_VECTOR(32-1 downto 0);
    --         pcpi_wait : OUT STD_LOGIC;
    --         pcpi_ready : OUT STD_LOGIC
    --     );
    -- end component;

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

    signal resetn_i, reset_processor_ni : STD_LOGIC;
    signal clock_i : STD_LOGIC;
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

begin

    -------------------------------------------------------------------------------
    -- delocalize inputs
    -------------------------------------------------------------------------------
    resetn_i <= resetn;
    reset_processor_ni <= reset_processor_n;
    clock_i <= clock;
    mem_valid <= mem_valid_i;
    mem_instr <= mem_instr_i;
    mem_addr <= mem_addr_i;
    mem_wdata <= mem_wdata_i;
    mem_wstrb <= mem_wstrb_i;
    mem_ready_i <= mem_ready;
    mem_rdata_i <= mem_rdata;

    -------------------------------------------------------------------------------
    -- pcpi - coprocessor
    -------------------------------------------------------------------------------
    -- avg_inst00: component pcpi_avg
    --     port map(
    --         resetn => resetn_i,
    --         clk => clock_i,
    --         pcpi_valid => pcpi_valid,
    --         pcpi_insn => pcpi_insn,
    --         pcpi_rs1 => pcpi_rs1,
    --         pcpi_rs2 => pcpi_rs2,
    --         pcpi_wr => pcpi_wr,
    --         pcpi_rd => pcpi_rd,
    --         pcpi_wait => pcpi_wait,
    --         pcpi_ready => pcpi_ready
    --     );

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
            ENABLE_PCPI => '0',
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
    
end architecture rtl;