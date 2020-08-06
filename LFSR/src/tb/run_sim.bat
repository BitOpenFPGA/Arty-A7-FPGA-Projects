@echo on

call "C:\Xilinx\Vivado\2018.3\settings64.bat"
call xvhdl -nolog ../hdl/LFSR.vhd lfsr_tb.vhd 
call xelab -nolog lfsr_tb -debug off
call xsim -nolog work.lfsr_tb -R

REM cmd /k
