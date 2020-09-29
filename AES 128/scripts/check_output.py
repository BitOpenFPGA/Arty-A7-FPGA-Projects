
# Checks the output of the AES testbench (written to text file) with the supplied sample test vectors provided by NIST

import os

test_names = []
for filename in os.listdir("NIST test vectors"):
	test_names.append(filename[:-4])

for test in test_names:
	# File path for text files with the correct/reference output
	ref_output_path = "..\\src\\tb\\NIST test vectors parsed\\" + test + "\\test_reference_output\\ref_output.txt" 
	
	# File path for the output of the AES 128 design (unit under test) from the testbench
	uut_output_path = "..\\src\\tb\\sim_output\\" + test + "_output.txt"
	print(test)
	test_passed = True
	
	
	with open(ref_output_path,'r') as fp_ref_output:
		with open(uut_output_path,'r') as fp_uut_output:
			
			
			# Multi message test is formatted with whole output relatin to a single key on a single line, whereas testbench output has 128 bits per line
			if test == "ECBMMT128":
				for idx, ref_line in enumerate(fp_ref_output):
					for num_block in range(idx+1):
						uut_output = fp_uut_output.readline()
						ref_output = ref_line[32*num_block:32*(num_block+1)] + "\n"
						if uut_output.lower() != ref_output.lower():
							test_passed = False
							print("line: " + str(idx))
							print("expected output: " + ref_output + "uut output: " + uut_output.lower())
			else:
				for idx, ref_output in enumerate(fp_ref_output):
					uut_output = fp_uut_output.readline()
					if uut_output.lower() != ref_output.lower():
						test_passed = False
						print("line: " + str(idx))
						print("expected output: " + ref_output + "uut output: " + uut_output.lower())
					
	
	if test_passed:
		print("Test Passed\n\n")
	else:
		print("Test Failed\n\n")
				
