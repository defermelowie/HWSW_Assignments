--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     picorv_mem_model - Behavioural
-- Project Name:    Memory model for PicoRV32
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20211218   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_MISC.or_reduce;
    use STD.textio.all;
    use ieee.std_logic_textio.all;

entity picorv_mem_model is
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
end entity picorv_mem_model;

architecture Behavioural of picorv_mem_model is

    -- localised inputs
    signal resetn_i : STD_LOGIC;
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

    file fh : text;

    type T_memory is array(0 to 4096) of STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal mem : T_memory;

    signal word : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal flag, flag_d, flag_dd : STD_LOGIC;
    signal mem_addr_int : integer;
    signal write_operation : STD_LOGIC;

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    resetn_i <= resetn;
    clock_i <= clock;

    load_file_i <= load_file;
    load_file_done <= load_file_done_i;

    mem_valid_i <= mem_valid;
    mem_instr_i <= mem_instr;
    mem_addr_i <= mem_addr;
    mem_wdata_i <= mem_wdata;
    mem_wstrb_i <= mem_wstrb;
    mem_ready <= mem_ready_i;
    mem_rdata <= mem_rdata_i;

    -------------------------------------------------------------------------------
    -- MEMORY
    -------------------------------------------------------------------------------
    write_operation <= or_reduce(mem_wstrb);
    PMEM: process(resetn_i, clock_i)
        variable v_line : line;
        variable v_temp : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
        variable v_pointer : integer;
    begin
        if resetn_i = '0' then 
            word <= (others => '0');
            flag <= '0';
            flag_d <= '0';
            flag_dd <= '0';
            load_file_done_i <= '0';
        elsif rising_edge(clock_i) then 
            if load_file_i = '1' then 
                v_pointer := 0;
                file_open(fh, FNAME_HEX, read_mode);

                while not endfile(fh) loop
                    readline(fh, v_line);
                    hread(v_line, v_temp);
                    mem(v_pointer) <= v_temp;
                    v_pointer := v_pointer + 1;
                end loop;

                load_file_done_i <= '1';
                file_close(fh);

                file_open(fh, FNAME_OUT, write_mode);
                
                report "file loaded to memory";
            else  
                if(mem_valid_i = '1') then 
                    if write_operation = '1' then 
                        if mem_addr_i = x"10000000" and mem_ready_i = '1' then 
                            write(v_line, mem_wdata_i);
                            writeline(fh,  v_line);
                        else
                            mem(mem_addr_int) <= mem_wdata_i;
                            word <= (others => '0');
                        end if;
                    else
                        word <= mem(mem_addr_int);
                    end if;
                end if;
                flag_d <= flag;
                flag_dd <= flag_d;
                flag <= mem_valid_i;
            end if;
        end if;
    end process;

    mem_addr_int <= to_integer(unsigned(mem_addr_i(13 downto 2)));

    mem_ready_i <= flag;
    mem_rdata_i <= word;

end Behavioural;
