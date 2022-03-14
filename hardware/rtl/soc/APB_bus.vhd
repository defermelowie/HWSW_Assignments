--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     picorv32_apb_adapter - Behavioural
-- Project Name:    PicoRV32 - peripheral
-- Description:     This compenent describes an adapater for the PicoRV32.
--					It takes the native memory interface and converts it to a
--					APB interface.
--
-- Revision     Date       Author     Comments
-- v0.1         20220106   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcodesign.ALL;

entity apb_bus is
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
end entity apb_bus;

architecture Behavioural of apb_bus is


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

    signal within_addressrange_0, within_addressrange_1, within_addressrange_2, within_addressrange_3 : STD_LOGIC; 

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
	PCLK_i <= PCLK;
	PRESETn_i <= PRESETn;

    PADDR_REQ_i <= PADDR_REQ;
    PPROT_REQ_i <= PPROT_REQ;
    PSELx_REQ_i <= PSELx_REQ;
    PENABLE_REQ_i <= PENABLE_REQ;
    PWRITE_REQ_i <= PWRITE_REQ;
    PWDATA_REQ_i <= PWDATA_REQ;
    PSTRB_REQ_i <= PSTRB_REQ;
    PREADY_REQ <= PREADY_REQ_i;
    PRDATA_REQ <= PRDATA_REQ_i;
    PSLVERR_REQ <= PSLVERR_REQ_i;

    PADDR_COMP_0 <= PADDR_COMP_0_i;
    PPROT_COMP_0 <= PPROT_COMP_0_i;
    PSELx_COMP_0 <= PSELx_COMP_0_i;
    PENABLE_COMP_0 <= PENABLE_COMP_0_i;
    PWRITE_COMP_0 <= PWRITE_COMP_0_i;
    PWDATA_COMP_0 <= PWDATA_COMP_0_i;
    PSTRB_COMP_0 <= PSTRB_COMP_0_i;
    PREADY_COMP_0_i <= PREADY_COMP_0;
    PRDATA_COMP_0_i <= PRDATA_COMP_0;
    PSLVERR_COMP_0_i <= PSLVERR_COMP_0;

    PADDR_COMP_1 <= PADDR_COMP_1_i;
    PPROT_COMP_1 <= PPROT_COMP_1_i;
    PSELx_COMP_1 <= PSELx_COMP_1_i;
    PENABLE_COMP_1 <= PENABLE_COMP_1_i;
    PWRITE_COMP_1 <= PWRITE_COMP_1_i;
    PWDATA_COMP_1 <= PWDATA_COMP_1_i;
    PSTRB_COMP_1 <= PSTRB_COMP_1_i;
    PREADY_COMP_1_i <= PREADY_COMP_1;
    PRDATA_COMP_1_i <= PRDATA_COMP_1;
    PSLVERR_COMP_1_i <= PSLVERR_COMP_1;

    PADDR_COMP_2 <= PADDR_COMP_2_i;
    PPROT_COMP_2 <= PPROT_COMP_2_i;
    PSELx_COMP_2 <= PSELx_COMP_2_i;
    PENABLE_COMP_2 <= PENABLE_COMP_2_i;
    PWRITE_COMP_2 <= PWRITE_COMP_2_i;
    PWDATA_COMP_2 <= PWDATA_COMP_2_i;
    PSTRB_COMP_2 <= PSTRB_COMP_2_i;
    PREADY_COMP_2_i <= PREADY_COMP_2;
    PRDATA_COMP_2_i <= PRDATA_COMP_2;
    PSLVERR_COMP_2_i <= PSLVERR_COMP_2;

    PADDR_COMP_3 <= PADDR_COMP_3_i;
    PPROT_COMP_3 <= PPROT_COMP_3_i;
    PSELx_COMP_3 <= PSELx_COMP_3_i;
    PENABLE_COMP_3 <= PENABLE_COMP_3_i;
    PWRITE_COMP_3 <= PWRITE_COMP_3_i;
    PWDATA_COMP_3 <= PWDATA_COMP_3_i;
    PSTRB_COMP_3 <= PSTRB_COMP_3_i;
    PREADY_COMP_3_i <= PREADY_COMP_3;
    PRDATA_COMP_3_i <= PRDATA_COMP_3;
    PSLVERR_COMP_3_i <= PSLVERR_COMP_3;


    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    within_addressrange_0 <= '1' when (PADDR_REQ_i >= G_BASE_ADDRESS_0) and (PADDR_REQ_i <= G_HIGH_ADDRESS_0) else '0';
    within_addressrange_1 <= '1' when (PADDR_REQ_i >= G_BASE_ADDRESS_1) and (PADDR_REQ_i <= G_HIGH_ADDRESS_1) else '0';
    within_addressrange_2 <= '1' when (PADDR_REQ_i >= G_BASE_ADDRESS_2) and (PADDR_REQ_i <= G_HIGH_ADDRESS_2) else '0';
    within_addressrange_3 <= '1' when (PADDR_REQ_i >= G_BASE_ADDRESS_3) and (PADDR_REQ_i <= G_HIGH_ADDRESS_3) else '0';


    -------------------------------------------------------------------------------
    -- MAPPING
    -------------------------------------------------------------------------------

    -- from completers to requester
    PREADY_REQ_i <= (PREADY_COMP_0_i and within_addressrange_0) 
        OR (PREADY_COMP_1_i and within_addressrange_1)
        OR (PREADY_COMP_2_i and within_addressrange_2)
        OR (PREADY_COMP_3_i and within_addressrange_3);
    PSLVERR_REQ_i <= (PSLVERR_COMP_0_i and within_addressrange_0) 
        OR (PSLVERR_COMP_1_i and within_addressrange_1)
        OR (PSLVERR_COMP_2_i and within_addressrange_2)
        OR (PSLVERR_COMP_3_i and within_addressrange_3);
    
    PMUX_RDATA: process(within_addressrange_0, PRDATA_COMP_0_i,
            within_addressrange_1, PRDATA_COMP_1_i, 
            within_addressrange_2, PRDATA_COMP_2_i,
            within_addressrange_3, PRDATA_COMP_3_i)
    begin
        if within_addressrange_0 = '1' then 
            PRDATA_REQ_i <= PRDATA_COMP_0_i;
        elsif within_addressrange_1 = '1' then 
            PRDATA_REQ_i <= PRDATA_COMP_1_i;
        elsif within_addressrange_2 = '1' then 
            PRDATA_REQ_i <= PRDATA_COMP_2_i;
        elsif within_addressrange_3 = '1' then 
            PRDATA_REQ_i <= PRDATA_COMP_3_i;
        else
            PRDATA_REQ_i <= (others => '0');
        end if;
    end process;

    -- from requester to completer 0
    PADDR_COMP_0_i <= PADDR_REQ_i;
    PPROT_COMP_0_i <= PPROT_REQ_i;
    PSELx_COMP_0_i <= PSELx_REQ_i and within_addressrange_0;
    PENABLE_COMP_0_i <= PENABLE_REQ_i;
    PWRITE_COMP_0_i <= PWRITE_REQ_i;
    PWDATA_COMP_0_i <= PWDATA_REQ_i;
    PSTRB_COMP_0_i <= PSTRB_REQ_i;
    
    -- from requester to completer 1
    PADDR_COMP_1_i <= PADDR_REQ_i;
    PPROT_COMP_1_i <= PPROT_REQ_i;
    PSELx_COMP_1_i <= PSELx_REQ_i and within_addressrange_1;
    PENABLE_COMP_1_i <= PENABLE_REQ_i;
    PWRITE_COMP_1_i <= PWRITE_REQ_i;
    PWDATA_COMP_1_i <= PWDATA_REQ_i;
    PSTRB_COMP_1_i <= PSTRB_REQ_i;

    -- from requester to completer 2
    PADDR_COMP_2_i <= PADDR_REQ_i;
    PPROT_COMP_2_i <= PPROT_REQ_i;
    PSELx_COMP_2_i <= PSELx_REQ_i and within_addressrange_2;
    PENABLE_COMP_2_i <= PENABLE_REQ_i;
    PWRITE_COMP_2_i <= PWRITE_REQ_i;
    PWDATA_COMP_2_i <= PWDATA_REQ_i;
    PSTRB_COMP_2_i <= PSTRB_REQ_i;

    -- from requester to completer 3
    PADDR_COMP_3_i <= PADDR_REQ_i;
    PPROT_COMP_3_i <= PPROT_REQ_i;
    PSELx_COMP_3_i <= PSELx_REQ_i and within_addressrange_3;
    PENABLE_COMP_3_i <= PENABLE_REQ_i;
    PWRITE_COMP_3_i <= PWRITE_REQ_i;
    PWDATA_COMP_3_i <= PWDATA_REQ_i;
    PSTRB_COMP_3_i <= PSTRB_REQ_i;

end Behavioural;
