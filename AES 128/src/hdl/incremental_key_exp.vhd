library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Performs the key schedule for one round
-- Latency is 3 clock cycles, so that the data is aligned/ready for add round key stage
entity incremental_key_exp is 
generic ( ROUND_NUMBER : natural);
port (	clk : in std_logic;
		rst : in std_logic;
		i_prev_key : in std_logic_vector(127 downto 0);
		i_prev_key_valid: in std_logic;
		o_round_key : out std_logic_vector(127 downto 0);				
		o_round_key_valid : out std_logic		
	);
end entity;

architecture rtl of incremental_key_exp is 

type sbox_rom_t is array (0 to 255) of std_logic_vector(7 downto 0);
constant sbox_rom : sbox_rom_t := (	x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
									x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
									x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
									x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
									x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
									x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
									x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
									x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
									x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
									x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
									x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
									x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
									x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
									x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
									x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
									x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16");   

type rcon_rom_t is array (0 to 9) of std_logic_vector(7 downto 0);
signal rcon_rom : rcon_rom_t := (x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36"); 


signal word1_l0, word2_l0, word3_l0, word4_l0 : std_logic_vector(31 downto 0);
signal word1_l1, word2_l1, word3_l1, word4_l1 : std_logic_vector(31 downto 0);

signal rot_sub_word : std_logic_vector(31 downto 0);

signal valid_sig_delay_line : std_logic_vector(2 downto 0);


begin


key_schedule : process (clk) 
begin 
if rising_edge(clk) then
	valid_sig_delay_line <= valid_sig_delay_line(1 downto 0) & i_prev_key_valid;
	if i_prev_key_valid = '1' then
		
		-- End result should be
		-- 4 32-bit word make up a round key 
		-- w1 - sub(rot(w[i-1])) xor rcon(i/Nk)
		-- w2 - w[i-1] xor w[i-nk]
		-- w3 - w[i-1] xor w[i-nk]
		-- w4 - w[i-1] xor w[i-nk]
		
		--first pipeline level
		rot_sub_word <= sbox_rom(to_integer(unsigned(i_prev_key(23 downto 16)))) & sbox_rom(to_integer(unsigned(i_prev_key(15 downto 8)))) & sbox_rom(to_integer(unsigned(i_prev_key(7 downto 0)))) & sbox_rom(to_integer(unsigned(i_prev_key(31 downto 24))));
		word1_l0 <= i_prev_key(127 downto 96);
		word2_l0 <= i_prev_key(95 downto 64) xor (rcon_rom(ROUND_NUMBER) & x"000000");
		word3_l0 <= i_prev_key(63 downto 32);
		word4_l0 <= i_prev_key(31 downto 0);
		
	end if;
		
		
	-- Second pipeline level
	word1_l1 <= word1_l0 xor rot_sub_word xor (rcon_rom(ROUND_NUMBER) & x"000000"); -- done
	word2_l1 <= word2_l0 xor word1_l0 xor rot_sub_word; -- done
	word3_l1 <= word3_l0; -- i_prev_key(127 downto 96) xor rot_sub_word xor i_prev_key(63 downto 32), need 
	word4_l1 <= word4_l0; 
		
	-- Output - third pipeline level
	if valid_sig_delay_line(1) = '1' then
		o_round_key <= word1_l1 & word2_l1 & (word3_l1 xor word2_l1) & (word3_l1 xor word2_l1 xor word4_l1);
	end if;

end if;		
	
end process;

o_round_key_valid <= valid_sig_delay_line(valid_sig_delay_line'high);

end;
