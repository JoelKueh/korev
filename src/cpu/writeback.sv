
/*
 * Module 'writeback'
 *
 * Handles the mem stage of the processor.
 */
module writeback (
    /* CPU General. */
    input clk,

    /* Data from mem stage. */
    input        mem_wb_writeback,  /* Should we write to registers. */
    input [31:0] mem_wb_data,       /* The data to write. */
    input [ 5:0] mem_wb_rd,         /* The register to write to. */

    /* regfile write interface. */
    output wire [31:0] regdata,
    output wire [5:0] regno,
    output wire write

);

  /* Handle register write. */
  assign regno = mem_wb_rd;
  assign regdata = mem_wb_data;
  assign write = mem_wb_writeback;

endmodule
