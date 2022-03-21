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
    use IEEE.std_logic_unsigned.all;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.NUMERIC_STD_UNSIGNED.all;

entity sin is
    generic (
        ALPHA_LEN : integer := 10;
        SIN_LEN : integer := 20
    );
    port (
        clock : std_logic;
        reset : STD_LOGIC;
        alpha : IN STD_ULOGIC_VECTOR(ALPHA_LEN-1 downto 0);
        sin : OUT std_logic_vector(SIN_LEN-1 downto 0)
    );
end entity sin;

architecture behavioural of sin is

   COMPONENT blk_mem_gen_0
        PORT (
            clka : IN STD_LOGIC;
            ena : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    -- signals for de(localising inputs)
    signal reset_i : STD_LOGIC;
    signal alpha_i : std_ulogic_vector (ALPHA_LEN-1 downto 0);
    signal sin_i : std_logic_vector (SIN_LEN-1 downto 0);
    
    -- local signals
    signal is_result_negative : STD_LOGIC;
    signal alpha_i_rescaled : std_ulogic_vector(alpha_len-1 downto 0);
    signal degrees_180 : std_ulogic_vector(alpha_len-1 downto 0) := b"0010110100"; -- 0010110100 BIN = 180 DEC
    
    -- rom signal
    signal rom_a_enable : std_logic;
    signal rom_a_addr : std_logic_vector(7 downto 0);
    signal rom_a_dout : std_logic_vector(31 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------

    alpha_i <= alpha;
    sin <= sin_i;

    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    is_result_negative <= '0' when alpha_i < degrees_180 else '1';
    alpha_i_rescaled <= alpha_i - degrees_180;
    
    rom_a_enable <= '1';
    rom_a_addr <= std_logic_vector(alpha_i(7 downto 0)) when is_result_negative = '0' else std_logic_vector(alpha_i_rescaled(7 downto 0));    
    sin_i <= rom_a_dout when is_result_negative = '0' else (not rom_a_dout) + b"1";
    
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