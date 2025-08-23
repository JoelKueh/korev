
`include "parameter.svh"

/*
 * Module 'mmu'
 *
 * Implements the memory management unit of the processor.
 * Separate caches for instruciton and data memory.
 */
module mmu (
    input clk,

    /* Data memory interface. */
    input wire [31:0] dmem_addr,
    input wire [31:0] dmem_wdata,
    input wire dmem_write,
    input wire dmem_read,
    input wire dmem_rdu,  /* Unsigned memory read. */
    input wire dmem_byte,  /* Byte op size. */
    input wire dmem_hwrd,  /* Halfword op size. */
    input wire dmem_wrd,  /* Word op size. */
    output wire dmem_drdy,
    output wire [31:0] dmem_rdata,

    /* Instruction memory interface (no writes). */
    input wire [31:0] imem_addr,
    input wire [31:0] imem_wdata,
    input wire imem_read,
    output wire imem_drdy,
    output wire [31:0] imem_rdata
);

  /* Define l1 cache blocks. */
  reg [31:0] icache_l1[CACHE_SIZE_L1];
  reg [31:0] dcache_l1[CACHE_SIZE_L1];

  /* Define main memory. */
  reg [31:0] memory[MEM_SIZE];

`ifdef MMU_SIMPLE
  /* No need to access main memory, just return the raw cache value. */

  /* Handle data memory writes. These must by synchronous. */
  always_ff @(posedge clk) begin
    if (dmem_write) dcache_l1[dmem_addr] <= dmem_wdata;
  end

  /* Handle reads. dmem_rdata may be junk if writing. */
  always dmem_rdata = dcache_l1[dmem_addr];
  always dmem_drdy = 1'b1;  /* Read is single cycle (drdy always true). */

  always imem_rdata = icache_l1[imem_addr];
  always imem_drdy = 1'b1;
`else
  /* TODO: Create the complex multi-level cache system. */
`endif

endmodule
