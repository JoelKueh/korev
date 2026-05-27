
# Kore-V Architecture

Kore-V is a five stage RV32I softcore designed for an FPGA.

## Pipeline

1. Fetch Stage
  - Attached to the memory interface.
  - Loads each instruction and updates the PC.

```systemverilog
module fetch (
    // General inputs.
    input wire i_clk,
    input wire [31:0] i_pc,

    // Memory interface wires.
    output wire [31:0] i_imem_addr,  // The address we want to read.
    input  wire [31:0] i_imem_rdata, // The data that we read.

    // The fetched instruction.
    output logic [31:0] b_fetch_dec_instr, // Buffered output instruction.
    output wire [31:0] o_newpc             // The new pc.
);
```
