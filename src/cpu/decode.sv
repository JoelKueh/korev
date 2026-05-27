
`include "riscv_instr.sv"
`include "defs.sv"

module decode (
    // CPU General data.
    input i_clk,

    // Data from the fetch stage.
    input [31:0] i_fetch_dec_instr,
    input [31:0] i_fetch_dec_pc,

    // Register File Interface
    output wire [ 5:0] o_rs1_no,
    output wire [ 5:0] o_rs2_no,
    input  wire [31:0] i_rs1_dat,
    input  wire [31:0] i_rs2_dat,

    // Register codes. Necessary for forwarding.
    output logic [5:0] b_dec_exec_rs1,
    output logic [5:0] b_dec_exec_rs2,
    output logic [5:0] b_dec_exec_rd,

    // Register data
    output logic [31:0] b_dec_exec_rs1_dat,
    output logic [31:0] b_dec_exec_rs2_dat,

    // Function codes.
    output logic [6:0] b_dec_exec_opcode,
    output logic [2:0] b_dec_exec_funct3,
    output logic [6:0] b_dec_exec_funct7,

    // Immediate.
    output logic [31:0] b_dec_exec_imm,

    // Alu Operation.
    output logic [4:0] b_dec_exec_alu_op,

    // Alu input control signals.
    output logic b_dec_exec_alu_pcsrc,    // Source alu_a from the pc?
    output logic b_dec_exec_alu_immsrc,   // Source alu_b from the imm?
    output logic b_dec_exec_jump_rs1src,  // Source jump base from rs1?
    output logic b_dec_exec_writeback,    // Write back to registers?

    // Branch control signals.
    output logic b_dec_exec_link,    // Link pc to rd?
    output logic b_dec_exec_jump,    // Is jump guaranteed?
    output logic b_dec_exec_branch,  // Is branch possible?
    output logic b_dec_exec_bonz,    // Branch on zero?

    // Mem interface control signals.
    output logic b_dec_exec_mem_w,    // Write to memory?
    output logic b_dec_exec_mem_r,    // Read from memory?
    output logic b_dec_exec_mem_rdu,   // Unsigned memory read?
    output logic b_dec_exec_mem_byte, // Byte op size?
    output logic b_dec_exec_mem_hwrd  // Halfword op size?
);

  // Pick apart instruction fields.
  wire [31:0] inst = i_fetch_dec_instr;
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

  // Handle reads from the register file
  assign o_rs1_no = rs1;
  assign o_rs2_no = rs2;
  always_ff @(posedge i_clk) begin
    b_dec_exec_rs1_dat <= i_rs2_dat;
    b_dec_exec_rs1_dat <= i_rs1_dat;
  end

  // Assign function / opcode.
  always_ff @(posedge i_clk) begin
    b_dec_exec_opcode <= fetch_dec_instr[6:0];
    b_dec_exec_funct7 <= fetch_dec_instr[31:25];
    b_dec_exec_funct3 <= fetch_dec_instr[14:12];
  end

  // Prepare the proper control signals for the operation.
  logic alu_op;
  logic writeback;
  logic immsrc;
  logic branch;
  logic bonz;
  logic jump;
  logic jump_rs1src;
  logic link;
  logic mem_w;
  logic mem_to_reg;
  logic mem_rdu;
  logic pc_to_reg;
  logic mem_byte;
  logic mem_hwrd;
  always_comb begin
    alu_op     = ALU_NOP;  // Perform no operation in the ALU.
    writeback  = 1'b0;  // Do not write back to registers.
    immsrc     = 1'b0;  // Source from rs2 for the ALU.
    branch     = 1'b0;  // Do not branch.
    bonz       = 1'b0;  // Branch when ALU result is zero (not when 1).
    jump       = 1'b0;  // Do not jump.
    link       = 1'b0;  // Do not link.
    mem_w      = 1'b0;  // Do not write to memory.
    mem_to_reg = 1'b0;  // Save memory result to registers.
    pc_to_reg  = 1'b0;  // Save current PC to registers.
    mem_byte   = 1'b0;  // Memory operation is not a byte operation.
    mem_hwrd   = 1'b0;  // Memory oepration is not a halfword operation.

    unique case (fetch_dec_instr)
      riscv_instr::ADD: begin
        // R-Type - rd = rs1 + rs2. Overflow ignored.
        alu_op = ALU_ADD;
        writeback = 1'b1;
      end
      riscv_instr::ADDI: begin
        // I-Type - rd = rs1 + sext(imm).
        alu_op = ALU_ADD;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::AND: begin
        // R-Type - rd = rs1 & rs2.
        alu_op = ALU_AND;
        writeback = 1'b1;
      end
      riscv_instr::ANDI: begin
        // I-Type - rd = rs1 & sext(imm).
        alu_op = ALU_AND;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::AUIPC: begin
        // U-Type - rd = pc + sext(imm).
        alu_op = ALU_ADD;
        alu_pcsrc = 1'b1;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::BEQ: begin
        // B-Type - Subtract and branch on zero.
        alu_op = ALU_SUB;
        branch = 1'b1;
        bonz   = 1'b1;
      end
      riscv_instr::BGE: begin
        // B-Type - Slt and branch on false.
        alu_op = ALU_SLT;
        branch = 1'b1;
        bonz   = 1'b1;
      end
      riscv_instr::BGEU: begin
        // B-Type - Sltu and branch on false.
        alu_op = ALU_SLTU;
        branch = 1'b1;
        bonz   = 1'b1;
      end
      riscv_instr::BLT: begin
        // B-Type - Slt and branch on true.
        alu_op = ALU_SLT;
        branch = 1'b1;
      end
      riscv_instr::BLTU: begin
        // B-Type - Sltu and branch on true.
        alu_op = ALU_SLTU;
        branch = 1'b1;
      end
      riscv_instr::BNE: begin
        // B-Type - Sub and branch on nonzero.
        alu_op = ALU_SUB;
        branch = 1'b1;
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
        alu_op = ALU_ADD;
        jump   = 1'b1;
      end
      riscv_instr::JALR: begin
        // I-Type - Jump and link to immediate offset from register.
        alu_op = ALU_ADD;
        jump_rs1src = 1'b1;  // Source base addr from rs1.
        pc_to_reg = 1'b1;  // Save current PC to rd.
        immsrc = 1'b1;
        jump = 1'b1;
      end
      riscv_instr::LB: begin
        // I-Type - Load byte by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;
        mem_to_reg = 1'b1;  // read memory.
        mem_byte   = 1'b1;  // byte size read.
      end
      riscv_instr::LBU: begin
        // I-Type - Load unsigned byte by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;
        mem_to_reg = 1'b1;  // read memory.
        mem_byte   = 1'b1;  // byte size read.
        mem_rdu    = 1'b1;  // mem read unsigned.
      end
      riscv_instr::LH: begin
        // I-Type - Load hw by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;
        mem_to_reg = 1'b1;  // read memory.
        mem_hwrd   = 1'b1;  // byte size read.
      end
      riscv_instr::LHU: begin
        // I-Type - Load unsigned hw by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;
        mem_to_reg = 1'b1;
        mem_hwrd   = 1'b1;
        mem_rdu    = 1'b1;
      end
      riscv_instr::LW: begin
        // I-Type - Load word by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;
        mem_to_reg = 1'b1;
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
        alu_op = ALU_OR;
        writeback = 1'b1;
      end
      riscv_instr::ORI: begin
        // R-Type - rd = rs1 | sext(imm).
        alu_op = ALU_OR;
        writeback = 1'b1;
        alu_immsrc = 1'b1;
      end
      riscv_instr::REM: begin
        // TODO: Not implemented.
      end
      riscv_instr::REMU: begin
        // TODO: Not implemented.
      end
      riscv_instr::SB: begin
        // S-Type - Store byte by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;  // alu source from immediate.
        mem_w      = 1'b1;  // write to memory.
        mem_byte   = 1'b1;  // mem op size is byte.
      end
      riscv_instr::SH: begin
        // S-Type - Store hwrd by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;  // alu source from immediate.
        mem_w      = 1'b1;  // write to memory.
        mem_byte   = 1'b1;  // mem op size is byte.
      end
      riscv_instr::SLL: begin
        // R-Type - rd = rs1 << (rs2 & 31)
        alu_op = ALU_SLL;
        writeback = 1'b1;
      end
      riscv_instr::SLLI: begin
        // R-Type - rd = rs1 << (sext(rs2) & 31)
        alu_op = ALU_SLL;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::SLT: begin
        // R-Type - rd = rs1 < rs2
        alu_op = ALU_SLT;
        writeback = 1'b1;
      end
      riscv_instr::SLTI: begin
        // R-Type - rd = rs1 < sext(imm)
        alu_op = ALU_SLT;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::SLTIU: begin
        // I-Type - rd = rs1 <u sext(imm)
        alu_op = ALU_SLTU;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::SLTU: begin
        // R-Type - rd = rs1 <u rs2
        alu_op = ALU_SLTU;
        writeback = 1'b1;
      end
      riscv_instr::SRA: begin
        // R-Type - rd = rs1 >>a (rs2 & 31)
        alu_op = ALU_SRA;
        writeback = 1'b1;
      end
      riscv_instr::SRAI: begin
        // R-Type - rd = rs1 >>a (sext(imm) & 31)
        alu_op = ALU_SRA;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::SRL: begin
        // R-Type - rd = rs1 >>l (rs2 & 31)
        alu_op = ALU_SRL;
        writeback = 1'b1;
      end
      riscv_instr::SRLI: begin
        // I-Type - rd = rs1 >>l (sext(imm) & 31)
        alu_op = ALU_SRL;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
      riscv_instr::SUB: begin
        // R-Type - rd = rs1 - rs2
        alu_op = ALU_SUB;
        writeback = 1'b1;
      end
      riscv_instr::SW: begin
        // S-Type - Store wrd by immediate offset from register.
        alu_op     = ALU_ADD;
        alu_immsrc = 1'b1;  // alu source from immediate.
        mem_w      = 1'b1;  // write to memory.
        mem_byte   = 1'b1;  // mem op size is byte.
      end
      riscv_instr::XOR: begin
        // R-Type - rd = rs1 ^ rs2
        alu_op = ALU_XOR;
        writeback = 1'b1;
      end
      riscv_instr::XORI: begin
        // I-Type - rd = rs1 ^ sext(imm)
        alu_op = ALU_XOR;
        alu_immsrc = 1'b1;
        writeback = 1'b1;
      end
    endcase
  end

  // Assign control signals to output buffers.
  always_ff @(posedge i_clk) begin
    b_dec_exec_alu_pcsrc <= alu_pcsrc;
    b_dec_exec_alu_immsrc <= alu_immsrc;
    b_dec_exec_jump_rs1src <= jump_rs1src;
    b_dec_exec_writeback <= writeback;

    // Branch control signals.
    b_dec_exec_link <= link;
    b_dec_exec_jump <= jump;
    b_dec_exec_branch <= branch;
    b_dec_exec_bonz <= bonz;

    // Mem interface control signals.
    b_dec_exec_mem_w <= mem_w;
    b_dec_exec_mem_r <= mem_r;
    b_dec_exec_mem_rdu <= mem_rdu;
    b_dec_exec_mem_byte <= mem_byte;
    b_dec_exec_mem_hwrd <= mem_hwrd;
  end

endmodule
