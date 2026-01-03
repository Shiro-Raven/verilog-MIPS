module ID_Stage_testbench ();

  reg clk;
  reg [4:0] in_write_register;
  reg [31:0] in_write_data;
  reg in_RegWrite;
  reg [31:0] in_instruction;
  reg [31:0] in_new_pc_value;

  wire [4:0] instr_bits_15_11;
  wire [4:0] instr_bits_20_16;
  wire [31:0] extended_bits;
  wire [31:0] read_data1;
  wire [31:0] read_data2;
  wire [31:0] new_pc_value;
  wire RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch;
  wire [1:0] load_mode;
  wire [2:0] ALUOp;

  integer test_count = 0;

  ID_Stage my_stage (
      .clk(clk),
      .in_write_register(in_write_register),
      .in_write_data(in_write_data),
      .in_RegWrite(in_RegWrite),
      .in_instruction(in_instruction),
      .in_new_pc_value(in_new_pc_value),
      .instr_bits_15_11_out(instr_bits_15_11),
      .instr_bits_20_16_out(instr_bits_20_16),
      .extended_bits_out(extended_bits),
      .read_data1_out(read_data1),
      .read_data2_out(read_data2),
      .new_pc_value_out(new_pc_value),
      .RegDst_out(RegDst),
      .RegWrite_out(RegWrite),
      .ALUSrc_out(ALUSrc),
      .MemWrite_out(MemWrite),
      .MemRead_out(MemRead),
      .MemToReg_out(MemToReg),
      .Branch_out(Branch),
      .load_mode_out(load_mode),
      .ALUOp_out(ALUOp)
  );

  initial clk = 1;
  always #1000 clk = ~clk;

  task check_id_stage;
    input [31:0] instruction_val;
    input [4:0] expected_instr_15_11;
    input [4:0] expected_instr_20_16;
    input [31:0] expected_new_pc;
    input expected_regdst;
    input expected_regwrite;
    input expected_alusrc;
    input [2:0] expected_aluop;
    input expected_memwrite;
    input expected_memread;
    input expected_memtoreg;
    input expected_branch;
    input [1:0] expected_load_mode;
    input [80:0] instruction_name;
    begin
      test_count = test_count + 1;
      in_instruction = instruction_val;
      #1;
      assert (instr_bits_15_11 === expected_instr_15_11 &&
              instr_bits_20_16 === expected_instr_20_16 &&
              new_pc_value === expected_new_pc &&
              RegDst === expected_regdst &&
              RegWrite === expected_regwrite &&
              ALUSrc === expected_alusrc &&
              ALUOp === expected_aluop &&
              MemWrite === expected_memwrite &&
              MemRead === expected_memread &&
              MemToReg === expected_memtoreg &&
              Branch === expected_branch &&
              load_mode === expected_load_mode) else begin
        $error("[FAIL] Test %2d: %s | Expected: instr_15_11=%d, instr_20_16=%d, new_pc=%d, RegDst=%b, RegWrite=%b, ALUSrc=%b, ALUOp=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, Branch=%b, load_mode=%b | Got: instr_15_11=%d, instr_20_16=%d, new_pc=%d, RegDst=%b, RegWrite=%b, ALUSrc=%b, ALUOp=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, Branch=%b, load_mode=%b",
               test_count, instruction_name,
               expected_instr_15_11, expected_instr_20_16, expected_new_pc, expected_regdst, expected_regwrite, expected_alusrc, expected_aluop, expected_memwrite, expected_memread, expected_memtoreg, expected_branch, expected_load_mode,
               instr_bits_15_11, instr_bits_20_16, new_pc_value, RegDst, RegWrite, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, Branch, load_mode);
        $fatal(1);
      end
      $display("[PASS] Test %2d: %s | instr_15_11=%d, instr_20_16=%d, new_pc=%d, RegDst=%b, RegWrite=%b, ALUSrc=%b, ALUOp=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, Branch=%b, load_mode=%b, read_data1=%d, read_data2=%d",
               test_count, instruction_name, instr_bits_15_11, instr_bits_20_16, new_pc_value, RegDst, RegWrite, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, Branch, load_mode, read_data1, read_data2);
    end
  endtask

  initial begin
    $display("═══════════════════════════════════════════════════════════════");
    $display("ID_Stage Test Suite");
    $display("═══════════════════════════════════════════════════════════════");
    $display("");

    in_write_register = 0;
    in_write_data = 0;
    in_RegWrite = 0;
    in_new_pc_value = 0;

    // Test 1: ADD R1, R1, R1
    #2000;
    in_instruction = 32'b00000000001000010000100000000000;
    check_id_stage(32'b00000000001000010000100000000000, 5'd1, 5'd1, 32'd0, 1'b1, 1'b1, 1'b0, 3'b100, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "ADD R1, R1, R1");

    // Test 2: ADD R2, R2, R2
    #2000;
    in_instruction = 32'b00000000010000100001000000000000;
    check_id_stage(32'b00000000010000100001000000000000, 5'd2, 5'd2, 32'd0, 1'b1, 1'b1, 1'b0, 3'b100, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "ADD R2, R2, R2");

    // Test 3: ADD R3, R3, R3
    #2000;
    in_instruction = 32'b00000000011000110001100000000000;
    check_id_stage(32'b00000000011000110001100000000000, 5'd3, 5'd3, 32'd0, 1'b1, 1'b1, 1'b0, 3'b100, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "ADD R3, R3, R3");

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
