---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: xoodoo_permutation.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 11 May 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.NUMERIC_STD_UNSIGNED.ALL;

library work;
    use work.PKG_hwswcodesign.ALL;
    use work.PKG_xoodoo.ALL;

entity xoodoo_permutation is
    port (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        number_of_rounds : IN STD_LOGIC_VECTOR(3 downto 0);
        data_valid : IN STD_LOGIC;
        -- Todo: State in

        ready : OUT STD_LOGIC
        -- Todo: State out
    );
end entity xoodoo_permutation;

architecture rtl of xoodoo_permutation is

    -------------------------------------------------------------------------------
    -- SIGNAL DEFINITIONS
    -------------------------------------------------------------------------------
    -- IO
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal number_of_rounds_i : STD_LOGIC_VECTOR(3 downto 0);
    signal data_valid_i : STD_LOGIC;
    signal ready_i : STD_LOGIC;

    -- Fsm states
    type T_fsm_state IS (R, L, P, F);  -- define states (Ready, Load, Permute, Finished)
    signal fsm_state : T_fsm_state; -- fsm state signal

    -- Local signals
    signal round_ctr : STD_LOGIC_VECTOR(3 downto 0);

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    -- INPUT
    clk_i <= clock;
    reset_i <= reset;
    number_of_rounds_i <= number_of_rounds;
    data_valid_i <= data_valid;
    -- OUTPUT
    ready <= ready_i;

    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    ready_i <= '1' when (fsm_state = F) else '0'; 

    -------------------------------------------------------------------------------
    -- FINITE STATE MACHINE
    -------------------------------------------------------------------------------
    P_FSM : process(reset_i, clk_i)
    begin
        if reset_i = '0' then
            fsm_state <= R;
        elsif rising_edge(clk_i) then
            case(fsm_state) is
                when R => fsm_state <= L when data_valid_i else R;
                when L => fsm_state <= P;
                when P => fsm_state <= F when (round_ctr = b"0000") else P;
                when F => fsm_state <= F when data_valid_i else R;  -- Stay in finished while data valid is high
            end case ;
        end if;     
    end process ; -- P_FSM

    -------------------------------------------------------------------------------
    -- ROUND COUNTER
    -------------------------------------------------------------------------------
    P_ROUND_CTR : process(reset_i, clk_i)
    begin
        if reset_i = '0' then
            round_ctr <= (others => '0');
        elsif rising_edge(clk_i) then
            case fsm_state is
                when R => round_ctr <= b"0000";
                when L => round_ctr <= number_of_rounds_i;
                when P => round_ctr <= round_ctr - 1;
                when F => round_ctr <= b"0000";
            end case;
        end if;
    end process; -- P_ROUND_CTR

end architecture rtl;