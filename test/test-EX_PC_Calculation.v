module EX_PC_Calculation_testbench ();

  wire [31:0] PC_out;
  reg [31:0] PC_in;
  reg [31:0] offset;

  integer test_count = 0;

  EX_PC_Calculation calculation (
      .PC_in (PC_in),
      .offset(offset),
      .PC_out(PC_out)
  );

  task check_pc;
    input [31:0] pc_in_val;
    input [31:0] offset_val;
    input [31:0] expected;
    begin
      test_count = test_count + 1;
      PC_in = pc_in_val;
      offset = offset_val;
      #1;
      assert (PC_out === expected)
      else begin
        $error(
            "[FAIL] Test %2d: PC_in=%d, offset=%d | Expected PC_out=%d (0x%h), Got PC_out=%d (0x%h)",
            test_count, PC_in, offset, expected, expected, PC_out, PC_out);
        $fatal(1);
      end
      $display("[PASS] Test %2d: PC_in=%d, offset=%d | PC_out=%d (0x%h) [Expected: %d]",
               test_count, PC_in, offset, PC_out, PC_out, expected);
    end
  endtask

  initial begin
    $display(
        "═══════════════════════════════════════════════════════════════");
    $display("EX_PC_Calculation Test Suite");
    $display(
        "═══════════════════════════════════════════════════════════════");
    $display("Testing PC_out = PC_in + (offset << 2)");
    $display("");

    // Test 1: PC_in = 4, offset = 2
    // Expected: 4 + (2 << 2) = 4 + 8 = 12
    check_pc(32'd4, 32'd2, 32'd12);

    // Test 2: PC_in = 0, offset = 4
    // Expected: 0 + (4 << 2) = 0 + 16 = 16
    check_pc(32'd0, 32'd4, 32'd16);

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
