----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.04.2026 10:46:49
-- Design Name: 
-- Module Name: IFetch - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFetch is
    Port ( Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           pc : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
signal pc_out: std_logic_vector(31 downto 0):=(others=>'0');
signal add_4_pc : std_logic_vector(31 downto 0);
signal mux_1_out:  std_logic_vector(31 downto 0);
signal mux_2_out:  std_logic_vector(31 downto 0);
signal pc_in: std_logic_vector(31 downto 0):=(others=>'0');


type rom_type is array(0 to 31) of std_logic_vector(31 downto 0);

signal ROM: rom_type := (

    B"010001_00000_00001_0000000000000000", -- 0x44010000 | LW $1, 0($0)    | Incarca limita X in $1
    B"010001_00000_00010_0000000000000100", -- 0x44020004 | LW $2, 4($0)    | Incarca limita Y in $2
    B"010001_00000_00011_0000000000001000", -- 0x44030008 | LW $3, 8($0)    | Incarca nr elemente N in $3
    B"010000_00000_00100_0000000000001100", -- 0x4004000C | ADDI $4, $0, 12 | Seteaza adresa de start vector in $4

    -- loop 
    B"010011_00011_00000_0000000000001100", -- 0x4C60000C | BEQ $3, $0, 12  | Daca N=0 sare la final 
    B"010001_00100_00101_0000000000000000", -- 0x44850000 | LW $5, 0($4)    | Incarca element curent in $5
     
    -- if Elem < X
    B"000000_00101_00001_00110_00000_000010", -- 0x00A13002 | SUB $6, $5, $1  | $6 = Elem - X
    B"000000_00000_00110_00110_11111_000100", -- 0x000637C4 | SRL $6, $6, 31  | Izoleaza bit semn (1 daca Elem < X)
    B"010011_00110_00000_0000000000000010", -- 0x4CC00002 | BEQ $6, $0, 2   | Daca nu e mai mic, sare peste SW
    B"010010_00100_00001_0000000000000000", -- 0x88410000 | SW $1, 0($4)    | Elem = X 

    -- if Elem > Y
    B"000000_00010_00101_00110_00000_000010", -- 0x00423002 | SUB $6, $2, $5  | $6 = Y - Elem
    B"000000_00000_00110_00110_11111_000100", -- 0x000637C4 | SRL $6, $6, 31  | Izoleaza bit semn (1 daca Elem > Y)
    B"010011_00110_00000_0000000000000001", -- 0x4CC00001 | BEQ $6, $0, 1   | Daca nu e mai mare, sare peste SW
    B"010010_00100_00010_0000000000000000", -- 0x88420000 | SW $2, 0($4)    | Elem = Y 
     
    -- next logic
    B"010000_00100_00100_0000000000000100", -- 0x40840004 | ADDI $4, $4, 4  | Next la urmatoarea adresa memorie
    B"010000_00011_00011_1111111111111111", -- 0x4063FFFF | ADDI $3, $3, -1 | Face N--
    B"100000_00000000000000000000000100", -- 0x80000004 | J 4             | Sare la  BEQ $3, $0, 12

    OTHERS => X"00000000"
);
begin

process(clk,rst)
begin

 if rst = '1' then
 
    pc_out<=(others=>'0');
    
  elsif rising_Edge(clk) then
        if en = '1' then
              pc_out  <= mux_2_out;  
    end if;
    
    end if; 
    
end process;

instruction<=ROM(conv_integer(pc_out(6 downto 2)));

add_4_pc<=pc_out + X"00000004";

pc<=add_4_pc;

process(PCSrc,BranchAddress,add_4_pc)
begin

case PCSrc is

  when '1' => mux_1_out<=BranchAddress;
  when '0' => mux_1_out<=add_4_pc;
  when others => mux_1_out<=(others=>'0');
  
  end case;
  
 end process;
 
 process(Jump,JumpAddress,mux_1_out)
begin

case Jump is

  when '1' => mux_2_out<=JumpAddress;
  when '0' => mux_2_out<=mux_1_out;
  when others => mux_2_out<=(others=>'0');
  
  end case;
  
 end process;
 
end Behavioral;