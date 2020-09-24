import os
from pathlib import Path

# Script to parse the test vectors from the file provided by NIST and put in separate text files in a form
# more easily read in the VHDL testbench. 


dir_name = "NIST test vectors"
os.chdir(dir_name)
for filename in os.listdir('.'):
	Path("../../src/tb/NIST test vectors parsed/" + filename[:-4]).mkdir(parents=True, exist_ok=True)
	Path("../../src/tb/NIST test vectors parsed/" + filename[:-4] + "/test_keys").mkdir(parents=True, exist_ok=True)
	Path("../../src/tb/NIST test vectors parsed/" + filename[:-4] + "/test_plain_txt").mkdir(parents=True, exist_ok=True)
	Path("../../src/tb/NIST test vectors parsed/" + filename[:-4] + "/test_reference_output").mkdir(parents=True, exist_ok=True)
	cipher_text = []
	keys = []
	plain_text = []
	with open(filename,'r') as fp:
		while True:
			line_buf = fp.readline()
			str_buf = line_buf.split()
			if str_buf:
				if str_buf[0] == "[DECRYPT]":
					break
				elif str_buf[0] == "KEY":
					keys.append(str_buf[2])
				elif str_buf[0] == "PLAINTEXT":
					plain_text.append(str_buf[2])			
				elif str_buf[0] == "CIPHERTEXT":
					cipher_text.append(str_buf[2])
	
	#Write keys to txt file
	with open("../../src/tb/NIST test vectors parsed/" + filename[:-4] + "/test_keys/keys.txt", 'w') as fp:
		for key in keys:
			fp.write(key)
			fp.write("\n")
	#write plain text data to file	
	with open("../../src/tb/NIST test vectors parsed/" + filename[:-4] + "/test_plain_txt/plain_txt.txt", 'w') as fp:
		for input_text in plain_text:
			fp.write(input_text)
			fp.write("\n")
	#write cipher text data	to file
	with open("../../src/tb/NIST test vectors parsed/" + filename[:-4] + "/test_reference_output/ref_output.txt", 'w') as fp:
		for reference_output in cipher_text:
			fp.write(reference_output)
			fp.write("\n")