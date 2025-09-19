
`include "./src/cpu/parameter.svh"

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
    input wire dmem_hwrd,  /* Halfword op size. */
    input wire dmem_wrd,  /* Word op size. */
    output logic dmem_drdy,
    output logic [31:0] dmem_rdata,

    /* Instruction memory interface (no writes). */
    input wire [31:0] imem_addr,
    output logic imem_drdy,
    output logic [31:0] imem_rdata
);

  /* Define l1 cache blocks. */
  reg [7:0] icache_l1[`CACHE_SIZE_L1];
  reg [7:0] dcache_l1[`CACHE_SIZE_L1];

  /* Define main memory. */
  reg [7:0] memory[`MEM_SIZE];

//`ifdef MMU_SIMPLE
  /* Handle data memory writes. These must be synchronous on the clock. */
  always_ff @(posedge clk) begin
    /* Handle byte write. */
    if (dmem_write) begin
      dcache_l1[dmem_addr] <= dmem_wdata[7:0];
    end

    /* Handle halfword write. */
    if (dmem_write && (dmem_hwrd || dmem_wrd)) begin
      dcache_l1[dmem_addr+1] <= dmem_wdata[15:8];
    end

    /* Handle word write. */
    if (dmem_write && dmem_wrd) begin
      dcache_l1[dmem_addr+2] <= dmem_wdata[23:16];
      dcache_l1[dmem_addr+3] <= dmem_wdata[31:24];
    end
  end

  /* Handle data memory reads. */
  wire [31:0] dmem_rd_byte = {
    {24{dmem_rdu ? 1'b0 : dcache_l1[dmem_addr][7]}},
    {dcache_l1[dmem_addr]}
  };

  wire [31:0] dmem_rd_hwrd = {
    {16{dmem_rdu ? 1'b0 : dcache_l1[dmem_addr + 1][7]}},
    {dcache_l1[dmem_addr + 1]},
    {dcache_l1[dmem_addr]}
  };

  wire [31:0] dmem_rd_wrd = {
    {dcache_l1[dmem_addr + 3]},
    {dcache_l1[dmem_addr + 2]},
    {dcache_l1[dmem_addr + 1]},
    {dcache_l1[dmem_addr]}
  };

  /* Mux between the reads. */
  assign dmem_rdata = dmem_rd_wrd;
  assign dmem_drdy = 1'b1;  /* Read is single cycle (drdy always true). */

  /* Handle imem reads. */
  assign imem_rdata = {
    {icache_l1[(imem_addr << 2) + 3]},
    {icache_l1[(imem_addr << 2) + 2]},
    {icache_l1[(imem_addr << 2) + 1]},
    {icache_l1[(imem_addr << 2)]}
  };
  assign imem_drdy = 1'b1;
//`else
//  /* TODO: Create the complex multi-level cache system. */
//`endif

endmodule
