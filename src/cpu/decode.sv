
`include "riscv_instr.sv"
`include "defs.sv"

module decode (
    // CPU General data.
    input clk,
    input [31:0] regfile[32],

    // Data from the fetch stage.
    input [31:0] ftch_dec_instr,
    input [31:0] ftch_dec_pc,

    // Register codes. Necessary for forwarding.
    output logic [5:0] dec_exec_rs1,
    output logic [5:0] dec_exec_rs2,
    output logic [5:0] dec_exec_rd,

    // Register data.
    output logic [31:0] dec_exec_rs1dat,
    output logic [31:0] dec_exec_rs2dat,

    // Function codes.
    output logic [6:0] dec_exec_opcode,
    output logic [2:0] dec_exec_funct3,
    output logic [6:0] dec_exec_funct7,

    // Immediate.
    output logic [31:0] dec_exec_imm,

    // Alu Operation.
    output logic [4:0] dec_exec_alu_op,

    // Alu input control signals.
    output logic dec_exec_alu_pcsrc,    // Source alu_a from the pc?
    output logic dec_exec_alu_immsrc,   // Source alu_b from the imm?
    output logic dec_exec_jump_rs1src,  // Source jump base from rs1?
    output logic dec_exec_writeback,    // Write back to registers?

    // Branch control signals.
    output logic dec_exec_link,    // Link pc to rd?
    output logic dec_exec_jump,    // Is jump guaranteed?
    output logic dec_exec_branch,  // Is branch possible?
    output logic dec_exec_bonz,    // Branch on zero?

    // Mem interface control signals.
    output logic dec_exec_mem_w,    // Write to memory?
    output logic dec_exec_mem_r,    // Read from memory?
    output logic dec_exec_mem_ru,   // Unsigned memory read?
    output logic dec_exec_mem_byte, // Byte op size?
    output logic dec_exec_mem_hwrd, // Halfword op size?
    output logic dec_exec_mem_wrd   // Word op size?
);

  // Pick apart instruction fields.
  wire [31:0] inst = fetch_dec_instr;
  wire [ 6:0] opcode = inst[6:0];
  wire [ 6:0] funct7 = inst[31:25];
  wire [ 3:0] funct3 = inst[11:7];
  wire [ 5:0] rs1 = inst[19:15];
  wire [ 5:0] rs2 = inst[24:20];
  wire [ 5:0] rd = inst[11:7];

  // Extract all possible immediates in parallel.
  wire [31:0] imm_i = {{21{inst[31]}}, inst[31:20]};
  wire [31:0] imm_s = {{21{inst[31]}}, inst[11:5], inst[4:0]};
  wire [31:0] imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] imm_u = {inst[31:12], 12'b0};
  wire [31:0] imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

  // Assign output registers.
  always_ff @(posedge clk) begin
    dec_exec_rs1 <= regfile[19:15];
    dec_exec_rs2 <= regfile[24:20];
    dec_exec_rd  <= regfile[11:7];
  end

  // Assign function / opcode.
  always_ff @(posedge clk) begin
    dec_exec_opcode <= fetch_dec_instr[6:0];
    dec_exec_funct7 <= fetch_dec_instr[31:25];
    dec_exec_funct3 <= fetch_dec_instr[14:12];
  end

  // Assign the immediate and register data right away.
  // With only the opcode, we can determine the alu op.

  // Prepare the proper control signals for the operation.
  always_ff @(posedge clk) begin
    dec_exec_alu_op    <= ALU_NOP;  // Perform no operation in the ALU.
    dec_exec_writeback <= 1'b0;     // Do not write back to registers.
    dec_exec_immsrc    <= 1'b0;     // Source from rs2 for the ALU.
    dec_exec_branch    <= 1'b0;     // Do not branch.
    dec_ecec_mem_w     <= 1'b0;     // Do not write to memory.
    dec_ecec_mem_r     <= 1'b0;     // Do not read from memory.

    unique case (fetch_dec_instr)
      riscv_instr::ADD: begin
        // R-Type - rd = rs1 + rs2. Overflow ignored.
        dec_exec_alu_op <= ALU_ADD;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::ADDI: begin
        // I-Type - rd = rs1 + sext(imm).
        dec_exec_alu_op <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::AND: begin
        // R-Type - rd = rs1 & rs2.
        dec_exec_alu_op <= ALU_AND;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::ANDI: begin
        // I-Type - rd = rs1 & sext(imm).
        dec_exec_alu_op <= ALU_AND;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::AUIPC: begin
        // U-Type - rd = pc + sext(imm).
        dec_exec_alu_op <= ALU_ADD;
        dec_exec_alu_pcsrc <= 1'b1;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::BEQ: begin
        // B-Type - Subtract and branch on zero.
        dec_exec_alu_op <= ALU_SUB;
        dec_exec_branch <= 1'b1;
        dec_exec_bonz   <= 1'b1;
      end
      riscv_instr::BGE: begin
        // B-Type - Slt and branch on false.
        dec_exec_alu_op <= ALU_SLT;
        dec_exec_branch <= 1'b1;
        dec_exec_bonz   <= 1'b1;
      end
      riscv_instr::BGEU: begin
        // B-Type - Sltu and branch on false.
        dec_exec_alu_op <= ALU_SLTU;
        dec_exec_branch <= 1'b1;
        dec_exec_bonz   <= 1'b1;
      end
      riscv_instr::BLT: begin
        // B-Type - Slt and branch on true.
        dec_exec_alu_op <= ALU_SLT;
        dec_exec_branch <= 1'b1;
      end
      riscv_instr::BLTU: begin
        // B-Type - Sltu and branch on true.
        dec_exec_alu_op <= ALU_SLTU;
        dec_exec_branch <= 1'b1;
      end
      riscv_instr::BNE: begin
        // B-Type - Sub and branch on nonzero.
        dec_exec_alu_op <= ALU_SUB;
        dec_exec_branch <= 1'b1;
      end
      riscv_instr::DIV: begin
        /* TODO: Not implemented */
      end
      riscv_instr::DIVU: begin
        /* TODO: Not implemented */
      end
      riscv_instr::EBREAK: begin
        /* TODO: Implemented as NOP */
      end
      riscv_instr::ECALL: begin
        /* TODO: Implemented as NOP */
      end
      riscv_instr::FENCE: begin
        /* TODO: Implemented as NOP */
      end
      riscv_instr::JAL: begin
        // J-Type - Jump and link to immediate offset from pc.
        dec_exec_alu_op <= ALU_ADD;
        dec_exec_jump   <= 1'b1;
      end
      riscv_instr::JALR: begin
        // I-Type - Jump and link to immediate offset from register.
        dec_exec_alu_op <= ALU_ADD;
        dec_exec_jump_rs1src <= 1'b1;  // Source base addr from rs1.
        dec_exec_immsrc <= 1'b1;
        dec_exec_jump <= 1'b1;
      end
      riscv_instr::LB: begin
        // I-Type - Load byte by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;
        dec_ecec_mem_r      <= 1'b1;  // read memory.
        dec_ecec_mem_byte   <= 1'b1;  // byte size read.
      end
      riscv_instr::LBU: begin
        // I-Type - Load unsigned byte by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;
        dec_ecec_mem_r      <= 1'b1;  // read memory.
        dec_ecec_mem_byte   <= 1'b1;  // byte size read.
        dec_exec_mem_ru     <= 1'b1;  // mem read unsigned.
      end
      riscv_instr::LH: begin
        // I-Type - Load hw by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;
        dec_ecec_mem_r      <= 1'b1;  // read memory.
        dec_exec_mem_hwrd   <= 1'b1;  // byte size read.
      end
      riscv_instr::LHU: begin
        // I-Type - Load unsigned hw by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;
        dec_ecec_mem_r      <= 1'b1;
        dec_exec_mem_hwrd   <= 1'b1;
        dec_exec_mem_ru     <= 1'b1;
      end
      riscv_instr::LW: begin
        // I-Type - Load word by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;
        dec_ecec_mem_r      <= 1'b1;
        dec_exec_mem_wrd    <= 1'b1;
      end
      riscv_instr::MUL: begin
        // TODO: Not implemented.
      end
      riscv_instr::MULH: begin
        // TODO: Not implemented.
      end
      riscv_instr::MULHSU: begin
        // TODO: Not implemented.
      end
      riscv_instr::MULHU: begin
        // TODO: Not implemented.
      end
      riscv_instr::OR: begin
        // R-Type - rd = rs1 | rs2.
        dec_exec_alu_op <= ALU_OR;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::ORI: begin
        // R-Type - rd = rs1 | sext(imm).
        dec_exec_alu_op <= ALU_OR;
        dec_exec_writeback <= 1'b1;
        dec_exec_alu_immsrc <= 1'b1;
      end
      riscv_instr::REM: begin
        // TODO: Not implemented.
      end
      riscv_instr::REMU: begin
        // TODO: Not implemented.
      end
      riscv_instr::SB: begin
        // S-Type - Store byte by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;  // alu source from immediate.
        dec_ecec_mem_w      <= 1'b1;  // write to memory.
        dec_exec_mem_byte   <= 1'b1;  // mem op size is byte.
      end
      riscv_instr::SH: begin
        // S-Type - Store hwrd by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;  // alu source from immediate.
        dec_ecec_mem_w      <= 1'b1;  // write to memory.
        dec_exec_mem_byte   <= 1'b1;  // mem op size is byte.
      end
      riscv_instr::SLL: begin
        // R-Type - rd = rs1 << (rs2 & 31)
        dec_exec_alu_op <= ALU_SLL;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SLLI: begin
        // R-Type - rd = rs1 << (sext(rs2) & 31)
        dec_exec_alu_op <= ALU_SLL;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SLT: begin
        // R-Type - rd = rs1 < rs2
        dec_exec_alu_op <= ALU_SLT;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SLTI: begin
        // R-Type - rd = rs1 < sext(imm)
        dec_exec_alu_op <= ALU_SLT;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SLTIU: begin
        // I-Type - rd = rs1 <u sext(imm)
        dec_exec_alu_op <= ALU_SLTU;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SLTU: begin
        // R-Type - rd = rs1 <u rs2
        dec_exec_alu_op <= ALU_SLTU;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SRA: begin
        // R-Type - rd = rs1 >>a (rs2 & 31)
        dec_exec_alu_op <= ALU_SRA;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SRAI: begin
        // R-Type - rd = rs1 >>a (sext(imm) & 31)
        dec_exec_alu_op <= ALU_SRA;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SRL: begin
        // R-Type - rd = rs1 >>l (rs2 & 31)
        dec_exec_alu_op <= ALU_SRL;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SRLI: begin
        // I-Type - rd = rs1 >>l (sext(imm) & 31)
        dec_exec_alu_op <= ALU_SRL;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SUB: begin
        // R-Type - rd = rs1 - rs2
        dec_exec_alu_op <= ALU_SUB;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::SW: begin
        // S-Type - Store wrd by immediate offset from register.
        dec_exec_alu_op     <= ALU_ADD;
        dec_exec_alu_immsrc <= 1'b1;  // alu source from immediate.
        dec_ecec_mem_w      <= 1'b1;  // write to memory.
        dec_exec_mem_byte   <= 1'b1;  // mem op size is byte.
      end
      riscv_instr::XOR: begin
        // R-Type - rd = rs1 ^ rs2
        dec_exec_alu_op <= ALU_XOR;
        dec_exec_writeback <= 1'b1;
      end
      riscv_instr::XORI: begin
        // I-Type - rd = rs1 ^ sext(imm)
        dec_exec_alu_op <= ALU_XOR;
        dec_exec_alu_immsrc <= 1'b1;
        dec_exec_writeback <= 1'b1;
      end
    endcase
  end

endmodule
