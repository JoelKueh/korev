
// Module 'mem'
// Handles the memory interface for the entire softcore.
//
// The implementation of this memory module is as follows.
// 1. Supports simultaneous imem rd and dmem wr.
// 2. Reading an address from imem that is being written in dmem is undefined.
// 3. Memory writes must be aligned by their size.
// 4. Memory reads are always the entire word.
//
// Our particular implementation allow this to be synthesized as block ram.
module mem #(
    parameter integer MEMSIZE = 1024
) (
    // CPU General
    input wire i_clk,

    // Imem Read Port
    input  wire  [31:0] i_imem_addr,
    output logic [31:0] b_imem_rdata,

    // Dmem R/W Port
    input wire i_dmem_write,
    input wire i_dmem_rdu,
    input wire i_dmem_byte,
    input wire i_dmem_hwrd,
    input wire [31:0] i_dmem_addr,
    input wire [31:0] i_dmem_wdata,
    output wire [31:0] o_dmem_result
);

  // Declare memory
  logic [31:0] memory[MEMSIZE];

  // Handle imem reads
  always_ff @(posedge clk) begin
    b_imem_rdata <= memory[i_imem_addr>>2];
  end

  // Prepare byte write enable signals.
  logic [3:0] bwe;
  always_comb begin
    if (i_dmem_op_byte) begin
      bwe[i_dmem_addr[1:0]] = 1'b1;
    end else if (i_dmem_op_hwrd) begin
      bwe[{i_dmem_addr[1], 1'b0}] = 1'b1;
      bwe[{i_dmem_addr[1], 1'b1}] = 1'b1;
    end else begin
      bwe = 4'b1111;
    end
  end

  // Handle dmem read/write
  logic [31:0] dmem_rdata;
  always_ff @(posedge clk) begin
    if (i_dmem_write) begin
      if (bwe[0]) memory[i_dmem_addr>>2][7:0] <= i_dmem_wdata[7:0];
      if (bwe[1]) memory[i_dmem_addr>>2][15:8] <= i_dmem_wdata[15:8];
      if (bwe[2]) memory[i_dmem_addr>>2][23:16] <= i_dmem_wdata[23:16];
      if (bwe[3]) memory[i_dmem_addr>>2][31:24] <= i_dmem_wdata[31:24];
    end else begin
      dmem_rdata <= memory[i_dmem_addr>>2];
    end
  end

  // Shift output into the right spot for byte-wide reads.
  logic sext_bit;
  logic [15:0] dmem_shifted;
  logic [31:0] regdata;
  always_comb begin
    if (i_dmem_op_byte) begin
      // Fix input data for byte-wide reads.
      dmem_shifted = o_dmem_rdata >> i_dmem_addr[1:0];
      sext_bit = i_dmem_rdu ? 1'b0 : dmem_shifted[7];
      o_dmem_result = {{24{sext_bit}}, dmem_shifted[7:0]};
    end else if (i_dmem_op_hwrd) begin
      // Fix input data for half-word-wide reads.
      dmem_shifted = o_dmem_rdata >> {i_dmem_addr[1], 1'b0};
      sext_bit = i_dmem_rdu ? 1'b0 : dmem_shifted[15];
      o_dmem_result = {{16{sext_bit}}, dmem_shifted[15:0]};
    end else begin
      // Otherwise just output the data as it is.
      o_dmem_result = o_mem_wb_data;
    end
  end

endmodule

