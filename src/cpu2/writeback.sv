
// Module 'writeback'
// Handles the writeback stage of the processor.
// This does cleaning on reads from 'mem' and handles rfile writes.
module writeback (
    // CPU General
    input i_clk,

    // Data from mem stage
    input wire        i_mem_wb_writeback,  // Writeback?
    input wire        i_mem_wb_mem_r,      // Was this operation a read?
    input wire        i_mem_wb_mem_rdu,    // Was memory read unsigned?
    input wire [31:0] i_mem_wb_mem_addr,   // The addr that we read from.
    input wire [31:0] i_mem_wb_mem_data,   // The data that we read.
    input wire [31:0] i_mem_wb_alu_result, // The result of the alu operation.
    input wire [ 5:0] i_mem_wb_rd,         // The register to write to.

    // regfile write interface
    output wire        o_write,
    output wire [31:0] o_data,
    output wire [ 5:0] o_regno
);

  // Shift output into the right spot for byte-wide reads.
  logic sext_bit;
  logic [15:0] dmem_shifted;
  logic [31:0] mem_result;
  always_comb begin
    if (i_dmem_op_byte) begin
      // Fix input data for byte-wide reads.
      dmem_shifted = i_mem_wb_mem_data >> i_mem_wb_mem_addr[1:0];
      sext_bit = i_mem_wb_mem_rdu ? 1'b0 : dmem_shifted[7];
      mem_result = {{24{sext_bit}}, dmem_shifted[7:0]};
    end else if (i_dmem_op_hwrd) begin
      // Fix input data for half-word-wide reads.
      dmem_shifted = o_dmem_rdata >> {i_dmem_addr[1], 1'b0};
      sext_bit = i_dmem_rdu ? 1'b0 : dmem_shifted[15];
      mem_result = {{16{sext_bit}}, dmem_shifted[15:0]};
    end else begin
      // Otherwise just output the data as it is.
      mem_result = o_mem_wb_data;
    end
  end

  // Handle register control signals
  assign o_write = i_mem_wb_writeback;
  assign o_data = i_mem_wb_mem_r ? i_mem_wb_data : i_mem_wb_alu_result;
  assign o_regno = i_mem_wb_rd;

endmodule

