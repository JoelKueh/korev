
/*
 * Module 'cpu'
 *
 * Main module for kore-v
 */
module cpu (
    input wire clk  /* Clock signal should come from oscillator. */
);

  logic [31:0] pc;

  /* Define the regfile module. */
  wire [31:0] rfile_regdata_w;
  wire [5:0] rfile_regno_w;
  wire rfile_write;
  wire [31:0] rfile_regdata_r;
  wire [5:0] rfile_regno_r;
  regfile i_regfile (
    .clk(clk),
    .regdata_w(rfile_regdata_w),
    .regno_w(rfile_regno_w),
    .write(rfile_write),
    .regdata_r(rfile_regdata_r),
    .regno_r(rfile_regno_r)
  );

  /* Define the fetch stage. */
  

endmodule
