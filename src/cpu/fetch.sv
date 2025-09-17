
/*
 * Module 'fetch'
 *
 * Implements the instruction fetch stage of the processor.
 */
module fetch (
    /* General inputs. */
    input wire clk,
    input wire [31:0] pc,

    /* Memory interface wires. */
    output wire [31:0] imem_addr,  /* The address we want to read. */
    input  wire        imem_drdy,  /* Asserted when imem_rdata is ready. */
    input  wire [31:0] imem_rdata, /* The data that we read. */

    /* The fetched instruction. */
    output logic [31:0] fetch_dec_instr,
    output logic [31:0] newpc      /* The new pc. */
);

  /* The PC holds the value of the next instruction to be executed. */
  assign imem_addr = pc;

  /* Awesome branch predictor. We won't take the branch. */
  always_ff @(posedge clk) begin
    fetch_dec_instr <= imem_rdata;
    newpc <= pc + 1;
  end
endmodule
