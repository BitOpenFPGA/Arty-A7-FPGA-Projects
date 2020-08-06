# Runs the testbench in xsim (Vivado) in batch mode and checks the output with the reference values.
from subprocess import Popen
import filecmp
import numpy as np

filepath=r"C:\Users\Philip\Documents\FPGA\FPGA projects\Random_Arty_A7_Projects\LFSR\src\tb" #change to path of batch file
p = Popen("run_sim.bat", cwd=filepath) #run the simulation by calling batch file
stdout, stderr = p.communicate() #wait for simulation to finish



#check output with reference value
print("\n\n\n----------------------------------------------------")

# # if filecmp.cmp("LFSR_tb_output.txt", "LFSR_ref_values.txt"):
	# # print("Test case 1: Passed")
# # else:
	# # print("Test case 1: Failed")
	
#load vectors into numpy arrays and check for equality
tb_output = np.loadtxt("LFSR_tb_output.txt")
ref_vals = np.loadtxt("LFSR_ref_values.txt")

if np.array_equal(tb_output, ref_vals):
	print("Test Case 1: Passed")
else: 
	print("Test Case 1: Failed")
	diff_idx = np.nonzero(np.equal(tb_output, ref_vals)==False)
	print("Diff values at lines: " +  str(diff_idx[0]))
	
print("----------------------------------------------------")





