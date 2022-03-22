---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: APB_sin.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 21 March 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcodesign.ALL;

entity APB_sin is
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
end entity APB_sin;

architecture rtl of APB_sin is

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

    constant C_NUMOF_REGISTERS : integer := 2;
    signal local_address : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    type T_registers is array (C_NUMOF_REGISTERS-1 downto 0) of STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal registers : T_registers; 

    signal within_addressrange : STD_LOGIC;
    signal load_reg_write, load_reg_read : STD_LOGIC;
    signal masked_data, mask : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

    signal outgoing_data : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal write_ack, read_ack : STD_LOGIC;

    alias DIN_R : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) is registers(0);
    signal DOUT_R : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    
    component sin is
        generic (
            ALPHA_LEN : integer := 10;
            SIN_LEN : integer := 32
        );
        port (
            clock : std_logic;
            reset : STD_LOGIC;
            alpha : IN STD_ULOGIC_VECTOR(ALPHA_LEN-1 downto 0);
            sine : OUT std_logic_vector(SIN_LEN-1 downto 0)
        );
    end component;

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
    PREADY <= PREADY_i;
    PRDATA <= PRDATA_i;
    PSLVERR <= PSLVERR_i;
    
    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    -- outgoing signals
    PREADY_i <= write_ack OR read_ack;
    PRDATA_i <= outgoing_data;
    PSLVERR_i <= '0';

    -- determine whether reading or writing is to be done
    within_addressrange <= '1' when (PADDR_i >= G_BASE_ADDRESS) and (PADDR_i <= G_HIGH_ADDRESS) else '0';
    load_reg_write <= PSELx_i and within_addressrange and not(PENABLE_i) and PWRITE_i;
    load_reg_read <= PSELx_i and within_addressrange and not(PENABLE_i) and not(PWRITE_i);

    -- mask out the data based on the STROBE
    mask <= PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & 
        PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & 
        PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & 
        PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0);
    masked_data <= PWDATA_i and mask;

    local_address <= PADDR_i XOR G_BASE_ADDRESS;
    
    -------------------------------------------------------------------------------
    -- APB REGISTERS
    -------------------------------------------------------------------------------
    -- functional block registers
    PREGISTER: process(PRESETn_i, PCLK_i)
    begin
        if PRESETn_i = '0' then 
            registers <= (others => (others => '0'));
        elsif rising_edge(PCLK_i) then 
            if(load_reg_write = '1') then
                if local_address = x"00000000" then 
                    DIN_R <= masked_data;
                end if;
            end if;
        end if;
    end process;

    -- outgoing registers
    PREG: process(PRESETn_i, PCLK_i)
    begin
        if PRESETn_i = '0' then 
            outgoing_data <= (others => '0');
            write_ack <= '0';
            read_ack <= '0';
        elsif rising_edge(PCLK_i) then 
            -- read operation
            if(load_reg_read = '1') then
                if local_address = x"00000000" then 
                    outgoing_data <= DIN_R;
                elsif local_address = x"00000004" then 
                    outgoing_data <= DOUT_R;
                end if;
            else
                outgoing_data <= (others => '0');
            end if;

            -- this functional block has no wait states
            write_ack <= load_reg_write;
            read_ack <= load_reg_read;
        end if;
    end process;

    -------------------------------------------------------------------------------
    -- SINE COMPONENT
    -------------------------------------------------------------------------------
    sin_inst00: component sin
        port map (
            clock => PCLK_i,
            reset => PRESETn_i,
            alpha => std_ulogic_vector(DIN_R(9 downto 0)),
            sine => DOUT_R
        );

end architecture rtl;