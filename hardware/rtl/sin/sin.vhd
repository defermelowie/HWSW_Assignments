---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: sin.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 14 March 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity sin is
    generic (
        ALPHA_LEN : integer := 10
    );
    port (
        clock : std_logic;
        reset : STD_LOGIC;
        alpha : IN STD_ULOGIC_VECTOR(ALPHA_LEN-1 downto 0)
    );
end entity sin;

architecture behavioural of sin is

   COMPONENT blk_mem_gen_0
        PORT (
            clka : IN STD_LOGIC;
            ena : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
        );
    END COMPONENT;
    
    -- signals for de(localising inputs)
    signal reset_i : STD_LOGIC;
    signal ALPHA_i : STD_ULOGIC_VECTOR(ALPHA_LEN-1 downto 0);
    
    -- local signals
    signal is_result_negative : STD_LOGIC;
    signal degrees_180 : STD_ULOGIC_VECTOR(ALPHA_LEN-1 downto 0) := b"0010110100";
    
    -- rom signal
    signal rom_a_enable : std_logic;
    signal rom_a_addr : std_logic_vector(6 downto 0);
    signal rom_a_dout : std_logic_vector(19 downto 0);
    
        
    -- control signals
    signal do_two_complement : STD_LOGIC;
    signal do_sub_pi : STD_LOGIC;

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------

    ALPHA_i <= alpha;

    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    is_result_negative <= '0' when ALPHA_i < degrees_180 else '1';
    do_sub_pi <= is_result_negative;
    do_two_complement <= is_result_negative;
    
    -------------------------------------------------------------------------------
    -- SINE LOOKUP TABLE
    -------------------------------------------------------------------------------
    blk_rom_inst00 : blk_mem_gen_0
        PORT MAP (
            clka => clock,
            ena => rom_a_enable,
            addra => rom_a_addr,
            douta => rom_a_dout
        );
    
end architecture behavioural;