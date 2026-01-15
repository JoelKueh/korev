
// Module 'cpu'
// Main module for the RISCV softcore.
module cpu (
    input wire i_clk
);

  logic [31:0] pc;
  wire  [31:0] newpc;

  // Assign the new pc.
  always @(posedge clk) begin
    pc <= newpc;
  end

  //
  // Pipeline
  //

  // FORWARDING PATHS
  wire [ 5:0] dec_exec_rd;
  wire [ 5:0] exec_mem_rd;
  wire [ 5:0] mem_wb_rd;
  wire [31:0] exec_exec_forward;
  wire [31:0] mem_exec_forward;

  // FETCH STAGE
  wire [31:0] fetch_imem_addr;
  wire [31:0] fetch_imem_rdata;
  wire [31:0] fetch_dec_instr;
  fetch inst_fetch (
      .i_clk(i_clk),
      .i_pc(pc),
      .i_imem_addr(fetch_imem_addr),
      .i_imem_rdata(fetch_imem_rdata),
      .b_fetch_dec_instr(fetch_dec_instr),
      .o_newpc(newpc)
  );

  // DECODE STAGE
  wire [5:0] dec_rs1_no;
  wire [5:0] dec_rs2_no;
  wire [5:0] dec_rs1_dat;
  wire [5:0] dec_rs1_dat;

  wire [5:0] dec_exec_rs1;
  wire [5:0] dec_exec_rs2;

  wire [31:0] dec_exec_rs1_dat;
  wire [31:0] dec_exec_rs2_dat;

  wire [6:0] dec_exec_opcode;
  wire [2:0] dec_exec_funct3;
  wire [6:0] dec_exec_funct7;

  wire [31:0] dec_exec_imm;
  wire [4:0] dec_exec_alu_op;

  wire dec_exec_alu_pcsrc;
  wire dec_exec_alu_immsrc;
  wire dec_exec_jump_rs1src;
  wire dec_exec_writeback;

  wire dec_exec_link;
  wire dec_exec_jump;
  wire dec_exec_branch;
  wire dec_exec_bonz;
  decode inst_decode (
      .i_clk(i_clk),

      .i_fetch_dec_isntr(fetch_dec_instr),
      .i_fetch_dec_pc(fetch_dec_pc),

      .o_rs1_no (dec_rs1_no),
      .o_rs2_no (dec_rs2_no),
      .o_rs1_dat(dec_rs1_dat),
      .o_rs2_dat(dec_rs2_dat),

      .b_dec_exec_rs1(dec_exec_rs1),
      .b_dec_exec_rs2(dec_exec_rs2),
      .b_dec_exec_rd (dec_exec_rd),

      .b_dec_exec_rs1_dat(dec_exec_rs1_dat),
      .b_dec_exec_rs2_dat(dec_exec_rs2_dat),

      .b_dec_exec_opcode(dec_exec_opcode),
      .b_dec_exec_funct3(dec_exec_funct3),
      .b_dec_exec_funct7(dec_exec_funct7),

      .b_dec_exec_imm(dec_exec_imm),
      .b_dec_exec_alu_op(dec_exec_alu_op),

      .b_dec_exec_alu_pcsrc  (dec_exec_alu_pcsrc),
      .b_dec_exec_alu_immsrc (dec_exec_alu_immsrc),
      .b_dec_exec_jump_rs1src(dec_exec_jump_rs1src),
      .b_dec_exec_writeback  (dec_exec_writeback),

      .b_dec_exec_link  (dec_exec_link),
      .b_dec_exec_jump  (dec_exec_jump),
      .b_dec_exec_branch(dec_exec_branch),
      .b_dec_exec_bonz  (dec_exec_bonz),

      .b_dec_exec_mem_w(dec_exec_mem_w),
      .b_dec_exec_mem_r(dec_exec_mem_r),
      .b_dec_exec_mem_rdu(dec_exec_mem_rdu),
      .b_dec_exec_mem_byte(dec_exec_mem_byte),
      .b_dec_exec_mem_hwrd(dec_exec_mem_hwrd)
  );

  // EXECUTE STAGE
  wire [5:0] exec_mem_rs1;
  wire [5:0] exec_mem_rs2;
  wire [5:0] exec_mem_rd;

  wire [31:0] exec_mem_bta;
  wire exec_mem_branch_taken;

  wire exec_mem_writeback;
  wire exec_mem_link;
  wire exec_mem_mem_w;
  wire exec_mem_mem_r;
  wire exec_mem_mem_rdu;
  wire exec_mem_mem_hwrd;

  wire [31:0] exec_mem_alu_result;
  wire [31:0] exec_mem_mem_wdata;
  execute inst_execute (
      .i_clk(i_clk),

      .i_dec_exec_alu_op(dec_exec_alu_op),

      .i_dec_exec_rs1(dec_exec_rs1),
      .i_dec_exec_rs2(dec_exec_rs2),
      .i_dec_exec_rd(dec_exec_rd),
      .i_exec_mem_rd(exec_mem_rd),
      .i_mem_wb_rd(exec_mem_rd),
      .b_exec_mem_rs1(exec_mem_rs1),
      .b_exec_mem_rs2(exec_mem_rs2),
      .b_exec_mem_rd(exec_mem_rd),

      .i_mem_exec_forward (mem_exec_forward),
      .i_exec_exec_forward(exec_exec_forward),

      .i_dec_exec_alu_pcsrc  (dec_exec_alu_pcsrc),
      .i_dec_exec_alu_immsrc (dec_exec_alu_immsrc),
      .i_dec_exec_jump_rs1src(dec_exec_jump_rs1src),
      .i_dec_exec_writeback  (dec_exec_writeback),

      .i_dec_exec_link  (dec_exec_link),
      .i_dec_exec_jump  (dec_exec_jump),
      .i_dec_exec_branch(dec_exec_branch),
      .i_dec_exec_bonz  (dec_exec_bonz),

      .i_dec_exec_mem_w(dec_exec_mem_w),
      .i_dec_exec_mem_r(dec_exec_mem_r),
      .i_dec_exec_mem_rdu(dec_exec_mem_rdu),
      .i_dec_exec_mem_byte(dec_exec_mem_byte),
      .i_dec_exec_mem_hwrd(dec_exec_mem_hwrd),

      .i_dec_exec_rs1_dat(dec_exec_rs1_dat),
      .i_dec_exec_rs2_dat(dec_exec_rs2_dat),
      .i_dec_exec_pc(dec_exec_pc),
      .i_dec_exec_imm(dec_exec_imm),

      .b_exec_mem_bta(exec_mem_bta),
      .b_exec_mem_branch_taken(exec_mem_branch_taken),

      .b_exec_mem_writeback(exec_mem_writeback),
      .b_exec_mem_link(exec_mem_link),
      .b_exec_mem_mem_w(exec_mem_mem_w),
      .b_exec_mem_mem_r(exec_mem_mem_r),
      .b_exec_mem_mem_rdu(exec_mem_mem_rdu),
      .b_exec_mem_mem_byte(exec_mem_mem_byte),
      .b_exec_mem_mem_hwrd(exec_mem_mem_hwrd),

      .b_exec_mem_alu_result(exec_mem_alu_result),
      .b_exec_mem_mem_wdata (exec_mem_mem_wdata)
  );

  // MEMORY
  memory inst_memory (
      .i_clk(i_clk),

      .i_exec_mem_rs1(exec_mem_rs1),
      .i_exec_mem_rs2(exec_mem_rs2),
      .i_exec_mem_rd(exec_mem_rd),
  );

endmodule
