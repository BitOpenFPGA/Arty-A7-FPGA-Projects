import os
from pathlib import Path
import subprocess 

# Generate shell commands to launch simulation

# Path for all design sources
design_files_path = '..\src\hdl\\'


xvhdl_cmd = 'xvhdl --nolog '

# May need to run this a few times to resolve dependencies.
# for i in range(3):
for filename in os.listdir(design_files_path):
	p = subprocess.Popen(xvhdl_cmd + design_files_path + filename ,shell=True) 
	stdout, stderr = p.communicate()
	
p = subprocess.Popen(xvhdl_cmd + "..\src\\tb\AES_128_fileIO_tb.vhd" ,shell=True) 
stdout, stderr = p.communicate()	
	
xelab_cmd = 'xelab --nolog AES_128_fileIO_tb -debug off'
xsim_cmd = 'xsim --nolog work.AES_128_fileIO_tb -R'


p = subprocess.Popen(xelab_cmd,shell=True) 
stdout, stderr = p.communicate()

p = subprocess.Popen(xsim_cmd,shell=True)
stdout, stderr = p.communicate()


