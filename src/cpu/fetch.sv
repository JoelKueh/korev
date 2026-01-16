
// Module 'fetch'
// Implements the instruction fetch stage of the processor.
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

  // The PC holds the value of the next instruction to be executed.
  assign imem_addr = pc;
  assign newpc = pc + 1;

  // Awesome branch predictor. We won't take the branch ever.
  always_ff @(posedge clk) begin
    fetch_dec_instr <= imem_rdata;
  end

endmodule
