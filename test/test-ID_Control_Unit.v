module ID_Control_Unit_testbench ();

  wire RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch;
  wire [1:0] load_mode;
  wire [2:0] ALUOp;

  reg [5:0] OP_CODE;

  integer test_count = 0;

  ID_Control_Unit control (
      .OP_CODE(OP_CODE),
      .RegDst(RegDst),
      .RegWrite(RegWrite),
      .ALUSrc(ALUSrc),
      .ALUOp(ALUOp),
      .MemWrite(MemWrite),
      .MemRead(MemRead),
      .MemToReg(MemToReg),
      .Branch(Branch),
      .load_mode(load_mode)
  );

  task check_control;
    input [5:0] opcode;
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
      OP_CODE = opcode;
      #1;
      assert (RegDst === expected_regdst &&
              RegWrite === expected_regwrite &&
              ALUSrc === expected_alusrc &&
              ALUOp === expected_aluop &&
              MemWrite === expected_memwrite &&
              MemRead === expected_memread &&
              MemToReg === expected_memtoreg &&
              Branch === expected_branch &&
              load_mode === expected_load_mode) else begin
        $error("[FAIL] Test %2d: %s (OP_CODE=6'b%b) | Expected: RegDst=%b, RegWrite=%b, ALUSrc=%b, ALUOp=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, Branch=%b, load_mode=%b | Got: RegDst=%b, RegWrite=%b, ALUSrc=%b, ALUOp=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, Branch=%b, load_mode=%b",
               test_count, instruction_name, opcode,
               expected_regdst, expected_regwrite, expected_alusrc, expected_aluop, expected_memwrite, expected_memread, expected_memtoreg, expected_branch, expected_load_mode,
               RegDst, RegWrite, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, Branch, load_mode);
        $fatal(1);
      end
      $display("[PASS] Test %2d: %s (OP_CODE=6'b%b) | RegDst=%b, RegWrite=%b, ALUSrc=%b, ALUOp=%b, MemWrite=%b, MemRead=%b, MemToReg=%b, Branch=%b, load_mode=%b",
               test_count, instruction_name, opcode, RegDst, RegWrite, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, Branch, load_mode);
    end
  endtask

  initial begin
    $display("═══════════════════════════════════════════════════════════════");
    $display("ID_Control_Unit Test Suite");
    $display("═══════════════════════════════════════════════════════════════");
    $display("");

    // Test 1: R-Type (6'b000_000)
    check_control(6'b000_000, 1'b1, 1'b1, 1'b0, 3'b100, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "R-Type");

    // Test 2: ADDI (6'b001_000)
    check_control(6'b001_000, 1'b0, 1'b1, 1'b1, 3'b000, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "ADDI");

    // Test 3: Unknown opcode (6'b100_111) - default case
    check_control(6'b100_111, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "Unknown (default)");

    // Test 4: LH (6'b100_001)
    check_control(6'b100_001, 1'b0, 1'b1, 1'b1, 3'b000, 1'b0, 1'b1, 1'b0, 1'b0, 2'b01, "LH");

    // Test 5: LHU (6'b100_101)
    check_control(6'b100_101, 1'b0, 1'b1, 1'b1, 3'b000, 1'b0, 1'b1, 1'b0, 1'b0, 2'b10, "LHU");

    // Test 6: SW (6'b101_011)
    check_control(6'b101_011, 1'b0, 1'b0, 1'b1, 3'b000, 1'b1, 1'b0, 1'b1, 1'b0, 2'b00, "SW");

    // Test 7: BEQ (6'b000_100)
    check_control(6'b000_100, 1'b0, 1'b0, 1'b0, 3'b001, 1'b0, 1'b0, 1'b1, 1'b1, 2'b00, "BEQ");

    // Test 8: ANDI (6'b001_100)
    check_control(6'b001_100, 1'b0, 1'b1, 1'b1, 3'b011, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "ANDI");

    // Test 9: ORI (6'b001_101)
    check_control(6'b001_101, 1'b0, 1'b1, 1'b1, 3'b010, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, "ORI");

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
