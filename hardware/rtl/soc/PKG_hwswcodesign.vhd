--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     PKG_hwswcodesign - Behavioural
-- Project Name:    soc - peripheral
-- Description:     Package for the SOC
--
-- Revision     Date       Author     Comments
-- v0.1         20220106   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

package PKG_hwswcodesign is

    
    constant C_DATA_WIDTH : integer := 32;
    constant C_STRB_WIDTH : integer := C_DATA_WIDTH/8;
    constant C_PROT_WIDTH : integer := 3;
    
    constant C_zeroes : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := (others => '0');

    -- memory map
    constant C_BASE_ADDRESS_0 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"00000000";
    constant C_HIGH_ADDRESS_0 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"00003FFF";
    constant C_BASE_ADDRESS_1 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"80000000";
    constant C_HIGH_ADDRESS_1 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"80000004";
    constant C_BASE_ADDRESS_2 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"81000000";
    constant C_HIGH_ADDRESS_2 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"81000FFF";
    constant C_BASE_ADDRESS_3 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"81100000";
    constant C_HIGH_ADDRESS_3 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"81100FFF";


    component APB_print is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF";
            FNAME_OUT : string := "data.dat"
        );
        port (
            resetn : IN STD_LOGIC;
            clock : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component APB_memory is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component APB_xoodyak is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component APB_dummy is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component APB_sin is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component APB_hamming_distance is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component picorv_APB_mem_model is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF";
            FNAME_HEX : string := "data.dat"
        );
        port (
            resetn : IN STD_LOGIC;
            clock : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component soc is
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
    end component;

    component APB_counter is
        generic (
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    component picorv32_apb_adapter is
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx : OUT STD_LOGIC;
            PENABLE : OUT STD_LOGIC;
            PWRITE : OUT STD_LOGIC;
            PWDATA : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY : IN STD_LOGIC;
            PRDATA : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR : IN STD_LOGIC;
            mem_valid : IN STD_LOGIC;
            mem_instr : IN STD_LOGIC;
            mem_addr : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_wdata : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_wstrb : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            mem_ready : OUT STD_LOGIC;
            mem_rdata : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0)
        );
    end component;

    component apb_bus is
        generic (
            G_BASE_ADDRESS_0 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS_0 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"FFFFFFFF";
            G_BASE_ADDRESS_1 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS_1 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"FFFFFFFF";
            G_BASE_ADDRESS_2 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS_2 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"FFFFFFFF";
            G_BASE_ADDRESS_3 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS_3 : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            -- APB requester memory interface
            PADDR_REQ : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT_REQ : IN STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx_REQ : IN STD_LOGIC;
            PENABLE_REQ : IN STD_LOGIC;
            PWRITE_REQ : IN STD_LOGIC;
            PWDATA_REQ : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB_REQ : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY_REQ : OUT STD_LOGIC;
            PRDATA_REQ : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR_REQ : OUT STD_LOGIC;
            -- APB completer 0
            PADDR_COMP_0 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT_COMP_0 : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx_COMP_0 : OUT STD_LOGIC;
            PENABLE_COMP_0 : OUT STD_LOGIC;
            PWRITE_COMP_0 : OUT STD_LOGIC;
            PWDATA_COMP_0 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB_COMP_0 : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY_COMP_0 : IN STD_LOGIC;
            PRDATA_COMP_0 : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR_COMP_0 : IN STD_LOGIC;
            -- APB completer 1
            PADDR_COMP_1 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT_COMP_1 : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx_COMP_1 : OUT STD_LOGIC;
            PENABLE_COMP_1 : OUT STD_LOGIC;
            PWRITE_COMP_1 : OUT STD_LOGIC;
            PWDATA_COMP_1 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB_COMP_1 : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY_COMP_1 : IN STD_LOGIC;
            PRDATA_COMP_1 : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR_COMP_1 : IN STD_LOGIC;
            -- APB completer 2
            PADDR_COMP_2 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT_COMP_2 : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx_COMP_2 : OUT STD_LOGIC;
            PENABLE_COMP_2 : OUT STD_LOGIC;
            PWRITE_COMP_2 : OUT STD_LOGIC;
            PWDATA_COMP_2 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB_COMP_2 : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY_COMP_2 : IN STD_LOGIC;
            PRDATA_COMP_2 : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR_COMP_2 : IN STD_LOGIC;

            -- APB completer 3
            PADDR_COMP_3 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PPROT_COMP_3 : OUT STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
            PSELx_COMP_3 : OUT STD_LOGIC;
            PENABLE_COMP_3 : OUT STD_LOGIC;
            PWRITE_COMP_3 : OUT STD_LOGIC;
            PWDATA_COMP_3 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSTRB_COMP_3 : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            PREADY_COMP_3 : IN STD_LOGIC;
            PRDATA_COMP_3 : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            PSLVERR_COMP_3 : IN STD_LOGIC
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
            mem_addr : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_wdata : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_wstrb : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            mem_rdata : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_la_read : OUT STD_LOGIC;
            mem_la_write : OUT STD_LOGIC;
            mem_la_addr : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_la_wdata : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            mem_la_wstrb : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
            pcpi_valid : OUT STD_LOGIC;
            pcpi_insn : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            pcpi_rs1 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            pcpi_rs2 : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            pcpi_wr : IN STD_LOGIC;
            pcpi_rd : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            pcpi_wait : IN STD_LOGIC;
            pcpi_ready : IN STD_LOGIC;
            irq : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            eoi : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
            trace_valid : OUT STD_LOGIC;
            trace_data : OUT STD_LOGIC_VECTOR(36-1 downto 0)
        );
    end component;

end package;

package body PKG_hwswcodesign is

end package body;