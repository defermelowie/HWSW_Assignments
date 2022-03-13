---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: avg.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 08 March 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity pcpi_avg is 
    port (
        resetn : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        pcpi_valid : IN STD_LOGIC;
        pcpi_insn : IN STD_LOGIC_VECTOR(32-1 downto 0);
        pcpi_rs1 : IN STD_LOGIC_VECTOR(32-1 downto 0);
        pcpi_rs2 : IN STD_LOGIC_VECTOR(32-1 downto 0);
        pcpi_wr : OUT STD_LOGIC;
        pcpi_rd : OUT STD_LOGIC_VECTOR(32-1 downto 0);
        pcpi_wait : OUT STD_LOGIC;
        pcpi_ready : OUT STD_LOGIC
    );
end entity pcpi_avg;

architecture behavioural of pcpi_avg is

    -- localised inputs
    signal resetn_i : STD_LOGIC;
    signal clock_i : STD_LOGIC;
    signal pcpi_valid_i : STD_LOGIC;
    signal pcpi_insn_i : STD_LOGIC_VECTOR(32-1 downto 0);
    signal pcpi_rs1_i : STD_LOGIC_VECTOR(32-1 downto 0);
    signal pcpi_rs2_i : STD_LOGIC_VECTOR(32-1 downto 0);
    signal pcpi_wr_i : STD_LOGIC;
    signal pcpi_rd_i : STD_LOGIC_VECTOR(32-1 downto 0);
    signal pcpi_wait_i : STD_LOGIC;
    signal pcpi_ready_i : STD_LOGIC;

    -- signals
    signal avg : STD_LOGIC_VECTOR(31 downto 0);
    signal sum: STD_LOGIC_VECTOR(32 downto 0);
    signal calculating, calculating_set, calculating_reset, finished: STD_LOGIC;
    signal is_rem_inst: STD_LOGIC;

begin

    -----------------------------------------------------------
    -- (de-)localising in/outputs
    -----------------------------------------------------------
    resetn_i <= resetn;
    clock_i <= clk;
    pcpi_valid_i <= pcpi_valid;
    pcpi_insn_i <= pcpi_insn;
    pcpi_rs1_i <= pcpi_rs1;
    pcpi_rs2_i <= pcpi_rs2;
    pcpi_wr <= pcpi_wr_i;
    pcpi_rd <= pcpi_rd_i;
    pcpi_wait <= pcpi_wait_i;
    pcpi_ready <= pcpi_ready_i;


    -----------------------------------------------------------
    -- combinatiorial
    -----------------------------------------------------------

    -- use riscv rem(ainder) instruction
    is_rem_inst <= '1' when (
        pcpi_insn_i(6 downto 0) = "0110011" and     -- opcode
        pcpi_insn_i(14 downto 12) = "110" and       -- func3
        pcpi_insn_i(31 downto 25) = "0000001"       -- func7
    ) else '0';

    pcpi_wait_i <= calculating;
    pcpi_wr_i <= finished;
    pcpi_rd_i <= avg;
    pcpi_ready_i <= finished;


    -----------------------------------------------------------
    -- sequential
    -----------------------------------------------------------

    proc : process( resetn_i, clock_i )
    begin
        if resetn_i = '0' then
            sum <= (others => '0');
            avg <= (others => '0');
            calculating <= '0';
            finished <= '0';
        elsif rising_edge(clock_i) then
            if is_rem_inst = '1' and pcpi_valid_i = '1' then
                finished <= '0';
                calculating <= '1';
                sum <= ('0' & pcpi_rs1_i) + ('0' & pcpi_rs2_i);
                avg <= sum(32 downto 1); -- Shift right -> /2
                calculating <= '0';
                finished <= '1';
            else
                finished <= '0';
                calculating <= '0';
            end if;
        end if;
    end process ; -- avg

end behavioural ; -- behavioural