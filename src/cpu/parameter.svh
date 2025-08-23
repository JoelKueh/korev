
/* Parameters for the MMU ***************************************************/

`define MMU_SIMPLE

`define MEM_SIZE (2 << 16)

`ifdef MMU_SIMPLE

/* Use simple cache (single cache line for debugging) */
`define CACHE_LINE_SIZE_L1 8196
`define CACHE_NUM_LINES_L1 1
`define CACHE_SIZE_L1 CACHE_LINE_SIZE_L1 * CACHE_NUM_LINES_L1

`else

/* Use complex cache (multiple cache lines) */
`define CACHE_LINE_SIZE_L1 64
`define CACHE_NUM_LINES_L1 128
`define CACHE_SIZE_L1 CACHE_LINE_SIZE_L1 * CACHE_NUM_LINES_L1

`endif

/* Parameters for the CPU ***************************************************/
