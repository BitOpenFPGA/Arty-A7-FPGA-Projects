# FPGA AES-128
This is an implementation of an Advanced Encryption Standard (AES) encryption core, targeting the Xilinx XC7A35TICSG324-1L FPGA found on the Digilent Arty A7 board. This AES core is designed for a key length of 128 bits and an input block size of 128 bits. Currently only the electronic codebook (ECB) mode of operation is implemented.

## Operation
The encryption core is fully pipelined. It can receive a new block of plaintext every clock cycle and, when the pipeline is filled, it produces a new block of ciphertext every clock cycle. The key expansion is performed fully parallel to the encryption, hence, the design is able to encrypt new data with different keys with no reduction in throughput. The latency of the design is 41 clock cycles: 4 clock cycles for each of the individual rounds (of which there are ten total rounds), plus an extra clock cycle for the initial add round key operation. A description of the ports is provided below. 

|Signal|Direction|Description |
|------|:---------:|------------|
|clk | in | input clock |
|rst | in | synchronous reset, active high |
|i_key | in | 128-bit key used for encryption |
|i_new_key_valid | in | valid signal for input key. Must be asserted for one clock cycle with every new input key|
|i_plaintext | in | 128-bit block of plaintext to be encrypted |
|i_plaintext_valid | in | valid signal for input plain text. Must be asserted for each new input block of plaintext  |
|o_ciphertext | out | output ciphertext i.e the plaintext encrypted|
|o_ciphertext_valid | out | valid signal asserted with valid ciphertext output|

Using the 100MHz on board oscillator on the Arty A7 as the main clock, the sustained throughput for the encryption is 128 bits * 100MHz = 12.8 Gbit/s. The maximum clock frequency that the design can run on is just over 300MHz (from Vivado) so the maximum sustained throughput is 128 bits * 300MHz = 38.4 Gbit/s.

## Resource utilisation
The resource use of the design is shown below for clock frequencies of 100MHz and 300MHz. The target FPGA is the Xilinx Artix-7 XC7A35TICSG324-1L found on the Digilent Arty A7 board. 

|Clock Frequency|LUTs|Registers|BRAMs| 
|---|---|---|---|
|100MHz|5420|11520|40|
|300MHz|12140|12928|0|

(To meet timing for the faster clock frequency, Vivado has implemented the ROMs for substitution box in LUTs as opposed to block RAM.)

## Testing
The design was tested using the example test vectors provided by NIST [here](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/block-ciphers#AES). This includes known answer tests, monte carlo testing and multiblock message tests. The *scripts* folder in this repository contains small Python scripts to automate the testing. The file, *parse_test_files.py*, parses the NIST response files and writes the test data to new files in the testbench directory in a format that is more easily read in by the VHDL testbench. *launch_sim.py* runs the Vivado simulator in scripted/batch mode, first compiling and elaborating the VHDL design files and then running the simulation for the testbench *AES_128_fileIO_tb.vhd*. The output of the testbench (i.e the ciphertext for each test) is written to text files in the directory *sim_output*. These are compared to the correct/reference values by the script *check_output.py*. Note that the simulation takes a little time to finish (approximately 5 minutes on my machine). This is mainly due to the monte carlo test, which runs through 100000 different inputs where the new input is generated based off the previous output ciphertext. 













