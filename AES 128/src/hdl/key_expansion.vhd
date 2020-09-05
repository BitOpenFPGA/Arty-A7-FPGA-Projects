library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity key_expansion is 
port (	clk : in std_logic;
		rst : in std_logic;
		i_cipher_key : in std_logic_vector(127 downto 0);
		i_cipher_key_valid: in std_logic;
		o_init_key : out std_logic_vector(127 downto 0);
		o_round_key_0 : out std_logic_vector(127 downto 0);
		o_round_key_1 : out std_logic_vector(127 downto 0);
		o_round_key_2 : out std_logic_vector(127 downto 0);				
		o_round_key_3 : out std_logic_vector(127 downto 0);				
		o_round_key_4 : out std_logic_vector(127 downto 0);				
		o_round_key_5 : out std_logic_vector(127 downto 0);				
		o_round_key_6 : out std_logic_vector(127 downto 0);				
		o_round_key_7 : out std_logic_vector(127 downto 0);				
		o_round_key_8 : out std_logic_vector(127 downto 0);				
		o_round_key_9 : out std_logic_vector(127 downto 0);				
		o_keys_valid : out std_logic		
	);
end entity;

architecture rtl of key_expansion is 

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


--counter to keep track of current key round
signal key_round_count : natural range 0 to 9;
 
--counter to keep track of word within the 128 bit key. Word length 32 bits, 4 words per key
signal current_key_word_cnt : unsigned(1 downto 0);

-- Store previous computed key for generation of next key
signal prev_key : std_logic_vector(127 downto 0);

type key_expansion_state_t is (WAIT_FOR_NEW_KEY, DO_KEY_EXP);
signal key_exp_state : key_expansion_state_t := WAIT_FOR_NEW_KEY;

type round_key_arr_t is array (0 to 9) of std_logic_vector(127 downto 0);
signal round_key_arr : round_key_arr_t;


begin


key_schedule: process(clk)
variable rot_sub_word, tmp : std_logic_vector(31 downto 0);
begin 
if rising_edge(clk) then
	if rst = '1' then
		key_round_count <= 0;
		current_key_word_cnt <= (others => '0');
		key_exp_state <= WAIT_FOR_NEW_KEY;
		o_keys_valid <= '0';
	else
		case key_exp_state is
			when WAIT_FOR_NEW_KEY =>
				key_round_count <= 0;
				current_key_word_cnt <= (others => '0');
				if (i_cipher_key_valid ='1') then
					prev_key <= i_cipher_key;
					key_exp_state <= DO_KEY_EXP;
					o_init_key <= i_cipher_key;
					o_keys_valid <= '0';
				end if;
			when DO_KEY_EXP => 
				current_key_word_cnt <= current_key_word_cnt+1;
				case current_key_word_cnt is
					when "00" => 
						rot_sub_word := sbox_rom(to_integer(unsigned(prev_key(23 downto 16)))) & sbox_rom(to_integer(unsigned(prev_key(15 downto 8)))) & sbox_rom(to_integer(unsigned(prev_key(7 downto 0)))) & sbox_rom(to_integer(unsigned(prev_key(31 downto 24))));
						round_key_arr(key_round_count)(127 downto 96) <= prev_key(127 downto 96) xor rot_sub_word xor (rcon_rom(key_round_count) & x"000000");
					when "01" => 
						round_key_arr(key_round_count)(95 downto 64) <= prev_key(95 downto 64) xor round_key_arr(key_round_count)(127 downto 96);
					when "10" => 
						round_key_arr(key_round_count)(63 downto 32) <= prev_key(63 downto 32) xor round_key_arr(key_round_count)(95 downto 64);
					when "11" => 
						tmp := prev_key(31 downto 0) xor round_key_arr(key_round_count)(63 downto 32);
						round_key_arr(key_round_count)(31 downto 0) <= tmp;
						prev_key <= round_key_arr(key_round_count)(127 downto 32) & tmp;
						if (key_round_count = 9) then 
							key_exp_state <= WAIT_FOR_NEW_KEY;
							o_keys_valid <= '1';
						else
							key_round_count <= key_round_count+1;
						end if;
					when others => NULL;
				end case;
		end case;
	end if;
end if;



end process;


o_round_key_0 <=round_key_arr(0);
o_round_key_1 <=round_key_arr(1);
o_round_key_2 <=round_key_arr(2);				
o_round_key_3 <=round_key_arr(3);				
o_round_key_4 <=round_key_arr(4);				
o_round_key_5 <=round_key_arr(5);				
o_round_key_6 <=round_key_arr(6);				
o_round_key_7 <=round_key_arr(7);				
o_round_key_8 <=round_key_arr(8);				
o_round_key_9 <=round_key_arr(9);	


end;
