--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     timer_counter - Behavioural
-- Project Name:    soc - peripheral
-- Description:     The system on chip
--
-- Revision     Date       Author     Comments
-- v0.1         20220106   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcodesign.all;

entity soc is
    port (
        PCLK : IN STD_LOGIC;
        PRESETn : IN STD_LOGIC;

        PADDR_mem : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        PPROT_mem : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
        PSELx_mem : OUT STD_LOGIC;
        PENABLE_mem : OUT STD_LOGIC;
        PWRITE_mem : OUT STD_LOGIC;
        PWDATA_mem : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        PSTRB_mem : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
        PREADY_mem : IN STD_LOGIC;
        PRDATA_mem : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        PSLVERR_mem : IN STD_LOGIC;

        PADDR_print : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        PPROT_print : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
        PSELx_print : OUT STD_LOGIC;
        PENABLE_print : OUT STD_LOGIC;
        PWRITE_print : OUT STD_LOGIC;
        PWDATA_print : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        PSTRB_print : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
        PREADY_print : IN STD_LOGIC;
        PRDATA_print : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        PSLVERR_print : IN STD_LOGIC
    );
end entity soc;

architecture Behavioural of soc is

    signal PCLK_i : STD_LOGIC;
    signal PRESETn_i : STD_LOGIC;

    signal PADDR_REQ_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal PPROT_REQ_i : STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
    signal PSELx_REQ_i : STD_LOGIC;
    signal PENABLE_REQ_i : STD_LOGIC;
    signal PWRITE_REQ_i : STD_LOGIC;
    signal PWDATA_REQ_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal PSTRB_REQ_i : STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
    signal PREADY_REQ_i : STD_LOGIC;
    signal PRDATA_REQ_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal PSLVERR_REQ_i : STD_LOGIC;

    signal PADDR_COMP_0_i, PADDR_COMP_1_i, PADDR_COMP_2_i, PADDR_COMP_3_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal PPROT_COMP_0_i, PPROT_COMP_1_i, PPROT_COMP_2_i, PPROT_COMP_3_i : STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
	signal PSELx_COMP_0_i, PSELx_COMP_1_i, PSELx_COMP_2_i, PSELx_COMP_3_i : STD_LOGIC;
	signal PENABLE_COMP_0_i, PENABLE_COMP_1_i, PENABLE_COMP_2_i, PENABLE_COMP_3_i : STD_LOGIC;
	signal PWRITE_COMP_0_i, PWRITE_COMP_1_i, PWRITE_COMP_2_i, PWRITE_COMP_3_i : STD_LOGIC;
	signal PWDATA_COMP_0_i, PWDATA_COMP_1_i, PWDATA_COMP_2_i, PWDATA_COMP_3_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal PSTRB_COMP_0_i, PSTRB_COMP_1_i, PSTRB_COMP_2_i, PSTRB_COMP_3_i : STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
	signal PREADY_COMP_0_i, PREADY_COMP_1_i, PREADY_COMP_2_i, PREADY_COMP_3_i : STD_LOGIC;
	signal PRDATA_COMP_0_i, PRDATA_COMP_1_i, PRDATA_COMP_2_i, PRDATA_COMP_3_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal PSLVERR_COMP_0_i, PSLVERR_COMP_1_i, PSLVERR_COMP_2_i, PSLVERR_COMP_3_i : STD_LOGIC;

    signal mem_valid_i : STD_LOGIC;
    signal mem_instr_i : STD_LOGIC;
    signal mem_addr_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal mem_wdata_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal mem_wstrb_i : STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
    signal mem_ready_i : STD_LOGIC;
    signal mem_rdata_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    PCLK_i <= PCLK;
    PRESETn_i <= PRESETn;

    PADDR_mem <= PADDR_COMP_0_i;
    PPROT_mem <= PPROT_COMP_0_i;
    PSELx_mem <= PSELx_COMP_0_i;
    PENABLE_mem <= PENABLE_COMP_0_i;
    PWRITE_mem <= PWRITE_COMP_0_i;
    PWDATA_mem <= PWDATA_COMP_0_i;
    PSTRB_mem <= PSTRB_COMP_0_i;
    PREADY_COMP_0_i <= PREADY_mem;
    PRDATA_COMP_0_i <= PRDATA_mem;
    PSLVERR_COMP_0_i <= PSLVERR_mem;

    PADDR_print <= PADDR_COMP_1_i;
    PPROT_print <= PPROT_COMP_1_i;
    PSELx_print <= PSELx_COMP_1_i;
    PENABLE_print <= PENABLE_COMP_1_i;
    PWRITE_print <= PWRITE_COMP_1_i;
    PWDATA_print <= PWDATA_COMP_1_i;
    PSTRB_print <= PSTRB_COMP_1_i;
    PREADY_COMP_1_i <= PREADY_print;
    PRDATA_COMP_1_i <= PRDATA_print;
    PSLVERR_COMP_1_i <= PSLVERR_print;


    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------


    -------------------------------------------------------------------------------
    -- APB peripherals
    -------------------------------------------------------------------------------
    APB_counter_inst00: component APB_counter generic map(
        G_BASE_ADDRESS => C_BASE_ADDRESS_2,
        G_HIGH_ADDRESS => C_HIGH_ADDRESS_2) 
    port map(
        PCLK => PCLK_i,
        PRESETn => PRESETn_i,
        PADDR => PADDR_COMP_2_i,
        PPROT => PPROT_COMP_2_i,
        PSELx => PSELx_COMP_2_i,
        PENABLE => PENABLE_COMP_2_i,
        PWRITE => PWRITE_COMP_2_i,
        PWDATA => PWDATA_COMP_2_i,
        PSTRB => PSTRB_COMP_2_i,
        PREADY => PREADY_COMP_2_i,
        PRDATA => PRDATA_COMP_2_i,
        PSLVERR => PSLVERR_COMP_2_i
    );
    
    APB_xoodoo_inst00: component APB_xoodoo generic map(
        G_BASE_ADDRESS => C_BASE_ADDRESS_3,
        G_HIGH_ADDRESS => C_HIGH_ADDRESS_3) 
    port map(
        PCLK => PCLK_i,
        PRESETn => PRESETn_i,
        PADDR => PADDR_COMP_3_i,
        PPROT => PPROT_COMP_3_i,
        PSELx => PSELx_COMP_3_i,
        PENABLE => PENABLE_COMP_3_i,
        PWRITE => PWRITE_COMP_3_i,
        PWDATA => PWDATA_COMP_3_i,
        PSTRB => PSTRB_COMP_3_i,
        PREADY => PREADY_COMP_3_i,
        PRDATA => PRDATA_COMP_3_i,
        PSLVERR => PSLVERR_COMP_3_i
    );

    -------------------------------------------------------------------------------
    -- APB bus
    -------------------------------------------------------------------------------
    apb_bus_inst00: component apb_bus 
        generic map(
            G_BASE_ADDRESS_0 => C_BASE_ADDRESS_0,
            G_HIGH_ADDRESS_0 => C_HIGH_ADDRESS_0,
            G_BASE_ADDRESS_1 => C_BASE_ADDRESS_1,
            G_HIGH_ADDRESS_1 => C_HIGH_ADDRESS_1,
            G_BASE_ADDRESS_2 => C_BASE_ADDRESS_2,
            G_HIGH_ADDRESS_2 => C_HIGH_ADDRESS_2,
            G_BASE_ADDRESS_3 => C_BASE_ADDRESS_3,
            G_HIGH_ADDRESS_3 => C_HIGH_ADDRESS_3)
        port map(
            PCLK => PCLK_i,
            PRESETn => PRESETn_i,
            PADDR_REQ => PADDR_REQ_i,
            PPROT_REQ => PPROT_REQ_i,
            PSELx_REQ => PSELx_REQ_i,
            PENABLE_REQ => PENABLE_REQ_i,
            PWRITE_REQ => PWRITE_REQ_i,
            PWDATA_REQ => PWDATA_REQ_i,
            PSTRB_REQ => PSTRB_REQ_i,
            PREADY_REQ => PREADY_REQ_i,
            PRDATA_REQ => PRDATA_REQ_i,
            PSLVERR_REQ => PSLVERR_REQ_i,
            PADDR_COMP_0 => PADDR_COMP_0_i,
            PPROT_COMP_0 => PPROT_COMP_0_i,
            PSELx_COMP_0 => PSELx_COMP_0_i,
            PENABLE_COMP_0 => PENABLE_COMP_0_i,
            PWRITE_COMP_0 => PWRITE_COMP_0_i,
            PWDATA_COMP_0 => PWDATA_COMP_0_i,
            PSTRB_COMP_0 => PSTRB_COMP_0_i,
            PREADY_COMP_0 => PREADY_COMP_0_i,
            PRDATA_COMP_0 => PRDATA_COMP_0_i,
            PSLVERR_COMP_0 => PSLVERR_COMP_0_i,
            PADDR_COMP_1 => PADDR_COMP_1_i,
            PPROT_COMP_1 => PPROT_COMP_1_i,
            PSELx_COMP_1 => PSELx_COMP_1_i,
            PENABLE_COMP_1 => PENABLE_COMP_1_i,
            PWRITE_COMP_1 => PWRITE_COMP_1_i,
            PWDATA_COMP_1 => PWDATA_COMP_1_i,
            PSTRB_COMP_1 => PSTRB_COMP_1_i,
            PREADY_COMP_1 => PREADY_COMP_1_i,
            PRDATA_COMP_1 => PRDATA_COMP_1_i,
            PSLVERR_COMP_1 => PSLVERR_COMP_1_i,
            PADDR_COMP_2 => PADDR_COMP_2_i,
            PPROT_COMP_2 => PPROT_COMP_2_i,
            PSELx_COMP_2 => PSELx_COMP_2_i,
            PENABLE_COMP_2 => PENABLE_COMP_2_i,
            PWRITE_COMP_2 => PWRITE_COMP_2_i,
            PWDATA_COMP_2 => PWDATA_COMP_2_i,
            PSTRB_COMP_2 => PSTRB_COMP_2_i,
            PREADY_COMP_2 => PREADY_COMP_2_i,
            PRDATA_COMP_2 => PRDATA_COMP_2_i,
            PSLVERR_COMP_2 => PSLVERR_COMP_2_i,
            PADDR_COMP_3 => PADDR_COMP_3_i,
            PPROT_COMP_3 => PPROT_COMP_3_i,
            PSELx_COMP_3 => PSELx_COMP_3_i,
            PENABLE_COMP_3 => PENABLE_COMP_3_i,
            PWRITE_COMP_3 => PWRITE_COMP_3_i,
            PWDATA_COMP_3 => PWDATA_COMP_3_i,
            PSTRB_COMP_3 => PSTRB_COMP_3_i,
            PREADY_COMP_3 => PREADY_COMP_3_i,
            PRDATA_COMP_3 => PRDATA_COMP_3_i,
            PSLVERR_COMP_3 => PSLVERR_COMP_3_i
    );


    -------------------------------------------------------------------------------
    -- PICORV32 + APB adapter
    -------------------------------------------------------------------------------
    picorv32_apb_adapter_inst00: component picorv32_apb_adapter port map(
        PCLK => PCLK_i,
        PRESETn => PRESETn_i,
        PADDR => PADDR_REQ_i,
        PPROT => PPROT_REQ_i,
        PSELx => PSELx_REQ_i,
        PENABLE => PENABLE_REQ_i,
        PWRITE => PWRITE_REQ_i,
        PWDATA => PWDATA_REQ_i,
        PSTRB => PSTRB_REQ_i,
        PREADY => PREADY_REQ_i,
        PRDATA => PRDATA_REQ_i,
        PSLVERR => PSLVERR_REQ_i,
        mem_valid => mem_valid_i,
        mem_instr => mem_instr_i,
        mem_addr => mem_addr_i,
        mem_wdata => mem_wdata_i,
        mem_wstrb => mem_wstrb_i,
        mem_ready => mem_ready_i,
        mem_rdata => mem_rdata_i
    );

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
            clk => PCLK_i,
            resetn => PRESETn_i,
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
            pcpi_valid => open, 
            pcpi_insn => open, 
            pcpi_rs1 => open, 
            pcpi_rs2 => open, 
            pcpi_wr => C_zeroes(0),
            pcpi_rd => C_zeroes,
            pcpi_wait => C_zeroes(0),
            pcpi_ready => C_zeroes(0),
            irq => C_zeroes,
            trap => open,
            eoi => open,
            trace_valid => open,
            trace_data => open
        );

end Behavioural;
