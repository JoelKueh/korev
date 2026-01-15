
// Module 'writeback'
// Handles the writeback stage of the processor.
// This does cleaning on reads from 'mem' and handles rfile writes.
module writeback (
    // CPU General
    input i_clk,

    // Data from mem stage
    input wire        i_mem_wb_writeback,  // Writeback?
    input wire [31:0] i_mem_wb_data,       // The data to write.
    input wire [ 5:0] i_mem_wb_rd,         // The register to write to.

    // regfile write interface
    output wire        o_write,
    output wire [31:0] o_data,
    output wire [ 5:0] o_regno
);

  // Handle register control signals
  assign o_write = i_mem_wb_writeback;
  assign o_data = i_mem_wb_data;
  assign o_regno = i_mem_wb_rd;

endmodule

