
/*
 * Module 'fetch'
 *
 * Implements the instruction fetch stage of the processor.
 */
module fetch (
    /* General inputs. */
    input clk,
    input [31:0] pc,

    /* Memory interface wires. */
    output wire [31:0] imem_addr,  /* The address we want to read. */
    input  wire        imem_drdy,  /* Asserted when imem_rdata is ready. */
    input  wire [31:0] imem_rdata, /* The data that we read. */

    /* Execute array outputs */
    output logic [31:0] exec_mem_out
);

  /* The PC holds the value of the next instruction to be executed. */
  assign imem_addr = pc;

  /* Awesome branch predictor. We won't take the branch. */
  always_ff @(posedge clk) begin
    exec_mem_out <= imem_rdata;
    pc <= pc + 1;
  end
endmodule
