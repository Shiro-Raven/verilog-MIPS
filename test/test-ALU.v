module ALU_testbench ();
  wire zero;
  wire [31:0] output1;

  reg [31:0] firstOperand, secondOperand;
  reg [4:0] shamt;
  reg [3:0] aluControlInput;

  integer test_count = 0;

  ALU alu (
      .firstOperand(firstOperand),
      .secondOperand(secondOperand),
      .aluControlInput(aluControlInput),
      .shamt(shamt),
      .zero(zero),
      .aluResult(output1)
  );

  task check_result;
    input [31:0] expected;
    input expected_zero;
    input [80:0] operation_name;
    begin
      test_count = test_count + 1;
      #1;
      assert (output1 === expected && zero === expected_zero)
      else begin
        $error(
            "[FAIL] Test %2d: %s | Expected: %d (0x%h), Got: %d (0x%h) | Expected Zero: %b, Got: %b",
            test_count, operation_name, expected, expected, output1, output1, expected_zero, zero);
        $fatal(1);
      end
      $display("[PASS] Test %2d: %s | Expected: %d (0x%h), Got: %d (0x%h) | Zero: %b", test_count,
               operation_name, expected, expected, output1, output1, zero);
    end
  endtask

  initial begin
    $display(
        "═══════════════════════════════════════════════════════════════");
    $display("ALU Test Suite");
    $display(
        "═══════════════════════════════════════════════════════════════");
    $display("Testing with firstOperand=10, secondOperand=-20");
    $display("");

    // Test 1: AND (ctrl=0)
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0000;
    shamt = 0;
    check_result(10 & (-20), 1'b0, "AND");

    // Test 2: OR (ctrl=1)
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0001;
    shamt = 0;
    check_result(10 | (-20), 1'b0, "OR");

    // Test 3: ADD (ctrl=2)
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0010;
    shamt = 0;
    check_result(10 + (-20), 1'b0, "ADD");

    // Test 4: SLL (ctrl=3) - shift left by shamt=1
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0011;
    shamt = 1;
    check_result((-20) << 1, 1'b0, "SLL");

    // Test 5: SRL (ctrl=4) - shift right by shamt=1
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0100;
    shamt = 1;
    check_result((-20) >> 1, 1'b0, "SRL");

    // Test 6: SUB (ctrl=6)
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0110;
    shamt = 0;
    check_result(10 - (-20), 1'b0, "SUB");

    // Test 7: SLT (ctrl=7) - 10 < -20 should be 0 (false)
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b0111;
    shamt = 0;
    check_result(32'd0, 1'b0, "SLT");

    // Test 8: SLTU (ctrl=11) - unsigned comparison
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b1011;
    shamt = 0;
    // unsigned(10) < unsigned(-20) = 10 < 4294967276 = 1 (true)
    check_result(32'd1, 1'b0, "SLTU");

    // Test 9: Default case (ctrl=12)
    firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4'b1100;
    shamt = 0;
    check_result(32'd0, 1'b0, "DEFAULT");

    // Test 10: Zero flag test
    firstOperand = 10;
    secondOperand = 10;
    aluControlInput = 4'b0010;
    shamt = 0;
    #1;
    test_count = test_count + 1;
    assert (zero === 1'b1 && output1 === 20)
    else begin
      $error("[FAIL] Test %2d: ZERO FLAG | Expected Zero=1, Got Zero=%b, Result=%d", test_count,
             zero, output1);
      $fatal(1);
    end
    $display("[PASS] Test %2d: ZERO FLAG | Operands equal, Zero=%b, Result=%d", test_count, zero,
             output1);

    #5;
    $display("");
    $display(
        "═══════════════════════════════════════════════════════════════");
    $display("Test Summary");
    $display(
        "═══════════════════════════════════════════════════════════════");
    $display("Total Tests:  %d", test_count);
    $display("All tests completed. If any assertion failed, simulation would have stopped.");
    $display(
        "═══════════════════════════════════════════════════════════════");
    $finish;
  end

endmodule
