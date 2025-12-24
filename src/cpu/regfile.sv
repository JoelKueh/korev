
// Module 'regfile'
// Implements the RISC-V 32-bit register file.
//
// This module is backed by dram.
module regfile (
    input wire i_clk,

    // Write port
    input wire [31:0] i_rd_dat,
    input wire [5:0] i_rd_no,
    input wire i_write,

    // Read ports
    input wire [ 5:0] i_rs1_no,
    input wire [ 5:0] i_rs2_no,
    output wire [31:0] b_rs1_dat,
    output wire [31:0] b_rs2_dat
);

  // Define register file
  logic [31:0] regs[31];

  // Handle register bypass for simultaneous read/write
  wire rs1_newdat;
  wire rs2_newdat;
  assign rs1_newdat = i_rd_dat == i_rs1_no ? i_rd_dat : regs[i_rs1_no];
  assign rs2_newdat = i_rd_dat == i_rs2_no ? i_rd_dat : regs[i_rs2_no];

  // Handle register reads
  always_ff @(posedge clk) begin
    if (write) begin
      b_rs1_dat <= rs1_newdat;
      b_rs2_dat <= rs2_newdat;
    end
  end

  // Handle regfile writes
  always_ff @(posedge clk) begin
    if (write) begin
      regs[regno_w] <= regdata_w;
    end
  end

endmodule

