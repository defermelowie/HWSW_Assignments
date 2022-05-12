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
        state_in : IN T_lane_array;
        ready : OUT STD_LOGIC;
        state_out : OUT T_lane_array
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
    signal state_in_i : T_lane_array;
    signal ready_i : STD_LOGIC;
    signal state_out_i : T_lane_array;

    -- Fsm states
    type T_fsm_state IS (R, L, P, F);  -- define states (Ready, Load, Permute, Finished)
    signal fsm_state : T_fsm_state; -- fsm state signal

    -- Round counter signal
    signal round_ctr : STD_LOGIC_VECTOR(3 downto 0);

    -- Plane type
    type T_plane is array (C_XOODOO_NUMOF_SHEETS-1 downto 0) of STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

    -- Permutation signals
    signal theta_in, theta_out : T_lane_array;
    signal theta_p, theta_e : T_plane;
    signal rho_w_in, rho_w_out : T_lane_array;
    signal iota_in, iota_out : T_lane_array;
    signal chi_in, chi_out : T_lane_array;
    signal rho_e_in, rho_e_out : T_lane_array;

    -- Helpers
    signal theta_e_0, theta_e_1 : T_plane;

    -- Index function for lane array type
    function index(y : integer := 0; x : integer := 0) 
    return integer is variable index_result : integer;
    begin
        index_result := ((y mod C_XOODOO_NUMOF_PLANES) * C_XOODOO_NUMOF_SHEETS) + (x mod C_XOODOO_NUMOF_SHEETS);
        return index_result;
    end function;

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    -- INPUT
    clk_i <= clock;
    reset_i <= reset;
    number_of_rounds_i <= number_of_rounds;
    data_valid_i <= data_valid;
    state_in_i <= state_in;
    -- OUTPUT
    ready <= ready_i;
    state_out <= state_out_i;

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

    -------------------------------------------------------------------------------
    -- STATE OUT DEFINITION
    -------------------------------------------------------------------------------
    P_STATE_OUT : process(reset_i, clk_i)
    begin
        if reset_i = '0' then
            state_out_i <= (others => (others => '0'));
        elsif rising_edge(clk_i) then
            -- Todo: if state out = last permutation output if state if finished
            case fsm_state is
                when R => state_out_i <= state_out_i;
                when L => state_out_i <= state_out_i;
                when P => state_out_i <= state_out_i;
                when F => state_out_i <= rho_e_out;
            end case;
        end if;
    end process ; -- P_STATE_OUT

    -------------------------------------------------------------------------------
    -- PERMUTATION
    -------------------------------------------------------------------------------
    -- Link stages
    theta_in <= state_in_i; -- Fixme: theta in is state_in only for first round
    rho_w_in <= theta_out;
    iota_in <= rho_w_out;
    chi_in <= iota_out;
    rho_e_in <= chi_out;

    -- Theta
    G_THETA_P : for x in 0 to C_XOODOO_NUMOF_SHEETS-1 generate
        theta_p(x) <= theta_in(index(0, x)) xor theta_in(index(1, x)) xor theta_in(index(2, x));
    end generate ; -- G_THETA_P
    G_THETA_E : for x in 0 to C_XOODOO_NUMOF_SHEETS-1 generate
        theta_e_0(x) <= (theta_p((x - 1) mod C_XOODOO_NUMOF_SHEETS)(26 downto 0) & theta_p((x - 1) mod C_XOODOO_NUMOF_SHEETS)(31 downto 27));
        theta_e_1(x) <= (theta_p((x - 1) mod C_XOODOO_NUMOF_SHEETS)(17 downto 0) & theta_p((x - 1) mod C_XOODOO_NUMOF_SHEETS)(31 downto 18));
        theta_e(x) <= theta_e_0(x) xor theta_e_1(x);
    end generate ; -- G_THETA_E
    G_THETA_AS : for x in 0 to C_XOODOO_NUMOF_SHEETS-1 generate
        G_THETA_AP : for y in 0 to C_XOODOO_NUMOF_PLANES-1 generate
            theta_out(index(y, x)) <= theta_in(index(y, x)) xor theta_e(x);
        end generate ; -- G_THETA_AP
    end generate ; -- G_THETA_AS

    -- -- Rho east
    -- G_RHO_E : for x in 0 to C_XOODOO_NUMOF_SHEETS-1 generate
        
    end generate ; -- G_RHO_E
end architecture rtl;