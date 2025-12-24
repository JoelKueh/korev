
// Module 'mem'
// Handles the mem stage of the processor.
module mem (
    // CPU General.
    input clk,

    // Register numbers for forwarding.
    input [5:0] dec_exec_rs1,
    input [5:0] dec_exec_rs2,
    input [5:0] dec_exec_rd,

    // Branch output.
    input [31:0] exec_mem_bta,         // Branch target address.
    input [31:0] exec_mem_brnch_taken, // Will we take the bta?

    // Control signals.
    input exec_mem_writeback,
    input exec_mem_link,
    input exec_mem_mem_w,     // Write to memory?
    input exec_mem_mem_r,     // Read from memory?
    input exec_mem_mem_rdu,   // Unsigned memory read?
    input exec_mem_mem_byte,  // Byte op size?
    input exec_mem_mem_hwrd,  // Halfword op size?
    input exec_mem_mem_wrd,   // Word op size?

    // Execute alu outputs.
    input [31:0] exec_mem_alu_result,  // Result of the alu.
    input [31:0] exec_mem_mem_wdata,   // Data written to memory.

    // Data memory interface.
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output wire dmem_write,
    output wire dmem_read,
    output wire dmem_rdu,
    output wire dmem_byte,
    output wire dmem_hwrd,
    output wire dmem_wrd,
    input wire [31:0] dmem_rdata,

    // Outputs to writeback stage.
    output logic        mem_wb_writeback,  // Should we write to registers.
    output logic [31:0] mem_wb_data,       // The data to write.
    output logic [ 5:0] mem_wb_rd          // The register to write to.
);

  // Prepare memory reads.
  assign dmem_addr  = exec_mem_alu_result;
  assign dmem_wdata = exec_mem_mem_wdata;
  assign dmem_write = exec_mem_mem_w;
  assign dmem_read  = exec_mem_mem_r;
  assign dmem_rdu   = exec_mem_mem_rdu;
  assign dmem_byte  = exec_mem_mem_byte;
  assign dmem_hwrd  = exec_mem_mem_hwrt;
  assign dmem_wrd   = exec_mem_mem_wrd;

  // Forward information on to the ext stage.
  always_ff @(posedge clk) begin
    mem_wb_writeback <= exec_mem_writeback;
    mem_wb_data <= exec_mem_mem_r ? dmem_rdata : exec_mem_alu_result;
  end

endmodule
