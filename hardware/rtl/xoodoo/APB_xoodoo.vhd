---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: APB_xoodoo.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 10 May 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcodesign.ALL;

entity APB_xoodoo is
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
end entity APB_xoodoo;

architecture rtl of APB_xoodoo is

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

    signal local_address : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

    signal within_addressrange : STD_LOGIC;
    signal illegal_write_address : STD_LOGIC;
    signal load_reg_write, load_reg_read : STD_LOGIC;
    signal masked_data, mask : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

    signal outgoing_data : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal write_ack, read_ack : STD_LOGIC;

    -- Lane array type
    constant C_XOODOO_NUMOF_PLANES : integer := 3;
    constant C_XOODOO_NUMOF_SHEETS : integer := 4;
    constant C_XOODOO_NUMOF_LANES : integer := C_XOODOO_NUMOF_PLANES * C_XOODOO_NUMOF_SHEETS;
    type T_lane_array is array (C_XOODOO_NUMOF_LANES-1 downto 0) of STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

    -- Define xoodoo registers
    signal CONTROL_R : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal LANE_IN_V : T_lane_array;
    signal STATUS_R : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal LANE_OUT_V : T_lane_array;
    
    -- Xoodoo permutation component

    component xoodoo_permutation is
        port (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            number_of_rounds : IN STD_LOGIC_VECTOR(3 downto 0);
            load : IN STD_LOGIC;
            -- Todo: State in
    
            ready : OUT STD_LOGIC
            -- Todo: State out
        );
    end component; -- xoodoo_permutation


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
    -- XOODOO PERMUTATION COMPONENT
    -------------------------------------------------------------------------------

    xoodoo_permutation_inst00: component xoodoo_permutation
        port map (
            clock => PCLK_i,
            reset => PRESETn_i,
            number_of_rounds => CONTROL_R(3 downto 0),
            load => CONTROL_R(4),
            ready => STATUS_R(0)
        );
    
    -------------------------------------------------------------------------------
    -- APB REGISTERS
    -------------------------------------------------------------------------------
    -- functional block registers
    PREGISTER: process(PRESETn_i, PCLK_i)
    begin
        if PRESETn_i = '0' then 
            CONTROL_R <= (others => '0');
            LANE_IN_V <= (others => (others => '0'));
        elsif rising_edge(PCLK_i) then 
            if(load_reg_write = '1') then
                illegal_write_address <= '0';
                case(local_address) is -- Input register addresses are defined here
                    when x"00000000" => CONTROL_R <= masked_data;
                    when x"00000004" => LANE_IN_V(0) <= masked_data;
                    when x"00000008" => LANE_IN_V(1) <= masked_data;
                    when x"0000000C" => LANE_IN_V(2) <= masked_data;
                    when x"00000010" => LANE_IN_V(3) <= masked_data;
                    when x"00000014" => LANE_IN_V(4) <= masked_data;
                    when x"00000018" => LANE_IN_V(5) <= masked_data;
                    when x"0000001C" => LANE_IN_V(6) <= masked_data;
                    when x"00000020" => LANE_IN_V(7) <= masked_data;
                    when x"00000024" => LANE_IN_V(8) <= masked_data;
                    when x"00000028" => LANE_IN_V(9) <= masked_data;
                    when x"0000002C" => LANE_IN_V(10) <= masked_data;
                    when x"00000030" => LANE_IN_V(11) <= masked_data;
                    when others  => illegal_write_address <= '1';
                end case ;
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
                case(local_address) is -- Input register addresses are defined here
                    when x"00000000" => outgoing_data <=  CONTROL_R;
                    when x"00000004" => outgoing_data <=  LANE_IN_V(0);
                    when x"00000008" => outgoing_data <=  LANE_IN_V(1);
                    when x"0000000C" => outgoing_data <=  LANE_IN_V(2);
                    when x"00000010" => outgoing_data <=  LANE_IN_V(3);
                    when x"00000014" => outgoing_data <=  LANE_IN_V(4);
                    when x"00000018" => outgoing_data <=  LANE_IN_V(5);
                    when x"0000001C" => outgoing_data <=  LANE_IN_V(6);
                    when x"00000020" => outgoing_data <=  LANE_IN_V(7);
                    when x"00000024" => outgoing_data <=  LANE_IN_V(8);
                    when x"00000028" => outgoing_data <=  LANE_IN_V(9);
                    when x"0000002C" => outgoing_data <=  LANE_IN_V(10);
                    when x"00000030" => outgoing_data <=  LANE_IN_V(11);
                    when x"00000034" => outgoing_data <=  STATUS_R;
                    when x"00000038" => outgoing_data <=  LANE_OUT_V(0);
                    when x"0000003C" => outgoing_data <=  LANE_OUT_V(1);
                    when x"00000040" => outgoing_data <=  LANE_OUT_V(2);
                    when x"00000044" => outgoing_data <=  LANE_OUT_V(3);
                    when x"00000048" => outgoing_data <=  LANE_OUT_V(4);
                    when x"0000004C" => outgoing_data <=  LANE_OUT_V(5);
                    when x"00000050" => outgoing_data <=  LANE_OUT_V(6);
                    when x"00000054" => outgoing_data <=  LANE_OUT_V(7);
                    when x"00000058" => outgoing_data <=  LANE_OUT_V(8);
                    when x"0000005C" => outgoing_data <=  LANE_OUT_V(9);
                    when x"00000060" => outgoing_data <=  LANE_OUT_V(10);
                    when x"00000064" => outgoing_data <=  LANE_OUT_V(11);
                    when others => outgoing_data <= (others => '0'); -- Output zero if address is illegal
                end case ;
            else
                outgoing_data <= (others => '0');
            end if;

            -- this functional block has no wait states
            write_ack <= load_reg_write;
            read_ack <= load_reg_read;
        end if;
    end process;

end architecture rtl;