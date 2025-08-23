
/* Definitions to match opcodes. */
`define OPCODE_R 7'b0110011

/* Definitions to match opcodes. */
`define OPCODE_R 7'b0110011
`define OPCODE_B 7'b1100011
`define OPCODE_I 7'b1100111 | 7'b0000011 | 7'b0010011 \
  | 7'b0001111 | 7'b1110011
`define OPCODE_J 7'b1101111
`define OPCODE_S 7'b0100011
`define OPCODE_U 7'b0110111 | 7'b0010111

`define M_ADD

/* Definitions used for OPCODE_R. Fifth bit of funct7 is used. */
`define R_MASK funct3
`define R_F3_ADD 3'b000
`define R_F3_SUB 3'b000
`define R_F3_SLL 3'b001
`define R_F3_SLT 3'b010
`define R_F3_SLTU 3'b011
`define R_F3_XOR 3'b100
`define R_F3_OR 3'b110
`define R_F3_AND 3'b111
`define R_F3_SRX 3'b101

/* Definitions used to parse OPCODE_R. Fifth bit of funct7 is used. */
`define I_MASK {funct7, funct3}
`define OPCODE_B 7'b1100011
`define OPCODE_I 7'b1100111 | 7'b0000011 | 7'b0010011 \
  | 7'b0001111 | 7'b1110011
`define OPCODE_J 7'b1101111
`define OPCODE_S 7'b0100011
`define OPCODE_U 7'b0110111 | 7'b0010111

`define M_ADD

/* Definitions used for OPCODE_R. Fifth bit of funct7 is used. */
`define R_MASK funct3
`define R_F3_ADD 3'b000
`define R_F3_SUB 3'b000
`define R_F3_SLL 3'b001
`define R_F3_SLT 3'b010
`define R_F3_SLTU 3'b011
`define R_F3_XOR 3'b100
`define R_F3_OR 3'b110
`define R_F3_AND 3'b111
`define R_F3_SRX 3'b101

/* Definitions used to parse OPCODE_R. Fifth bit of funct7 is used. */
`define I_MASK {funct7, funct3}

/*
 * Module 'decode'
 *
 * Handles the decode stage of the processor.
 */
module decode (
    /* CPU General data. */
    input clk,
    input [31:0] regfile[32],

    /* Data from the fetch stage. */
    input [31:0] ftch_dec_instr,

    /* Registers. */
    output logic [31:0] dec_exec_rs1,
    output logic [31:0] dec_exec_rs2,
    output logic [31:0] dec_exec_rd,

    /* Function codes. */
    output logic [6:0] dec_exec_opcode,
    output logic [2:0] dec_exec_funct3,
    output logic [6:0] dec_exec_funct7,

    /* Immediate. */
    output logic [31:0] dec_exec_imm,

    /* Other signals. */
    output logic [4:0] dec_exec_alu_op
);

  /* Assign output registers. */
  always_ff @(posedge clk) begin
    dec_exec_rs1 <= regfile[19:15];
    dec_exec_rs1 <= regfile[24:20];
    dec_exec_rd  <= regfile[11:7];
  end

  /* Extract all possible immediates in parallel. */
  // No R-Type Immediate
  wire [31:0] inst = fetch_dec_instr;
  wire [31:0] imm_i = {{21{inst[31]}}, inst[31:20]};
  wire [31:0] imm_s = {{21{inst[31]}}, inst[11:5], inst[4:0]};
  wire [31:0] imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] imm_u = {inst[31:12], 12'b0};
  wire [31:0] imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

  /* Assign immediate. */
  always_ff @(posedge clk) begin
    unique case (fetch_dec_instr[6:2])
      // R-Type: All 01100(11). No Immediate
      // I-Type:
      //  - 11001(11)
      //  - 00000(11)
      //  - 00100(11)
      5'b00x00 | 5'b11001: dec_exec_imm <= imm_i;
      // S-Type:
      //  - 01000(11)
      5'b01000: dec_exec_imm <= imm_s;
      // B-Type:
      //  - 11000(11)
      5'b11000: dec_exec_imm <= imm_b;
      // U-Type:
      //  - 01101(11)
      //  - 00011(11)
      //  - 11100(11)
      5'b01101 | 5'b00011 | 5'b11100: dec_exec_imm <= imm_u;
      // J-Type:
      //  - 11011(11)
      5'b11011: dec_exec_imm <= imm_j;
    endcase
  end

  /* Assign wires for opcode / function code. */
  wire [6:0] opcode = fetch_dec_instr[6:0];
  wire [6:0] funct7 = fetch_dec_instr[31:25];
  wire [6:0] funct3 = fetch_dec_instr[14:12];

  /* Calculate the alu_op. */
  always_ff @(posedge clk) begin
    unique case (opcode)
      OPCODE_R: begin
        dec_exec_imm <= imm_r;

        unique case (R_MASK)
          R_ADD:  alu_op <= ALU_ADD;
          R_SUB:  alu_op <= ALU_SUB;
          R_AND:  alu_op <= ALU_AND;
          R_OR:   alu_op <= ALU_OR;
          R_XOR:  alu_op <= ALU_XOR;
          R_SLL:  alu_op <= ALU_SLL;
          R_SRL:  alu_op <= ALU_SRL;
          R_SRA:  alu_op <= ALU_SRA;
          R_SLT:  alu_op <= ALU_SLT;
          R_SLTU: alu_op <= ALU_SLTU;
        endcase
      end
      OPCODE_I: begin
        dec_exec_imm <= imm_i;
      end
      OPCODE_S: begin
        dec_exec_imm <= imm_s;
      end
      OPCODE_B: begin
        dec_exec_imm <= imm_b;
      end
      OPCODE_U: begin
        dec_exec_imm <= imm_u;
      end
      OPCODE_J: begin
        dec_exec_imm <= imm_j;
      end
    endcase
  end

  /* Assign function / opcode. */
  always_ff @(posedge clk) begin
    dec_exec_opcode <= fetch_dec_instr[6:0];
    dec_exec_funct7 <= fetch_dec_instr[31:25];
    dec_exec_funct3 <= fetch_dec_instr[14:12];
  end
endmodule
