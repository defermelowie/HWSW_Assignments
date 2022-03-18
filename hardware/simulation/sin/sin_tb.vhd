---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: sin_tb.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 14 March 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity sin_tb is
end entity sin_tb;

architecture behavioural of sin_tb is

    signal reset_i : STD_LOGIC;
    signal alpha_i : STD_ULOGIC_VECTOR(9 downto 0);

    component sin is
        generic (
            ALPHA_LEN : integer := 10
        );
        port (
            reset : STD_LOGIC;
            alpha : IN STD_ULOGIC_VECTOR(ALPHA_LEN-1 downto 0)
        );
    end component;

begin

    -------------------------------------------------------------------------------
    -- STIMULI
    -------------------------------------------------------------------------------
    PSTIM: process
    begin
        reset_i <= '0';
        alpha_i <= std_ulogic_vector(to_unsigned(0, alpha_i'length));
        wait for 50 ns;

        reset_i <= '1';
        wait for 50 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(0, alpha_i'length));
        wait for 50 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(30, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(60, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(90, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(120, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(150, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(180, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(210, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(240, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(270, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(300, alpha_i'length));
        wait for 10 ns;
        
        alpha_i <= std_ulogic_vector(to_unsigned(330, alpha_i'length));
        wait for 10 ns;

        wait;
    end process;

    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    sin_inst00: component sin
        generic map (
            ALPHA_LEN => 10
        )
        port map (
            reset => reset_i,
            alpha => alpha_i
        );

end behavioural;