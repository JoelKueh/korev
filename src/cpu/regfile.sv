
/*
 * Module 'regfile'
 *
 * Implements the RISC-V 32-bit register file.
 */
module regfile (
    input wire clk,
    input wire [31:0] regdata_i,
    input wire [5:0] regno,
    input wire write,
    output wire [31:0] regdata_o
);

  logic [31:0] regs[31];

  /* Write on the falling edge of the clock. */
  always_ff @(negedge clk) begin
    if (write) begin
      regs[regno] <= regdata_i;
    end
  end

  /* Read continuously. Read valid on the rising edge of the clock. */
  assign regdata_o = regs[regno];

endmodule
