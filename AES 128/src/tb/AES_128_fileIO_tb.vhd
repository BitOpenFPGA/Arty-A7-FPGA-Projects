library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity AES_128_fileIO_tb is
end entity;

architecture bahav of AES_128_fileIO_tb is

constant clk_period : time := 10 ns;
signal clk, rst : std_logic;
signal key_valid, ciphertext_valid, plaintext_valid : std_logic;
signal key, plaintext, ciphertext : std_logic_vector(127 downto 0);
-- signal round_key : std_logic_vector(127 downto 0);


file file_keys : text;
file file_plaintext : text;
file file_output : text;



begin


uut : entity work.AES_128
	port map (
		clk => clk,
		rst => rst,
		i_key => key,
		i_new_key_valid => key_valid,
		i_plaintext => plaintext,
		i_plaintext_valid => plaintext_valid,
		o_ciphertext => ciphertext,
		o_ciphertext_valid => ciphertext_valid
	);



generate_clk : process 
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

read_write_io : process 

variable iline1,iline2 : line;
variable oline : line;
variable input_key : std_logic_vector(127 downto 0);
variable input_plaintext : std_logic_vector(127 downto 0);
variable input_plaintext_line : std_logic_vector(1279 downto 0);
variable num_blocks_cnt : integer := 0;

