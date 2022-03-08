--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     pcpi_hwswcd_hd - Behavioural
-- Project Name:    hardware/software codesign
-- Description:     coprocessor for PicoRV32 that calculates the Hamming distance
--
-- Revision     Date       Author     Comments
-- v0.1         20220118   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity pcpi_hwswcd_hd is
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
end entity pcpi_hwswcd_hd;

architecture Behavioural of pcpi_hwswcd_hd is

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

    signal isArith, isMul, distance_ce, finished : STD_LOGIC;
    signal calculating, calculating_set, calculating_reset : STD_LOGIC;
    signal distance, distance_inc : STD_LOGIC_VECTOR(31 downto 0);
    signal pointer : STD_LOGIC_VECTOR(31 downto 0);
    signal operand_x, operand_y : STD_LOGIC_VECTOR(31 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
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


    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    isArith <= '1' when pcpi_insn_i(6 downto 0) = "0110011" else '0';
    isMul <= '1' when pcpi_insn_i(31 downto 25) = "0000001" else '0';
    distance_ce <= (operand_x(0) xor operand_y(0)) and calculating;
    distance_inc <= std_logic_vector(to_unsigned(to_integer(unsigned(distance)) + 1, distance_inc'length));

    calculating_set <= pcpi_valid_i and not(calculating) and isArith and isMul and not(finished);
    calculating_reset <= pointer(0) and not pointer(1) and calculating;

    pcpi_wait_i <= calculating;
    pcpi_wr_i <= finished;
    pcpi_rd_i <= distance;
    pcpi_ready_i <= finished;


    -------------------------------------------------------------------------------
    -- SEQUENTIAL
    -------------------------------------------------------------------------------
    PREG: process(resetn_i, clock_i)
    begin
        if resetn_i = '0' then
            operand_x <= (others => '0');
            operand_y <= (others => '0');
            pointer <= (others => '1');
            distance <= (others => '0');
            calculating <= '0';
            finished <= '0';
        elsif rising_edge(clock_i) then 
            if calculating_set = '1' then 
                operand_x <= pcpi_rs1_i;
                operand_y <= pcpi_rs2_i;
                pointer <= (others => '1');
                distance <= (others => '0');
            elsif calculating = '1' then 
                operand_x <= '0' & operand_x(operand_x'high downto 1);
                operand_y <= '0' & operand_y(operand_y'high downto 1);
                pointer <= '0' & pointer(pointer'high downto 1);
                if distance_ce = '1' then 
                    distance <= distance_inc;
                end if;
            end if;
            if calculating_reset = '1' then 
                calculating <= '0';
            elsif calculating_set = '1' then 
                calculating <= '1';
            end if;
            finished <= calculating_reset;
        end if;
    end process;

end Behavioural;
