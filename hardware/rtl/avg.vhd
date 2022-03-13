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

    -- fsm states
    type State_type IS (R, W, F);  -- define states (Ready, Write data, Finished)

    -- signals
	signal fsm_state : State_type;              -- fsm state signal
    signal avg : STD_LOGIC_VECTOR(31 downto 0); -- average
    signal sum: STD_LOGIC_VECTOR(32 downto 0);  -- sum
    signal is_rem_inst: STD_LOGIC;              -- is remainder instruction signal

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
    
    -- signals for calculation
    sum <= ('0' & pcpi_rs1_i) + ('0' & pcpi_rs2_i); -- calculate sum
    avg <= sum(32 downto 1); -- Shift right -> /2

    -----------------------------------------------------------
    -- sequential
    -----------------------------------------------------------

    proc: process(resetn_i, clock_i)
    begin
        if resetn_i = '0' then
            fsm_state <= R;
        elsif rising_edge(clock_i) then
            case fsm_state is
                when R =>
                    pcpi_wait_i <= '0';
                    pcpi_wr_i <= '0';
                    pcpi_ready_i <= '0';
                    pcpi_rd_i <= (others => '0');
                    -- next state is write data if valid instruction and pcpi valid
                    if is_rem_inst = '1' and pcpi_valid_i = '1' then
                        fsm_state <= W;
                    else
                        fsm_state <= R;
                    end if;
                when W =>
                    pcpi_wait_i <= '0';
                    pcpi_wr_i <= '1';
                    pcpi_ready_i <= '1';
                    pcpi_rd_i <= avg;
                    -- next state is finished
                    fsm_state <= F;
                when F =>
                    pcpi_wait_i <= '0';
                    pcpi_wr_i <= '0';
                    pcpi_ready_i <= '0';
                    pcpi_rd_i <= (others => '0');
                    -- next state is ready
                    fsm_state <= R;
            end case;
        end if;
    end process proc;

end behavioural ; -- behavioural