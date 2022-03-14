--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     picorv_APB_mem_model - Behavioural
-- Project Name:    Memory model for PicoRV32 with an APB interface
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20220107   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_MISC.or_reduce;
    use STD.textio.all;
    use ieee.std_logic_textio.all;

library work;
    use work.PKG_hwswcodesign.ALL;

entity picorv_APB_mem_model is
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
end entity picorv_APB_mem_model;

architecture Behavioural of picorv_APB_mem_model is

    -- localised inputs
    signal resetn_i : STD_LOGIC;
    signal clock_i : STD_LOGIC;

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

    file fh : text;

    type T_memory is array(0 to 16384-1) of STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal mem : T_memory;

    signal masked_data, mask : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal within_addressrange : STD_LOGIC;
    signal load_reg_write, load_reg_read : STD_LOGIC;
    signal outgoing_data : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal write_ack, read_ack : STD_LOGIC;
    signal addr_int : integer range 0 to 16384-1;
    
    signal mem_content : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    resetn_i <= resetn;
    clock_i <= clock;

    PADDR_i <= PADDR;
    PPROT_i <= PPROT; -- is ignored
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

    addr_int <= to_integer(unsigned(PADDR_i(15 downto 2)));
    within_addressrange <= '1' when (PADDR_i >= G_BASE_ADDRESS) and (PADDR_i <= G_HIGH_ADDRESS) else '0';
    load_reg_write <= PSELx_i and within_addressrange and not(PENABLE_i) and PWRITE_i;
    load_reg_read <= PSELx_i and within_addressrange and not(PENABLE_i) and not(PWRITE_i);


    -- mask out the read and write data based on the STROBE
    mask <= PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & PSTRB_i(3) & 
            PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & PSTRB_i(2) & 
            PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & PSTRB_i(1) & 
            PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0) & PSTRB_i(0);
    masked_data <= PWDATA_i and mask;
    
    mem_content <= mem(addr_int) and not(mask);

    -------------------------------------------------------------------------------
    -- MEMORY
    -------------------------------------------------------------------------------
    PMEM: process(resetn_i, clock_i)
        variable v_line : line;
        variable v_temp : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        variable v_pointer : integer;
    begin
        if resetn_i = '0' then 
            outgoing_data <= (others => '0');
            mem <= (others => (others => '0'));

            -- init the firmware
            v_pointer := 0;
            file_open(fh, FNAME_HEX, read_mode);

            while not endfile(fh) loop
                readline(fh, v_line);
                hread(v_line, v_temp);
                mem(v_pointer) <= v_temp;
                v_pointer := v_pointer + 1;
            end loop;

            file_close(fh);
        elsif rising_edge(clock_i) then 
            -- write to memory
            if load_reg_write = '1' then 
                mem(addr_int) <= masked_data OR mem_content;
                outgoing_data <= (others => '0');
            end if;

            -- read from memory 
            if load_reg_read = '1' then 
                outgoing_data <= mem_content;
            end if;

            -- this functional block has no wait states
            write_ack <= load_reg_write;
            read_ack <= load_reg_read;
        end if;
    end process;


end Behavioural;
