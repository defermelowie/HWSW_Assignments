--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     picorv_testbench - Behavioural
-- Project Name:    Testbench for PicoRV32
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20211224   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    -- use IEEE.NUMERIC_STD.ALL;


entity APB_counter_tb is
    generic (
        G_DATA_WIDTH : integer := 32
    );
end entity APB_counter_tb;

architecture Behavioural of APB_counter_tb is

    component APB_counter is
        generic (
            G_DATA_WIDTH : integer := 32;
            G_BASE_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"00000000";
            G_HIGH_ADDRESS : STD_LOGIC_VECTOR(32-1 downto 0) := x"FFFFFFFF"
        );
        port (
            PCLK : IN STD_LOGIC;
            PRESETn : IN STD_LOGIC;
            PADDR : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            PPROT : IN STD_LOGIC_VECTOR(3-1 downto 0);
            PSELx : IN STD_LOGIC;
            PENABLE : IN STD_LOGIC;
            PWRITE : IN STD_LOGIC;
            PWDATA : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            PSTRB : IN STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
            PREADY : OUT STD_LOGIC;
            PRDATA : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            PSLVERR : OUT STD_LOGIC
        );
    end component;

    signal PCLK : STD_LOGIC;
    signal PRESETn : STD_LOGIC;
    signal PADDR : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal PPROT : STD_LOGIC_VECTOR(3-1 downto 0);
    signal PSELx : STD_LOGIC;
    signal PENABLE : STD_LOGIC;
    signal PWRITE : STD_LOGIC;
    signal PWDATA : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal PSTRB : STD_LOGIC_VECTOR(G_DATA_WIDTH/8-1 downto 0);
    signal PREADY : STD_LOGIC;
    signal PRDATA : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal PSLVERR : STD_LOGIC;

    constant clock_period : time := 10 ns;

begin



    -------------------------------------------------------------------------------
    -- STIMULI
    -------------------------------------------------------------------------------
    PSTIM: process
    begin
        -- apply reset
        PRESETn <= '0';
        PADDR <= (others => '0');
        PPROT <= (others => '0');
        PSELx <= '0';
        PENABLE <= '0';
        PWRITE <= '0';
        PWDATA <= (others => '0');
        PSTRB <= (others => '0');
        wait for clock_period*10;

        -- release reset
        PRESETn <= '1';
        wait for clock_period*10;

        ------------------------------------------------
        -- TEST 1: write data and read back
        -- write data - setup phase
        PADDR <= x"81000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '1';
        PWDATA <= x"76543210";
        PSTRB <= x"F";
        wait for clock_period;
        -- write data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        -- read data - setup phase
        PADDR <= x"81000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '0';
        PWDATA <= x"00000000";
        PSTRB <= x"0";
        wait for clock_period;
        -- read data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        assert(PRDATA = x"76543210") report "ERROR TEST 1" severity error;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        ------------------------------------------------
        -- TEST 2: write data and read back to an address out of range
        -- write data - setup phase
        PADDR <= x"82000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '1';
        PWDATA <= x"76543210";
        PSTRB <= x"F";
        wait for clock_period;
        -- write data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        -- read data - setup phase
        PADDR <= x"82000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '0';
        PWDATA <= x"00000000";
        PSTRB <= x"0";
        wait for clock_period;
        -- read data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        assert(PRDATA = x"00000000") report "ERROR TEST 2" severity error;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;


        ------------------------------------------------
        -- TEST 3: let the counter count
        -- write data - setup phase
        PADDR <= x"81000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '1';
        PWDATA <= x"00000001";
        PSTRB <= x"F";
        wait for clock_period;
        -- write data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        -- write data - setup phase
        PADDR <= x"81000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '1';
        PWDATA <= x"00000000";
        PSTRB <= x"F";
        wait for clock_period;
        -- write data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        -- read data - setup phase
        PADDR <= x"81000004";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '0';
        PWDATA <= x"00000000";
        PSTRB <= x"0";
        wait for clock_period;
        -- read data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        assert(PRDATA = x"0000000C") report "ERROR TEST 3" severity error;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        ------------------------------------------------
        -- TEST 4: clear the counter
        -- write data - setup phase
        PADDR <= x"81000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '1';
        PWDATA <= x"00000002";
        PSTRB <= x"F";
        wait for clock_period;
        -- write data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        -- write data - setup phase
        PADDR <= x"81000000";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '1';
        PWDATA <= x"00000000";
        PSTRB <= x"F";
        wait for clock_period;
        -- write data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        -- read data - setup phase
        PADDR <= x"81000004";
        PSELx <= '1';
        PENABLE <= '0';
        PWRITE <= '0';
        PWDATA <= x"00000000";
        PSTRB <= x"0";
        wait for clock_period;
        -- read data - access phase
        PENABLE <= '1';
        wait for clock_period/2;
        -- wait for acknowledge (if needed)
        if PREADY = '0' then 
            wait until PREADY = '1';
        end if;
        assert(PRDATA = x"00000000") report "ERROR TEST 4" severity error;
        wait for clock_period/2;
        PADDR <= (others => '0'); PPROT <= (others => '0'); PSELx <= '0'; PENABLE <= '0'; PWRITE <= '0'; PWDATA <= (others => '0'); PSTRB <= (others => '0');
        wait for clock_period*10;

        wait;
    end process;

    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    APB_counter_inst00: component APB_counter 
        generic map (
            G_DATA_WIDTH => 32,
            G_BASE_ADDRESS => x"81000000",
            G_HIGH_ADDRESS => x"8100FFFF")
        port map(
            PCLK => PCLK,
            PRESETn => PRESETn,
            PADDR => PADDR,
            PPROT => PPROT,
            PSELx => PSELx,
            PENABLE => PENABLE,
            PWRITE => PWRITE,
            PWDATA => PWDATA,
            PSTRB => PSTRB,
            PREADY => PREADY,
            PRDATA => PRDATA,
            PSLVERR => PSLVERR);

    -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    PCLOCK: process
    begin
        PCLK <= '1';
        wait for clock_period/2;
        PCLK <= '0';
        wait for clock_period/2;
    end process PCLOCK;

end Behavioural;
