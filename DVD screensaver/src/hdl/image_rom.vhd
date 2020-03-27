library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

--image map size 144*78. Store in two block rams
entity image_rom is
generic ( 	DATA_WIDTH : natural := 144;
			DEPTH : natural := 78;
			ADDR_WIDTH : natural := 7);
port (	clk : in std_logic;
		r_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
		data : out std_logic_vector(DATA_WIDTH-1 downto 0) );
end entity;

architecture rtl of image_rom is 
type rom_t is array (0 to DEPTH-1) of bit_vector(DATA_WIDTH-1 downto 0);

impure function mem_init(file_name : string)
             return rom_t is
file fp : text open read_mode is file_name;
variable image_data : rom_t:= (others=>(others=>'0'));
variable i_line : line; 
begin
	--iterate though rows in file
 for i in 0 to DEPTH-1 loop
	readline(fp, i_line);
	read(i_line, image_data(i));
 end loop;
 return image_data;
end mem_init;



--signal rom : rom_t := (0=> (others=> '1'), 1=> (others=> '0'), 2=>(others=> '0'), others=> (others=> '1') );
signal rom : rom_t := mem_init("data.txt"); --NOTE: REPLACE WITH FULL ABSOLUTE PATH TO TXT FILE


attribute rom_style : string;
attribute rom_style of rom : signal is "block";

begin

process (clk) is
begin
	if rising_edge(clk) then 
		data <= to_stdlogicvector(rom(to_integer(unsigned(r_addr)))); 
	end if;
end process;



end architecture;