library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component IFetch is
    Port ( jump : in STD_LOGIC;
           jumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           PCSrc : in STD_LOGIC;
           branchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           pc : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component ID is
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
end component;

component UC is
    Port ( 
        instr    : in  std_logic_vector (5 downto 0); 
        regDst   : out std_logic;
        extOp    : out std_logic;
        ALUSrc   : out std_logic;
        branch   : out std_logic;
        jump     : out std_logic;
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        RegWrite : out std_logic;
        ALUOp    : out std_logic_vector (2 downto 0)
    );
end component;

component ex is
  Port ( 
    RD1: in std_logic_vector(31 downto 0);
    ALUSrc: in std_logic;
    RD2: in std_logic_vector(31 downto 0);
    Ext_Imm: in std_logic_vector(31 downto 0);
    sa: in std_logic_vector(4 downto 0);
    func: in std_logic_vector(5 downto 0);
    ALUOp: in std_logic_vector(2 downto 0);
    pc_plus_4: in std_logic_vector(31 downto 0);
    gtz: out std_logic;
    zero: out std_logic;
    alu_res: out std_logic_vector(31 downto 0);
    BrachAddress: out std_logic_vector(31 downto 0)
  );
end component;

component mem is
  Port (
    mem_write: in std_logic;
    alu_in: in std_logic_vector(31 downto 0);
    RD2: in std_logic_vector(31 downto 0);
    clk: in std_logic;
    en: in std_logic;
    mem_data: out std_logic_vector(31 downto 0);
    alu_out: out std_logic_vector(31 downto 0)
   );
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

signal en_sig: std_Logic;
signal instr_sig, pc_plus_sig: std_logic_vector(31 downto 0);
signal rd1_sig, rd2_sig, ext_sig: std_Logic_vector(31 downto 0);
signal sa_sig: std_logic_vector(4 downto 0);
signal func_sig: std_Logic_vector(5 downto 0);
signal regdst_sig, extop_sig, alusrc_sig, branch_sig, jump_sig, memwrite_sig, memtoreg_sig, regwrite_sig: std_Logic;
signal aluop_sig: std_logic_vector(2 downto 0);

signal alu_res_sig, alu_out_sig, mem_data_sig : std_logic_vector(31 downto 0);
signal branch_addr_sig : std_logic_vector(31 downto 0);
signal jump_addr_sig : std_logic_vector(31 downto 0);
signal zero_sig, gtz_sig : std_logic;
signal pc_src_sig : std_logic;
signal wd_sig : std_logic_vector(31 downto 0);
signal mux_out: std_Logic_vector(31 downto 0);

begin

mpg1: MPG port map(en_sig, btn(0), clk);

jump_addr_sig <= pc_plus_sig(31 downto 28) & instr_sig(25 downto 0) & "00";
pc_src_sig <= branch_sig and zero_sig;

instr_fetch: IFetch port map(
    jump          => jump_sig, 
    jumpAddress   => jump_addr_sig, 
    PCSrc         => pc_src_sig, 
    branchAddress => branch_addr_sig,
    en            => en_sig, 
    rst           => btn(1), 
    clk           => clk,
    pc            => pc_plus_sig, 
    instruction   => instr_sig
);

unitate_control: UC port map(
    instr    => instr_sig(31 downto 26),
    regDst   => regdst_sig, 
    extOp    => extop_sig,
    ALUSrc   => alusrc_sig, 
    branch   => branch_sig,
    jump     => jump_sig, 
    MemWrite => memwrite_sig,
    MemtoReg => memtoreg_sig,
    RegWrite => regwrite_sig,
    ALUOp    => aluop_sig
);

wd_sig <= mem_data_sig when memtoreg_sig = '1' else alu_out_sig;

id1: ID port map(
    regWrite => regwrite_sig,
    Instr    => instr_sig(25 downto 0),
    regDst   => regdst_sig, 
    en       => en_sig,
    extOp    => extop_sig, 
    RD1      => rd1_sig,
    RD2      => rd2_sig, 
    WD       => wd_sig, 
    ext_Imm  => ext_sig,
    func     => func_sig,
    sa       => sa_sig,
    clk      => clk
);

-- EX
ex_inst: ex port map(
    RD1          => rd1_sig,
    ALUSrc       => alusrc_sig,
    RD2          => rd2_sig,
    Ext_Imm      => ext_sig,
    sa           => sa_sig,
    func         => func_sig,
    ALUOp        => aluop_sig,
    pc_plus_4    => pc_plus_sig,
    gtz          => gtz_sig,
    zero         => zero_sig,
    alu_res      => alu_res_sig,
    BrachAddress => branch_addr_sig
);

-- MEM
mem_inst: mem port map(
    mem_write => memwrite_sig,
    alu_in    => alu_res_sig,
    RD2       => rd2_sig,
    clk       => clk,
    en        => en_sig,
    mem_data  => mem_data_sig,
    alu_out   => alu_out_sig
);

process(sw(7 downto 5), instr_sig, pc_plus_sig, rd1_sig, rd2_sig, ext_sig, alu_res_sig, mem_data_sig, wd_sig)
begin
   case sw(7 downto 5) is
       when "000" => mux_out <= instr_sig;
       when "001" => mux_out <= pc_plus_sig; 
       when "010" => mux_out <= rd1_sig;
       when "011" => mux_out <= rd2_sig;
       when "100" => mux_out <= ext_sig;
       when "101" => mux_out <= alu_res_sig;
       when "110" => mux_out <= mem_data_sig;
       when "111" => mux_out <= wd_sig;
       when others => mux_out <= (others => '0');
  end case;
end process;
 
ssd1: SSD port map(clk, mux_out, an, cat);

led(10 downto 0) <= aluop_sig & regdst_sig & extop_sig & alusrc_sig & branch_sig & jump_sig & memwrite_sig & memtoreg_sig & regwrite_sig;

end Behavioral;