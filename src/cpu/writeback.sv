
// Module 'writeback'
// Handles the writeback stage of the processor.
// This does cleaning on reads from 'mem' and handles rfile writes.
module writeback (
    // CPU General
    input i_clk,

    // Data from mem stage
    input wire        i_mem_wb_writeback,  // Should we write to registers
    input wire [ 1:0] i_mem_wb_shamt,      // Shift amount for memory operation
    input wire        i_mem_wb_rdu,        // Unsigned memory operation?
    input wire        i_mem_wb_op_byte,    // Byte-wide memory operation?
    input wire        i_mem_wb_op_hwrd,    // Word-wide memory operation?
    input wire [31:0] i_mem_wb_data,       // The data to write
    input wire [ 5:0] i_mem_wb_rd,         // The register to write to

    // regfile write interface
    output wire [31:0] regdata,
    output wire [5:0] regno,
    output wire write
);

  // Handle register control signals
  assign regno = i_mem_wb_rd;
  assign write = i_mem_wb_writeback;

  // Set register data
  logic sext_bit;
  logic [15:0] dmem_shifted;
  always_comb begin
    if (i_dmem_op_byte) begin
      // Fix input data for byte-wide reads.
      dmem_shifted = dmem_rdata >> i_mem_wb_shamt;
      sext_bit = i_dmem_rdu ? 1'b0 : dmem_shifted[7];
      regdata = {{24{sext_bit}}, dmem_shifted[7:0]};
    end else if (i_dmem_op_hwrd) begin
      // Fix input data for half-word-wide reads.
      dmem_shifted = dmem_rdata >> {i_mem_wb_shamt[1], 1'b0};
      sext_bit = i_dmem_rdu ? 1'b0 : dmem_shifted[15];
      regdata = {{16{sext_bit}}, dmem_shifted[15:0]};
    end else begin
      // Otherwise pass data directly to registers.
      regdata = mem_wb_data;
    end
  end

endmodule

