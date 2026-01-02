module ALU_Control (
    // TODO finalize the codes used for aluOp
    input [2:0] aluOp,
    input [5:0] funct,
    output reg [3:0] aluControlInput
);

  always @(aluOp, funct) begin
    // R-type
    if (aluOp == 3'b100) begin
      case (funct)
        6'b100000: aluControlInput <= 4'b0010;  // add
        6'b100010: aluControlInput <= 4'b0110;  // sub
        6'b100100: aluControlInput <= 4'b0000;  // and
        6'b100101: aluControlInput <= 4'b0001;  // or
        6'b000000: aluControlInput <= 4'b0011;  // sll
        6'b000010: aluControlInput <= 4'b0100;  // srl
        6'b101010: aluControlInput <= 4'b0111;  // slt
        6'b101011: aluControlInput <= 4'b1011;  // sltu
      endcase
    end  // non-R-type
    else begin
      case (aluOp)
        3'b000: aluControlInput <= 4'b0010;  // sw, lw, addi, lhu, lh
        3'b001: aluControlInput <= 4'b0110;  // beq
        3'b010: aluControlInput <= 4'b0001;  // ori
        3'b011: aluControlInput <= 4'b0000;  // andi
      endcase
    end
  end

endmodule
