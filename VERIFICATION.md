
# Kore-V Verification

Kore-V is verified using a UVM testbench which makes use of a series of test programs. These test programs are executed against Spike (a software reference simulator produced by the RISC-V foundation). The simulator and reference core are configured to produce an RVVI trace 

The results of the simulator and the softcore are compared based on the output of their instruction trace. This is standardized based on the RFVI specification.
