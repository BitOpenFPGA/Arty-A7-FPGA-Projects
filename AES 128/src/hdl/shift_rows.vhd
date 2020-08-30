library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Performs the shift rows transformation
entity shift_rows is
port ( 	i_data_block : in std_logic_vector(127 downto 0);
		i_data_valid : in std_logic;
		o_data_block : out std_logic_vector(127 downto 0);
		o_data_valid : out std_logic
	);

end entity;

architecture rtl of shift_rows is 



begin

o_data_valid <= i_data_valid;

--first row of bytes unchanged - corresponding to byte 0,4,8,12, i.e 127 downto 120, 95 downto 88, 63 downto 56, 31 downto 24
o_data_block(127 downto 120) <= i_data_block(127 downto 120);
o_data_block(95 downto 88) <= i_data_block(95 downto 88);
o_data_block(63 downto 56) <= i_data_block(63 downto 56);
o_data_block(31 downto 24) <= i_data_block(31 downto 24);

--Second row of bytes: one cyclic left shift - byte 1,5,9,13 -> 5,9,13,1
o_data_block(119 downto 112) <= i_data_block(87 downto 80); 
o_data_block(87 downto 80) <= i_data_block(55 downto 48);
o_data_block(55 downto 48) <= i_data_block(23 downto 16);
o_data_block(23 downto 16) <= i_data_block(119 downto 112);

--Third row of bytes: two cyclic left shift - byte 2,6,10,14 -> 10,14,2,6
o_data_block(111 downto 104) <= i_data_block(47 downto 40);
o_data_block(79 downto 72) <= 	i_data_block(15 downto 8);
o_data_block(47 downto 40) <= 	i_data_block(111 downto 104);
o_data_block(15 downto 8) <= 	i_data_block(79 downto 72);

--Fourth row of bytes: three cyclic left shift - byte 3,7,11,15 -> 15,3,7,11
o_data_block(103 downto 96) <= 	i_data_block(7 downto 0);
o_data_block(71 downto 64) <= 	i_data_block(103 downto 96);
o_data_block(39 downto 32) <= 	i_data_block(71 downto 64);
o_data_block(7 downto 0) <= 	i_data_block(39 downto 32);

end;