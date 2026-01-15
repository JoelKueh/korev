
// Module 'execute'
// Handles the execution stage of the processor.
module execute (
    // CPU General.
    input i_clk,

    // Alu Operation.
    input [4:0] i_dec_exec_alu_op,

    // Register numbers for forwarding.
    input [5:0] i_dec_exec_rs1,
    input [5:0] i_dec_exec_rs2,
    input [5:0] i_dec_exec_rd,
    input [5:0] i_exec_mem_rd,
    input [5:0] i_mem_wb_rd,
    output logic [5:0] b_exec_mem_rs1,
    output logic [5:0] b_exec_mem_rs2,
    output logic [5:0] b_exec_mem_rd,

    // Pipeline data for forwarding.
    input [31:0] i_mem_exec_forward,  // Mem-Ex forwarding path.
    input [31:0] i_exec_exec_forward, // Ex-Ex forwarding path.

    // Alu input control signals.
    input i_dec_exec_alu_pcsrc,    // Source alu_a from the pc?
    input i_dec_exec_alu_immsrc,   // Source alu_b from the imm?
    input i_dec_exec_jump_rs1src,  // Source jump base from rs1?
    input i_dec_exec_writeback,    // Write back to registers?

    // Branch control signals.
    input i_dec_exec_link,    // Link pc to rd?
    input i_dec_exec_jump,    // Is jump guaranteed?
    input i_dec_exec_branch,  // Is branch possible?
    input i_dec_exec_bonz,    // Branch on zero?

    // Mem interface control signals.
    input i_dec_exec_mem_w,     // Write to memory?
    input i_dec_exec_mem_r,     // Read from memory?
    input i_dec_exec_mem_rdu,   // Unsigned memory read?
    input i_dec_exec_mem_byte,  // Byte op size?
    input i_dec_exec_mem_hwrd,  // Halfword op size?

    // Execute alu inputs.
    input [31:0] i_dec_exec_rs1_dat,
    input [31:0] i_dec_exec_rs2_dat,
    input [31:0] i_dec_exec_pc,
    input [31:0] i_dec_exec_imm,

    // Branch output.
    output logic [31:0] b_exec_mem_bta,          // Branch target address.
    output logic        b_exec_mem_branch_taken, // Will we take the branch?

    // Control signals.
    output logic b_exec_mem_writeback,
    output logic b_exec_mem_link,
    output logic b_exec_mem_mem_w,     // Write to memory?
    output logic b_exec_mem_mem_r,     // Read from memory?
    output logic b_exec_mem_mem_rdu,   // Unsigned memory read?
    output logic b_exec_mem_mem_byte,  // Byte op size?
    output logic b_exec_mem_mem_hwrd,  // Halfword op size?

    // Execute alu outputs.
    output logic [31:0] b_exec_mem_alu_result,  // Result of the alu.
    output logic [31:0] b_exec_mem_mem_wdata    // Data written to memory.
);

  // Need a full adder to compute the branch target address.
  wire [31:0] branch_base = i_dec_exec_jump_r1src ? i_dec_exec_pc : i_dec_exec_rs1_dat;
  logic [31:0] bta;
  logic branch_taken;
  always_comb begin
    bta = branch_base + i_dec_exec_imm << 1;
    branch_taken = (alu_resut == 32'b0) ^ i_dec_exec_bonz;
  end

  // Mux out inputs to alu.
  wire [31:0] alu_a = i_dec_exec_alu_pcsrc ? i_dec_exec_pc :
    i_dec_exec_rs1 == i_exec_mem_rd ? i_exec_exec_forward :
    i_dec_exec_rs1 == i_mem_wb_rd ? i_mem_exec_forward : i_dec_exec_rs1_dat;
  wire [31:0] alu_b = i_dec_exec_alu_immsrc ? i_dec_exec_pc :
    i_dec_exec_rs2 == i_exec_mem_rd ? i_exec_exec_forward :
    i_dec_exec_rs2 == i_mem_wb_rd ? i_mem_exec_forward : i_dec_exec_rs2_dat;

  // Shared FA for add, sub, sll, sge, etc...
  wire alu_op = i_dec_exec_alu_op;
  wire subtract = alu_op == ALU_SUB || alu_op == ALU_SLT;
  wire [31:0] res_fa = alu_a + (subtract ? (~alu_b + 1) : alu_b);

  // Compute alu result.
  logic [31:0] alu_result;
  always_comb begin
    unique case (dec_exec_alu_op)
      ALU_ADD | ALU_SUB: alu_result = res_fa;
      ALU_AND: alu_result = alu_a & alu_b;
      ALU_OR: alu_result = alu_a | alu_b;
      ALU_XOR: alu_result = alu_a ^ alu_b;
      ALU_SLL: alu_result = alu_a << (alu_b & 5'b11111);
      ALU_SRL: alu_result = alu_a >> (alu_b & 5'b11111);
      ALU_SRA: alu_result = alu_a >>> (alu_b & 5'b11111);
      ALU_SLT: alu_result = res_fa[31];  // check for negative.
      ALU_SLTU: alu_result = $unsigned(alu_a) < $unsigned(alu_b);
    endcase
  end

  // Assign result and control signals.
  always_ff @(posedge i_clk) begin
    // Register numbers for forwarding.
    b_exec_mem_rs1 <= i_dec_exec_rs1;
    b_exec_mem_rs2 <= i_dec_exec_rs2;
    b_exec_mem_rd <= i_dec_exec_rd;

    // Assign branch output.
    b_exec_mem_bta <= bta;
    b_exec_mem_branch_taken <= branch_taken;

    // Forward unconsumed control signals.
    b_exec_mem_writeback <= i_dec_exec_writeback;
    b_exec_mem_link <= i_dec_exec_link;
    b_exec_mem_mem_w <= i_dec_exec_mem_w;
    b_exec_mem_mem_r <= i_dec_exec_mem_r;
    b_exec_mem_mem_rdu <= i_dec_exec_mem_rdu;
    b_exec_mem_mem_byte <= i_dec_exec_mem_byte;
    b_exec_mem_mem_hwrd <= i_dec_exec_mem_hwrd;

    // Pass on the alu_result and the value of rs2 (for stores).
    b_exec_mem_alu_result <= alu_result;
    b_exec_mem_mem_wdata <= i_dec_exec_rs2_dat;
  end

endmodule
