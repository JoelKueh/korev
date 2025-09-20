
/*
 * Module 'regfile'
 *
 * Implements the RISC-V 32-bit register file.
 */
module regfile (
    input wire clk,

    /* Write port. */
    input wire [31:0] regdata_w,
    input wire [5:0] regno_w,
    input wire write,

    /* Read port. */
    input wire [31:0] regdata_r,
    input wire [5:0] regno_r
);

  logic [31:0] regs[31];

  /* Read. If the regno_w and regno_r are the same, bypass the regfile. */
  assign regdata_r = regno_w == regno_r ?
    regdata_w : regs[regno_r];

  /* Write on the positive edge of the clock. */
  always_ff @(posedge clk) begin
    if (write) begin
      regs[regno_w] <= regdata_w;
    end
  end

endmodule
