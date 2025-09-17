
/*
 * Module 'fetchtb'
 *
 * Testbench for the fetch stage of the CPU.
 */
module fetchtb ();
  /* Wires, registers. */
  logic clk = 0;
  logic [31:0] pc = 31'b0;

  /* Instantiate the whole mmu. We only need the program memory. */
  wire [31:0] mmu_imem_addr;
  wire mmu_imem_drdy;
  wire [31:0] mmu_imem_rdata;
  mmu i_mmu (
      .clk(clk),

      /* No need for data memory. */
      /* verilator lint_off PINCONNECTEMPTY */
      .dmem_addr (),
      .dmem_wdata(),
      .dmem_write(),
      .dmem_read (),
      .dmem_rdu  (),
      .dmem_hwrd (),
      .dmem_wrd  (),
      .dmem_drdy (),
      .dmem_rdata(),
      /* verilator lint_on PINCONNECTEMPTY */

      /* Wire up the instruction memory. */
      .imem_addr (mmu_imem_addr),
      .imem_drdy (mmu_imem_drdy),
      .imem_rdata(mmu_imem_rdata)
  );

  /* Instantiate the fetch module. */
  wire [31:0] fetch_dec_instr = 0;
  wire [31:0] newpc = 0;
  fetch i_fetch (
      .clk(clk),
      .pc(pc),
      .imem_addr(mmu_imem_addr),
      .imem_drdy(mmu_imem_drdy),
      .imem_rdata(mmu_imem_rdata),
      .fetch_dec_instr(fetch_dec_instr),
      .newpc(newpc)
  );

  /* Update the pc from the newpc. */
  always_ff @(posedge clk) begin
    pc <= newpc;
  end

  /* Create the clock. */
  always begin
    #10
    clk = ~clk;
  end

  /* File IO simulation variables. */
  reg [639:0] errmsg;
  string imem_fname;
  string res_fname;
  int fimem;
  int fres;

  /* Load the resuource files for the fetch test. */
  initial begin
    logic [7:0] imem_data;
    int i = 0;

    /* Check if the proper args were supplied. */
    if (!$value$plusargs("IMEM_FILE=%s", imem_fname)) begin
      $display("ERROR: IMEM_FILE must be specified in plusargs.");
      $finish;
    end

    if (!$value$plusargs("RES_FILE=%s", res_fname)) begin
      $display("ERROR: RES_FILE must be specified in plusargs.");
      $finish;
    end

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
      i_mmu.icache_l1[i++] = imem_data;
    end

    if ($ferror(fimem, errmsg)) begin
      $display("ERROR: failed read with error %s", errmsg);
      $finish;
    end

    /* Start reading from 
  end

  /* Cleanup. */
  final begin
    //if (fimem != 0 && $fclose(fimem) != 0) begin
    //  $display("ERROR: failed to close %s", imem_fname);
    //end

    //if (fres != 0 && $fclose(fres) != 0) begin
    //  $display("ERROR: failed to close %s", res_fname);
    //end
  end

  /* Check the fetched instruction against that in the result file. */
  always_ff @(posedge clk) begin
    logic [31:0] res_data;
    int i = 0;

    /* Read from the result file. */
    if ($fread(res_data, fres) <= 0) begin
      if ($ferror(fres, errmsg)) begin
        $display("ERROR: failed read with error %s", errmsg);
      end
      $finish;
    end

    /* Check the result. */
    if (fetch_dec_instr != res_data) begin
      $display("FAIL: %x != %x", fetch_dec_instr, res_data);
    end
  end
endmodule
