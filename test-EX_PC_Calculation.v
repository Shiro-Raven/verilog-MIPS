module EX_PC_Calculation_testbench ();

  wire [31:0] PC_out;
  reg  [31:0] PC_in;
  reg  [15:0] offset;

  EX_PC_Calculation calculation (
      PC_in,
      offset,
      PC_out
  );

  initial begin
    #5 PC_in = 4;
    offset = 2;
    #5 PC_in = 0;
    offset = 4;
    #5 $finish;
  end

  initial begin
    $monitor("PC_in=%d offset=%d PC_out=%d \n", PC_in, offset, PC_out);
  end

endmodule
