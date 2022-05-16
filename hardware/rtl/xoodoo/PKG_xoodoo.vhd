---------------------------------------------------------------
-- Hardware software codesign
---------------------------------------------------------------
-- Course assignments
--
-- File: PKG_xoodoo.vhd (vhdl)
-- By: Lowie Deferme (UHasselt/KULeuven - FIIW)
-- On: 12 May 2022
---------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcodesign.ALL;

package PKG_xoodoo is

    -- Lane array type
    constant C_XOODOO_NUMOF_PLANES : integer := 3;
    constant C_XOODOO_NUMOF_SHEETS : integer := 4;
    constant C_XOODOO_NUMOF_LANES : integer := C_XOODOO_NUMOF_PLANES * C_XOODOO_NUMOF_SHEETS;
    type T_lane_array is array (C_XOODOO_NUMOF_LANES-1 downto 0) of STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);

end package;