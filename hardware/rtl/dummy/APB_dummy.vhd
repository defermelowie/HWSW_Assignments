--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     APB_dummy - Behavioural
-- Project Name:    PicoRV32 - peripheral
-- Description:     This compenent is an empty placeholder
--
-- Revision     Date       Author     Comments
-- v0.1         20220126   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcodesign.ALL;

entity APB_dummy is
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
end entity APB_dummy;

architecture Behavioural of APB_dummy is

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

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    PCLK_i <= PCLK;
    PRESETn_i <= PRESETn;
    PADDR_i <= PADDR;
    PPROT_i <= PPROT;
    PSELx_i <= PSELx;
    PENABLE_i <= PENABLE;
    PWRITE_i <= PWRITE;
    PWDATA_i <= PWDATA;
    PSTRB_i <= PSTRB;
    PREADY <= '0';
    PRDATA <= (others => '0');
    PSLVERR <= '0';



end Behavioural;
