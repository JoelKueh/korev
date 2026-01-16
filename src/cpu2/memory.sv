
// Module 'memory'
// Handles the memory interface stage of the pipeline.
module memory (
    // CPU General.
    input i_clk,

    // Register numbers for forwarding.
    input [5:0] i_exec_mem_rs1,
    input [5:0] i_exec_mem_rs2,
    input [5:0] i_exec_mem_rd,
    input [5:0] i_mem_wb_rd,

    // Pipeline data for forwarding
    input [31:0] i_mem_mem_forward,

    // Branch output.
    input [31:0] i_exec_mem_bta,         // Branch target address.
    input [31:0] i_exec_mem_brnch_taken, // Will we take the branch?

    // Control signals.
    input i_exec_mem_writeback,
    input i_exec_mem_link,
    input i_exec_mem_mem_w,     // Write to memory?
    input i_exec_mem_mem_r,     // Read from memory?
    input i_exec_mem_mem_rdu,   // Unsigned memory read?
    input i_exec_mem_mem_byte,  // Byte op size?
    input i_exec_mem_mem_hwrd,  // Halfword op size?
    input i_exec_mem_mem_wrd,   // Word op size?

    // Execute alu outputs.
    input [31:0] i_exec_mem_alu_result,  // Result of the alu.
    input [31:0] i_exec_mem_mem_wdata,   // Data written to memory.

    // Data memory interface.
    output wire [31:0] o_dmem_addr,
    output wire [31:0] o_dmem_wdata,
    output wire o_dmem_write,
    output wire o_dmem_read,
    output wire o_dmem_rdu,
    output wire o_dmem_byte,
    output wire o_dmem_hwrd,
    input wire [31:0] i_dmem_rdata,

    // Outputs to writeback stage.
    output logic        b_mem_wb_writeback,  // Should we write to registers.
    output logic        b_mem_wb_mem_addr,
    output logic [31:0] b_mem_wb_mem_data,      // The data read from memory.
    output logic [31:0] b_mem_wb_data,       // The data to write.
    output logic [ 5:0] b_mem_wb_rd          // The register to write to.
);

  // Prepare memory reads.
  assign o_dmem_addr  = i_exec_mem_alu_result;
  assign o_dmem_wdata = i_exec_mem_mem_wdata;
  assign o_dmem_write = i_exec_mem_mem_w;
  assign o_dmem_read  = i_exec_mem_mem_r;
  assign o_dmem_rdu   = i_exec_mem_mem_rdu;
  assign o_dmem_byte  = i_exec_mem_mem_byte;
  assign o_dmem_hwrd  = i_exec_mem_mem_hwrd;

  // Forward information onto the next stage.
  always_ff @(posedge i_clk) begin
    o_mem_wb_writeback <= i_exec_mem_writeback;
    o_mem_wb_data <= i_exec_mem_mem_r ? i_dmem_rdata : i_exec_mem_alu_result;
  end

endmodule

