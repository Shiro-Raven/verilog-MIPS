//ALU passed test with 10,20 and with 10,-20
module ALU_testbench ();

  wire RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch;
  wire [1:0] load_mode;
  wire [2:0] ALUOp;

  reg  [5:0] OP_CODE;

  ID_Control_Unit control (
      OP_CODE,
      // Outputs
      RegDst,
      RegWrite,
      ALUSrc,
      ALUOp,
      MemWrite,
      MemRead,
      MemToReg,
      Branch,
      load_mode
  );

  initial begin
    #5 OP_CODE = 6'b000_000;
    #5 OP_CODE = 6'b001_000;
    #5 OP_CODE = 6'b100_111;
    #5 OP_CODE = 6'b100_001;
    #5 OP_CODE = 6'b100_101;
    #5 OP_CODE = 6'b101_011;
    #5 OP_CODE = 6'b000_100;
    #5 OP_CODE = 6'b001_100;
    #5 OP_CODE = 6'b001_101;
    #5 $finish;
  end

  initial begin
    $monitor(
        "time=%d RegDst=%d RegWrite=%d ALUSrc=%d ALUOp=%b MemWrite=%d Memread=%d MemToReg=%d branch=%d load_mode=%b \n",
        $time, RegDst, RegWrite, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, Branch, load_mode);
  end

endmodule
