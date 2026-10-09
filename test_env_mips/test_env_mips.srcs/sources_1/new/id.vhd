----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2026 04:32:29 PM
-- Design Name: 
-- Module Name: ID - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
Port ( 
        regWrite : in std_logic;
        Instr : in std_logic_vector (25 downto 0);
        regDst : in std_logic;
        en : in std_logic;
        extOp : in std_logic;
        RD1 : out std_logic_vector (31 downto 0);
        RD2 : out std_logic_vector (31 downto 0);
        WD : in std_logic_vector (31 downto 0);
        ext_Imm : out std_logic_vector (31 downto 0);
        func : out std_logic_vector (5 downto 0);
        sa : out std_logic_vector (4 downto 0);
        clk : in std_logic
);
end ID;

architecture Behavioral of ID is

signal write_addr : std_logic_vector (4 downto 0);

type reg_mem is array (0 to 31) of std_logic_vector(31 downto 0);

signal mem : reg_mem :=(others=>X"00000000");

begin

write_addr <= Instr(15 downto 11) when regDst = '1' else Instr(20 downto 16);

process(clk)
begin

    if rising_edge(clk) then
    
        if en ='1' and regWrite='1' then
        
            mem(conv_integer(write_addr) )<= WD;
            
        end if;
        
    end if;
    
end process;

rd1 <= mem(conv_integer(Instr(25 downto 21)) ); 
rd2 <= mem(conv_integer(Instr(20 downto 16)) ); 

ext_Imm(15 downto 0) <= Instr(15 downto 0); 
ext_Imm(31 downto 16) <= (others => Instr(15)) when extOp='1' else (others => '0');
func <= Instr(5 downto 0);
sa <= Instr(10 downto 6);

end Behavioral;