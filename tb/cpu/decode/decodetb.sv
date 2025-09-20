`timescale 1ns / 100ps;

/*
 * Module 'decodetb'
 *
 * Testbench for the fetch stage of the CPU.
 */
module decodetb ();
  logic clk = 0;
  logic [31:0] pc = 31'b0;

  logic [31:0] fetch_dec_instr;
  logic [31:0] fetch_dec_pc;
  logic [31:0] dec_exec_pc;

  wire [5:0] dec_exec_rs1;
  wire [5:0] dec_exec_rs2;
  wire [5:0] dec_exec_rd;

  wire [31:0] dec_exec_rs1dat;
  wire [31:0] dec_exec_rs2dat;

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

  wire dec_exec_mem_w;
  wire dec_exec_mem_r;
  wire dec_exec_mem_ru;
  wire dec_exec_mem_byte;
  wire dec_exec_mem_hwrd;
  wire dec_exec_mem_wrd;
  decode i_decode (
      /* CPU General data. */
      .clk(clk),
      .pc (pc),

      /* Fetch stage data. */
      .ftch_dec_instr(fetch_dec_instr),
      .ftch_dec_pc(fetch_dec_pc),

      /* Register codes for forwarding. */
      .dec_exec_rs1(dec_exec_rs1),
      .dec_exec_rs2(dec_exec_rs2),
      .dec_exec_rd (dec_exec_rd),
      .dec_exec_pc (dec_exec_pc),

      /* Register data. */
      .dec_exec_rs1dat(dec_exec_rs1dat),
      .dec_exec_rs2dat(dec_exec_rs2dat),

      /* Function codes. */
      .dec_exec_opcode(dec_exec_opcode),
      .dec_exec_funct3(dec_exec_funct3),
      .dec_exec_funct7(dec_exec_funct7),

      /* Immedaite. */
      .dec_exec_imm(dec_exec_imm),

      /* ALU Operation. */
      .dec_exec_alu_op(dec_exec_alu_op),

      /* ALU input control signals. */
      .dec_exec_alu_pcsrc  (dec_exec_alu_pcsrc),
      .dec_exec_alu_immsrc (dec_exec_alu_immsrc),
      .dec_exec_jump_rs1src(dec_exec_jump_rs1src),
      .dec_exec_writeback  (dec_exec_writeback),

      /* Branch control signals. */
      .dec_exec_link  (dec_exec_link),
      .dec_exec_jump  (dec_exec_jump),
      .dec_exec_branch(dec_exec_branch),
      .dec_exec_bonz  (dec_exec_bonz),

      /* Memory interface control signals. */
      .dec_exec_mem_w(dec_exec_mem_w),
      .dec_exec_mem_r(dec_exec_mem_r),
      .dec_exec_mem_ru(dec_exec_mem_ru),
      .dec_exec_mem_bypte(dec_exec_mem_byte),
      .dec_exec_mem_hwrd(dec_exec_mem_hwrd),
      .dec_exec_mem_wrd(dec_exec_mem_wrd)
  );

  /* Update the pc from the newpc. */
  always_ff @(posedge clk) begin
    pc <= newpc;
  end

  /* File IO simulation variables. */
  reg [639:0] errmsg;
  string imem_fname;
  string res_fname;
  string dump_fname;
  int fimem;
  int fres;

  /* Simulation variables. */
  logic [31:0] imem_data;
  logic [31:0] res_data;
  int i = 0;

  /* Load the resuource files for the fetch test. */
  initial begin
    /* Check if the proper args were supplied. */
    if (!$value$plusargs("IMEM_FILE=%s", imem_fname)) begin
      $display("ERROR: IMEM_FILE must be specified in plusargs.");
      $finish;
    end

    if (!$value$plusargs("RES_FILE=%s", res_fname)) begin
      $display("ERROR: RES_FILE must be specified in plusargs.");
      $finish;
    end

    if (!$value$plusargs("DUMP_FILE=%s", dump_fname)) begin
      $display("ERROR: DUMP_FILE must be specified in plusargs.");
      $finish;
    end

    /* Create the dumpfile. */
    $dumpfile(dump_fname);
    $dumpvars(0, fetchtb);

    /* Open the relevant files. */
    fimem = $fopen(imem_fname, "r");
    if (fimem == 0) begin
      $display("ERROR: could not open %s", imem_fname);
      $finish;
    end

    fres = $fopen(res_fname, "r");
    if (fres == 0) begin
      $display("ERROR: could not open %s", res_fname);
      $finish;
    end

    /* Initialize program memory from the data file. */
    i = 0;
    while (($fread(
        imem_data, fimem
    )) > 0) begin
      i_mmu.icache_l1[i++] = imem_data[7:0];
      i_mmu.icache_l1[i++] = imem_data[15:8];
      i_mmu.icache_l1[i++] = imem_data[23:16];
      i_mmu.icache_l1[i++] = imem_data[31:24];
    end

    if ($ferror(fimem, errmsg)) begin
      $display("ERROR: failed read with error %s", errmsg);
      $finish;
    end

    /* Start reading from the result file. */
    i = 0;
    while (($fread(
        res_data, fres
    )) > 0) begin
      /* Switch the clock. */
      clk = ~clk;
      #1 clk = ~clk;

      /* Check the result after 10ns. */
      #1
      if (fetch_dec_instr !== res_data) begin
        $display("FAIL: %x != %x", fetch_dec_instr, res_data);
      end
    end

    if ($ferror(fres, errmsg)) begin
      $display("ERROR: failed read with error %s", errmsg);
    end

    /* Cleanup. */
    if (fimem != 0) $fclose(fimem);
    if (fres != 0) $fclose(fres);
  end
endmodule
