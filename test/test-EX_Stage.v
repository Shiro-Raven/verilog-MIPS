module EX_Stage_testbench ();

  localparam PC_OFFSET = 32;
  localparam EXPECTED_PC = 32'd128;  // 0 + (PC_OFFSET << 2)

  reg clk, in_RegDst, in_RegWrite, in_ALUSrc, in_MemWrite, in_MemRead, in_MemToReg, in_branch;
  reg [1:0] in_load_mode;
  reg [2:0] in_ALUOp;
  reg [4:0] in_instr_bits_15_11, in_instr_bits_20_16;
  reg [31:0] in_extended_bits, in_read_data1, in_read_data2, in_new_pc_value;

  wire zero_out, RegWrite_out, MemWrite_out, MemRead_out, MemToReg_out, branch_out;
  wire [1:0] load_mode_out;
  wire [4:0] writebackDestination_out;
  wire [31:0] aluResult_out, rt_out, pc_out;

  integer test_count = 0;

  EX_Stage myStage (
      .clk(clk),
      .in_RegDst(in_RegDst),
      .in_RegWrite(in_RegWrite),
      .in_ALUSrc(in_ALUSrc),
      .in_MemWrite(in_MemWrite),
      .in_MemRead(in_MemRead),
      .in_MemToReg(in_MemToReg),
      .in_ALUOp(in_ALUOp),
      .in_instr_bits_15_11(in_instr_bits_15_11),
      .in_instr_bits_20_16(in_instr_bits_20_16),
      .in_extended_bits(in_extended_bits),
      .in_read_data1(in_read_data1),
      .in_read_data2(in_read_data2),
      .in_new_pc_value(in_new_pc_value),
      .in_load_mode(in_load_mode),
      .in_branch(in_branch),
      .zero_out(zero_out),
      .RegWrite_out(RegWrite_out),
      .MemWrite_out(MemWrite_out),
      .MemRead_out(MemRead_out),
      .MemToReg_out(MemToReg_out),
      .load_mode_out(load_mode_out),
      .writebackDestination_out(writebackDestination_out),
      .aluResult_out(aluResult_out),
      .rt_out(rt_out),
      .pc_out(pc_out),
      .branch_out(branch_out)
  );

  always #1000 clk = ~clk;

  task check_ex_stage;
    input [31:0] expected_pc;
    input [4:0] expected_wb_dest;
    input expected_regwrite;
    input expected_memwrite;
    input expected_memread;
    input expected_memtoreg;
    input [1:0] expected_load_mode;
    input expected_branch;
    input [31:0] expected_rt;
    begin
      test_count = test_count + 1;
      #1;
      assert (pc_out === expected_pc &&
              writebackDestination_out === expected_wb_dest &&
              RegWrite_out === expected_regwrite &&
              MemWrite_out === expected_memwrite &&
              MemRead_out === expected_memread &&
              MemToReg_out === expected_memtoreg &&
              load_mode_out === expected_load_mode &&
              branch_out === expected_branch &&
              rt_out === expected_rt) else begin
        $error("[FAIL] Test %2d | Expected: pc=%d, wb_dest=%d, RegWrite=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, load_mode=%d, branch=%b, rt=%d | Got: pc=%d, wb_dest=%d, RegWrite=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, load_mode=%d, branch=%b, rt=%d",
               test_count, expected_pc, expected_wb_dest,
               expected_regwrite, expected_memwrite, expected_memread, expected_memtoreg, expected_load_mode, expected_branch, expected_rt,
               pc_out, writebackDestination_out,
               RegWrite_out, MemWrite_out, MemRead_out, MemToReg_out, load_mode_out, branch_out, rt_out);
        $fatal(1);
      end
      $display("[PASS] Test %2d | zero=%b, aluResult=%d, pc=%d, wb_dest=%d, RegWrite=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, load_mode=%d, branch=%b, rt=%d",
               test_count, zero_out, aluResult_out, pc_out, writebackDestination_out,
               RegWrite_out, MemWrite_out, MemRead_out, MemToReg_out, load_mode_out, branch_out, rt_out);
    end
  endtask

  initial begin
    $display("═══════════════════════════════════════════════════════════════");
    $display("EX_Stage Test Suite");
    $display("═══════════════════════════════════════════════════════════════");
    $display("");

    clk = 1;
    in_branch = 0;
    in_RegDst = 0;
    in_RegWrite = 0;
    in_ALUSrc = 0;
    in_instr_bits_15_11 = 0;
    in_instr_bits_20_16 = 0;
    in_new_pc_value = 0;

    // Test 1: MemRead=1, load_mode=2
    #2000;
    in_MemWrite = 0;
    in_MemRead = 1;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 7;
    in_ALUOp = 3'b100;
    in_extended_bits = PC_OFFSET;
    check_ex_stage(EXPECTED_PC, 5'd0, 1'b0, 1'b0, 1'b1, 1'b0, 2'd2, 1'b0, 32'd7);

    // Test 2: MemWrite=1, MemRead=1, load_mode=1
    #2000;
    in_MemWrite = 1;
    in_MemRead = 1;
    in_load_mode = 1;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 8;
    in_ALUOp = 3'b100;
    in_extended_bits = PC_OFFSET;
    check_ex_stage(EXPECTED_PC, 5'd0, 1'b0, 1'b1, 1'b1, 1'b0, 2'd1, 1'b0, 32'd8);

    // Test 3: MemWrite=1, MemRead=1, load_mode=2
    #2000;
    in_MemWrite = 1;
    in_MemRead = 1;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 8;
    in_ALUOp = 3'b100;
    in_extended_bits = PC_OFFSET;
    check_ex_stage(EXPECTED_PC, 5'd0, 1'b0, 1'b1, 1'b1, 1'b0, 2'd2, 1'b0, 32'd8);

    // Test 4: MemToReg=1
    #2000;
    in_MemWrite = 0;
    in_MemRead = 0;
    in_load_mode = 2;
    in_MemToReg = 1;
    in_read_data1 = 7;
    in_read_data2 = 7;
    in_ALUOp = 3'b100;
    in_extended_bits = PC_OFFSET;
    check_ex_stage(EXPECTED_PC, 5'd0, 1'b0, 1'b0, 1'b0, 1'b1, 2'd2, 1'b0, 32'd7);

    // Test 5: RegDst=1
    #2000;
    in_RegDst = 1;
    in_instr_bits_15_11 = 5;
    in_MemWrite = 0;
    in_MemRead = 0;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 10;
    in_read_data2 = 20;
    in_ALUOp = 3'b100;
    in_extended_bits = PC_OFFSET;
    check_ex_stage(EXPECTED_PC, 5'd5, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2, 1'b0, 32'd20);

    // Test 6: Branch signal
    #2000;
    in_RegDst = 0;
    in_branch = 1;
    in_MemWrite = 0;
    in_MemRead = 0;
    in_load_mode = 0;
    in_MemToReg = 0;
    in_read_data1 = 5;
    in_read_data2 = 5;
    in_ALUOp = 3'b100;
    in_extended_bits = PC_OFFSET;
    check_ex_stage(EXPECTED_PC, 5'd0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 32'd5);

    #5;
    $display("");
    $display("═══════════════════════════════════════════════════════════════");
    $display("Test Summary");
    $display("═══════════════════════════════════════════════════════════════");
    $display("Total Tests:  %d", test_count);
    $display("All tests completed. If any assertion failed, simulation would have stopped.");
    $display("═══════════════════════════════════════════════════════════════");
    $finish;
  end

endmodule