begin
	rst <= '1';
	wait for clk_period;
	rst <= '0';
	wait until rising_edge(clk);
	for I in 0 to 4 loop
		-- -- For launching simulation manually in simulator. File paths for input are relative to location of testbench.
		-- if I = 0 then 
			-- file_open(file_keys, "NIST test vectors parsed\ECBGFSbox128\test_keys\keys.txt",  read_mode);
			-- file_open(file_plain_txt, "NIST test vectors parsed\ECBGFSbox128\test_plain_txt\plain_txt.txt",  read_mode);
			-- file_open(file_output, "ECBGFSbox128_output.txt", write_mode);
		-- elsif I = 1 then
			-- file_open(file_keys, "NIST test vectors parsed\ECBKeySbox128\test_keys\keys.txt",  read_mode);
			-- file_open(file_plain_txt, "NIST test vectors parsed\ECBKeySbox128\test_plain_txt\plain_txt.txt",  read_mode);
			-- file_open(file_output, "ECBKeySbox128_output.txt", write_mode);
		-- elsif I = 2 then
			-- file_open(file_keys, "NIST test vectors parsed\ECBVarKey128\test_keys\keys.txt",  read_mode);
			-- file_open(file_plain_txt, "NIST test vectors parsed\ECBVarKey128\test_plain_txt\plain_txt.txt",  read_mode);
			-- file_open(file_output, "ECBVarKey128_output.txt", write_mode);
		-- elsif I = 3 then
			-- file_open(file_keys, "NIST test vectors parsed\ECBVarTxt128\test_keys\keys.txt",  read_mode);
			-- file_open(file_plain_txt, "NIST test vectors parsed\ECBVarTxt128\test_plain_txt\plain_txt.txt",  read_mode);
			-- file_open(file_output, "ECBVarTxt128_output.txt", write_mode);
		
		-- end if;
		
		-- For launching simulation via python script. File paths for input are relative to location of script 
		if I = 0 then 
			file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBGFSbox128\test_keys\keys.txt",  read_mode);
			file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBGFSbox128\test_plain_txt\plain_txt.txt",  read_mode);
			file_open(file_output, "..\src\tb\sim_output\ECBGFSbox128_output.txt", write_mode);
		elsif I = 1 then
			file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBKeySbox128\test_keys\keys.txt",  read_mode);
			file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBKeySbox128\test_plain_txt\plain_txt.txt",  read_mode);
			file_open(file_output, "..\src\tb\sim_output\ECBKeySbox128_output.txt", write_mode);
		elsif I = 2 then
			file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBMCT128\test_keys\keys.txt",  read_mode);
			file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBMCT128\test_plain_txt\plain_txt.txt",  read_mode);
			file_open(file_output, "..\src\tb\sim_output\ECBMCT128_output.txt", write_mode);
		elsif I = 3 then
			file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBVarKey128\test_keys\keys.txt",  read_mode);
			file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBVarKey128\test_plain_txt\plain_txt.txt",  read_mode);
			file_open(file_output, "..\src\tb\sim_output\ECBVarKey128_output.txt", write_mode);
		elsif I = 4 then
			file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBVarTxt128\test_keys\keys.txt",  read_mode);
			file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBVarTxt128\test_plain_txt\plain_txt.txt",  read_mode);
			file_open(file_output, "..\src\tb\sim_output\ECBVarTxt128_output.txt", write_mode);
		
		end if;
		
		while not endfile(file_keys) loop
			readline(file_keys, iline1);
			readline(file_plaintext, iline2);
			hread(iline1, input_key);
			hread(iline2, input_plaintext);
			  
			--assign to signals
			key <= input_key;
			plaintext <= input_plaintext;
			plaintext_valid <= '1';
			key_valid <= '1';
			
			wait until rising_edge(clk);
			plaintext_valid <= '0';
			key_valid <= '0';
			if ciphertext_valid = '1' then --save data to file
				hwrite(oline, ciphertext);
				writeline(file_output, oline);
			end if;	
		end loop;
		
		--Wait for and save any data still outputting from pipeline
		for num_clks in 0 to 40 loop
			wait until rising_edge(clk);
			if ciphertext_valid = '1' then --save data to file
				hwrite(oline, ciphertext);
				writeline(file_output, oline);
			end if;	
		end loop;
		
		
		file_close(file_keys);
		file_close(file_plaintext);
		file_close(file_output);
	end loop;
	
	
	
	-- AES Monte Carlo Test (MMT). Algorithm specified in "The Advanced Encryption Standard Algorithm Validation Suite (AESAVS)" document.
	--
	-- 	Key[0] = Key
	-- 	PT[0] = PT
	-- 	For i = 0 to 99
	--		For j = 0 to 999
	-- 			CT[j] = AES(Key[i], PT[j])
	-- 			PT[j+1] = CT[j]
	-- 		Output CT[j]
	-- 		Key[i+1] = Key[i] xor CT[j]
	--		PT[0] = CT[j]
	
	-- For launching sim mannually - path relative to textbench
	-- file_open(file_keys, "NIST test vectors parsed\ECBMCT128\test_keys\keys.txt",  read_mode);
	-- file_open(file_plain_txt, "NIST test vectors parsed\ECBMCT128\test_plain_txt\plain_txt.txt",  read_mode);
	-- file_open(file_output, "ECBMCT128_output.txt", write_mode);
	
	-- For launching from script - path relative to script
	file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBMCT128\test_keys\keys.txt",  read_mode);
	file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBMCT128\test_plain_txt\plain_txt.txt",  read_mode);
	file_open(file_output, "..\src\tb\sim_output\ECBMCT128_output.txt", write_mode);
	
	wait until rising_edge(clk);
	readline(file_keys, iline1);
	readline(file_plaintext, iline2);
	hread(iline1, input_key);
	hread(iline2, input_plaintext);
	
	key <= input_key;
	plaintext <= input_plaintext;
	
	for I in 0 to 99 loop
		for J in 0 to 999 loop
			--assign to signals
			plaintext_valid <= '1';
			key_valid <= '1';
			wait until rising_edge(clk);
			plaintext_valid <= '0';
			key_valid <= '0';
			wait until ciphertext_valid = '1';
			plaintext <= ciphertext;
		end loop;
			key <= key xor ciphertext;
		--save output to file
		if ciphertext_valid = '1' then 
			hwrite(oline, ciphertext);
			writeline(file_output, oline);
		end if;	
	end loop;


	file_close(file_keys);
	file_close(file_plaintext);
	file_close(file_output);
	
	-- AES Multiblock Message Test (MMT)
	-- Text file has input plain text with various number of blocks, so it must be handled differently to the previous test vectors
	
	-- file_open(file_keys, "NIST test vectors parsed\ECBMMT128\test_keys\keys.txt",  read_mode);
	-- file_open(file_plain_txt, "NIST test vectors parsed\ECBMMT128\test_plain_txt\plain_txt.txt",  read_mode);
	-- file_open(file_output, "ECBMMT128_output.txt", write_mode);
	
	
	--for when launching tb from script
	file_open(file_keys, "..\src\tb\NIST test vectors parsed\ECBMMT128\test_keys\keys.txt",  read_mode);
	file_open(file_plaintext, "..\src\tb\NIST test vectors parsed\ECBMMT128\test_plain_txt\plain_txt.txt",  read_mode);
	file_open(file_output, "..\src\tb\sim_output\ECBMMT128_output.txt", write_mode);
	
	wait until rising_edge(clk);

	while not endfile(file_keys) loop
		readline(file_keys, iline1);
		readline(file_plaintext, iline2);
		hread(iline1, input_key);
		hread(iline2, input_plaintext_line(input_plaintext_line'high downto input_plaintext_line'high - iline2'length*4+1));
		-- report integer'image(iline2'length);
		--assign key to signal
		key <= input_key;
		
		-- for each new block of data with same key
		-- txt file is organised with first test case having 1 block, then second case 2 blocks and so on.
		for J in 0 to num_blocks_cnt loop 
			plaintext <= input_plaintext_line(1279-(J*128) downto 1279-(J*128)-127);
			plaintext_valid <= '1';
			key_valid <= '1';
			
			wait until rising_edge(clk);
			
			plaintext_valid <= '0';
			key_valid <= '0';
			if ciphertext_valid = '1' then --save data to file
				hwrite(oline, ciphertext);
				writeline(file_output, oline);
			end if;	
		end loop;
		num_blocks_cnt := num_blocks_cnt + 1;
	end loop;
	
	--Wait for and save any data still outputting from pipeline
	for num_clks in 0 to 40 loop
		wait until rising_edge(clk);
		if ciphertext_valid = '1' then --save data to file
			hwrite(oline, ciphertext);
			writeline(file_output, oline);
		end if;	
	end loop;
	
	file_close(file_keys);
	file_close(file_plaintext);
	file_close(file_output);
	
	
	

	assert false report "end of simulation" severity failure;
	
	

end process;

end;