//ALU passed test with 10,20 and with 10,-20
module ALU_testbench ();
  wire zero;
  wire [31:0] output1;

  reg [31:0] firstOperand, secondOperand;
  reg [4:0] shamt;
  reg [3:0] aluControlInput;

  ALU alu (
      firstOperand,
      secondOperand,
      aluControlInput,
      output1,
      shamt,
      zero
  );

  initial begin
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 0;
    shamt = 0;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 1;
    shamt = 0;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 2;
    shamt = 0;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 3;
    shamt = 1;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 4;
    shamt = 1;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 6;
    shamt = 0;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 7;
    shamt = 0;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 11;
    shamt = 0;
    #5 firstOperand = 10;
    secondOperand = -20;
    aluControlInput = 12;
    shamt = 0;
    #5 $finish;
  end

  initial begin
    $monitor("time=%d first=%d second=%d shamt=%d alucontrolInput=%d output=%d zero=%d \n", $time,
             firstOperand, secondOperand, shamt, aluControlInput, output1, zero);
  end

endmodule
