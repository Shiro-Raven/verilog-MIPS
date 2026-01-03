module IF_Stage_TB ();

  reg clk;
  reg in_PCSrc;
  reg [31:0] in_branch_address;
  wire [31:0] instruction_out;
  wire [31:0] pc_plus_four_out;

  integer test_count = 0;

  IF_Stage IF_Stage_Module (
      .clk(clk),
      .in_PCSrc(in_PCSrc),
      .in_branch_address(in_branch_address),
      .instruction_out(instruction_out),
      .pc_plus_four_out(pc_plus_four_out)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  task check_if_stage;
    input [31:0] expected_pc_plus_four;
    input [31:0] expected_instruction;
    input [80:0] test_name;
    begin
      test_count = test_count + 1;
      #1;
      assert (pc_plus_four_out === expected_pc_plus_four &&
              instruction_out === expected_instruction) else begin
        $error("[FAIL] Test %2d: %s | Expected: pc_plus_four=%d, instruction=%d (0x%h) | Got: pc_plus_four=%d, instruction=%d (0x%h)",
               test_count, test_name, expected_pc_plus_four, expected_instruction, expected_instruction,
               pc_plus_four_out, instruction_out, instruction_out);
        $fatal(1);
      end
      $display("[PASS] Test %2d: %s | pc_plus_four=%d, instruction=%d (0x%h)",
               test_count, test_name, pc_plus_four_out, instruction_out, instruction_out);
    end
  endtask

  initial begin
    $display("═══════════════════════════════════════════════════════════════");
    $display("IF_Stage Test Suite");
    $display("═══════════════════════════════════════════════════════════════");
    $display("");

    in_PCSrc = 0;
    in_branch_address = 0;

    #1;

    // Test 1: Initial state (PC=0)
    check_if_stage(32'd4, 32'd0, "Initial state (PC=0)");

    // Test 2: After 1 cycle (PC=4)
    @(posedge clk);
    #1;
    check_if_stage(32'd8, 32'd0, "After 1 cycle (PC=4)");

    // Test 3: After 2 cycles (PC=8)
    @(posedge clk);
    #1;
    check_if_stage(32'd12, 32'd0, "After 2 cycles (PC=8)");

    // Test 4: Branch (PC=100)
    in_PCSrc = 1;
    in_branch_address = 100;
    @(posedge clk);
    #1;
    check_if_stage(32'd104, 32'd0, "After branch (PC=100)");

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
