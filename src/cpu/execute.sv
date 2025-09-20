
/*
 * Module 'execute'
 *
 * Handles the execution stage of the processor.
 */
module execute (
    /* CPU General. */
    input clk,

    /* Alu Operation. */
    input [4:0] dec_exec_alu_op,

    /* Forwarding paths. */
    input [5:0] dec_exec_rs1,
    input [5:0] dec_exec_rs2,
    output [5:0] exec_mem_rd,
    input [5:0] mem_wb_rd,

    /* alu_b forwarding path. */
    input [5:0] dec_exec_rs2,
    input [5:0] exec_mem_rs2,
    input [5:0] mem_wb_rs2,
    input [5:0] dec_exec_rd,

    /* Forwarding paths. */
    input [31:0] mem_exec_forward,  /* Mem-Ex forwarding path. */

    /* Alu input control signals. */
    input dec_exec_alu_pcsrc,    /* Source alu_a from the pc? */
    input dec_exec_alu_immsrc,   /* Source alu_b from the imm? */
    input dec_exec_jump_rs1src,  /* Source jump base from rs1? */
    input dec_exec_writeback,    /* Write back to registers? */

    /* Branch control signals. */
    input dec_exec_link,    /* Link pc to rd? */
    input dec_exec_jump,    /* Is jump guaranteed? */
    input dec_exec_branch,  /* Is branch possible? */
    input dec_exec_bonz,    /* Branch on zero? */

    /* Mem interface control signals. */
    input dec_exec_mem_w,     /* Write to memory? */
    input dec_exec_mem_r,     /* Read from memory? */
    input dec_exec_mem_rdu,   /* Unsigned memory read? */
    input dec_exec_mem_byte,  /* Byte op size? */
    input dec_exec_mem_hwrd,  /* Halfword op size? */
    input dec_exec_mem_wrd,   /* Word op size? */

    /* Execute alu inputs */
    input [31:0] dec_exec_rs1dat,
    input [31:0] dec_exec_rs2dat,
    input [31:0] dec_exec_pc,
    input [31:0] dec_exec_imm,

    /* Branch output. */
    output logic [31:0] exec_mem_bta,         /* Branch target address. */
    output logic [31:0] exec_mem_brnch_taken, /* Will we take the bta? */

    /* Control signals. */
    output logic exec_mem_writeback,
    output logic exec_mem_link,
    output logic exec_mem_mem_w,     /* Write to memory? */
    output logic exec_mem_mem_r,     /* Read from memory? */
    output logic exec_mem_mem_rdu,   /* Unsigned memory read? */
    output logic exec_mem_mem_byte,  /* Byte op size? */
    output logic exec_mem_mem_hwrd,  /* Halfword op size? */
    output logic exec_mem_mem_wrd,   /* Word op size? */

    /* Register numbers for forwarding. */
    output logic [5:0] exec_mem_rs1,
    output logic [5:0] exec_mem_rs2,
    output logic [5:0] exec_mem_rd,

    /* Execute alu outputs */
    output logic [31:0] exec_mem_alu_result,  /* Result of the alu. */
    output logic [31:0] exec_mem_mem_wdata    /* Data written to memory. */
);

  /* Need a full adder to compute the branch target address. */
  wire [31:0] brnch_base = dec_exec_jump_r1src ? dec_exec_pc : dec_exec_rs1dat;
  always_ff @(posedge clk) begin
    exec_mem_brnch_taken <= dec_exec_bonz ? alu_result == 0 : alu_result !== 0;
    exec_mem_bta <= brnch_base + imm;
  end

  /* Mux out inputs to alu */
  wire [31:0] alu_a = dec_exec_alu_pcsrc ? dec_exec_pc :
    dec_exec_rs1 == exec_mem_rs1 ? exec_mem_alu_result :
    dec_exec_rs1 == exec_mem_rs1 ? 
  wire [31:0] alu_b = dec_exec_alu_immsrc ? dec_exec_imm : dec_exec_rs2dat;

  /* Shared FA for add, sub, sll, sge, etc... */
  wire alu_op = dec_exec_alu_op;
  wire subtract = alu_op == ALU_SUB || alu_op == ALU_SLT;
  wire [31:0] res_fa = alu_a + (subtract ? (~alu_b + 1) : alu_b);

  /* Compute alu result. */
  wire [31:0] alu_result;
  always_comb begin
    unique case (dec_exec_alu_op)
      ALU_ADD | ALU_SUB: alu_result = res_fa;
      ALU_AND: alu_result = alu_a & alu_b;
      ALU_OR: alu_result = alu_a | alu_b;
      ALU_XOR: alu_result = alu_a ^ alu_b;
      ALU_SLL: alu_result = alu_a << (alu_b & 5'b11111);
      ALU_SRL: alu_result = alu_a >> (alu_b & 5'b11111);
      ALU_SRA: alu_result = alu_a >>> (alu_b & 5'b11111);
      ALU_SLT: alu_result = res_fa[31];  /* check for negative. */
      ALU_SLTU: alu_result = $unsigned(alu_a) < $unsigned(alu_b);
    endcase
  end

  /* Compute result and control signals. */
  always_ff @(posedge clk) begin
    /* Forward unconsumed control signals. */
    exec_mem_writeback <= dec_exec_writeback;
    exec_mem_link <= dec_exec_link;
    exec_mem_mem_w <= dec_exec_mem_w;
    exec_mem_mem_r <= dec_exec_mem_r;
    exec_mem_mem_rdu <= dec_exec_mem_rdu;
    exec_mem_mem_byte <= dec_exec_mem_byte;
    exec_mem_mem_hwrd <= dec_exec_mem_hwrd;
    exec_mem_mem_wrd <= dec_exec_mem_wrd;

    /* Pass on the alu_result and the value of rs2 (for stores). */
    exec_mem_alu_result <= alu_result;
    exec_mem_rs2dat <= dec_exec_rs2dat;
  end

endmodule
