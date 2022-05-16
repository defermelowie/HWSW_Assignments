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

entity picorv32_apb_adapter is
    port (

		PCLK : IN STD_LOGIC;
        PRESETn : IN STD_LOGIC;

		-- APB requester memory interface
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

		-- Native PicoRV32 memory interface
        mem_valid : IN STD_LOGIC;
        mem_instr : IN STD_LOGIC;
        mem_addr : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        mem_wdata : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        mem_wstrb : IN STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
        mem_ready : OUT STD_LOGIC;
        mem_rdata : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0)
    );
end entity picorv32_apb_adapter;

architecture Behavioural of picorv32_apb_adapter is


	signal PCLK_i : STD_LOGIC;
	signal PRESETn_i : STD_LOGIC;
	signal PADDR_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal PPROT_i : STD_LOGIC_VECTOR(C_PROT_WIDTH-1 downto 0);
	signal PSELx_i : STD_LOGIC;
	signal PENABLE_i : STD_LOGIC;
	signal PWRITE_i : STD_LOGIC;
	signal PWDATA_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal PSTRB_i : STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
	signal PREADY_i : STD_LOGIC;
	signal PRDATA_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal PSLVERR_i : STD_LOGIC;
	signal mem_valid_i : STD_LOGIC;
	signal mem_instr_i : STD_LOGIC;
	signal mem_addr_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal mem_wdata_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
	signal mem_wstrb_i : STD_LOGIC_VECTOR(C_STRB_WIDTH-1 downto 0);
	signal mem_ready_i : STD_LOGIC;
	signal mem_rdata_i : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

	signal mem_valid_d : STD_LOGIC;

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
	PCLK_i <= PCLK;
	PRESETn_i <= PRESETn;
	PADDR <= PADDR_i;
	PPROT <= PPROT_i;
	PSELx <= PSELx_i;
	PENABLE <= PENABLE_i;
	PWRITE <= PWRITE_i;
	PWDATA <= PWDATA_i;
	PSTRB <= PSTRB_i;
	PREADY_i <= PREADY;
	PRDATA_i <= PRDATA;
	PSLVERR_i <= PSLVERR; -- ingored
	mem_valid_i <= mem_valid;
	mem_instr_i <= mem_instr; -- ignored
	mem_addr_i <= mem_addr;
	mem_wdata_i <= mem_wdata;
	mem_wstrb_i <= mem_wstrb;
	mem_ready <= mem_ready_i;
	mem_rdata <= mem_rdata_i;


	-------------------------------------------------------------------------------
    -- MAPPING
    -------------------------------------------------------------------------------
	PADDR_i <= mem_addr_i;
	PWDATA_i <= mem_wdata_i;
	PSTRB_i <= mem_wstrb_i;
	PSELx_i <= mem_valid_i;
	PENABLE_i <= mem_valid_d;

	PWRITE_i <= mem_wstrb_i(3) OR mem_wstrb_i(2) OR mem_wstrb_i(1) OR mem_wstrb_i(0);
	PPROT_i <= "000";

	mem_ready_i <= PREADY_i;
	mem_rdata_i <= PRDATA_i;


	-------------------------------------------------------------------------------
    -- REGISTER
    -------------------------------------------------------------------------------
	PREGISTER: process(PRESETn_i, PCLK_i)
	begin
		if PRESETn_i = '0' then 
			mem_valid_d <= '0';
		elsif rising_edge(PCLK_i) then 
			mem_valid_d <= mem_valid_i;
		end if;
	end process;


end Behavioural;
