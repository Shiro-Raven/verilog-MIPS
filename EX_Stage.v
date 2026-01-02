module EX_Stage (
    input clk,
    input in_RegDst,
    input in_RegWrite,
    input in_ALUSrc,
    input in_MemWrite,
    input in_MemRead,
    input in_MemToReg,
    input [2:0] in_ALUOp,
    input [4:0] in_instr_bits_15_11,
    input [4:0] in_instr_bits_20_16,
    input [31:0] in_extended_bits,
    input [31:0] in_read_data1,
    input [31:0] in_read_data2,
    input [31:0] in_new_pc_value,
    input [1:0] in_load_mode,
    input in_branch,
    output zero_out,
    output RegWrite_out,
    output MemWrite_out,
    output MemRead_out,
    output MemToReg_out,
    output [1:0] load_mode_out,
    output [4:0] writebackDestination_out,
    output [31:0] aluResult_out,
    output [31:0] rt_out,
    output [31:0] pc_out,
    output branch_out
);

  // multiplexer before ALU
  wire [31:0] second_alu_input;
  assign second_alu_input = (in_ALUSrc === 1) ? in_extended_bits : in_read_data2;

  // passing signals on
  assign RegWrite_out = in_RegWrite;
  assign MemWrite_out = in_MemWrite;
  assign MemRead_out = in_MemRead;
  assign MemToReg_out = in_MemToReg;
  assign branch_out = in_branch;
  assign load_mode_out = in_load_mode;
  assign rt_out = in_read_data2;

  // ALU Control
  wire [3:0] aluControlInput;
  ALU_Control alu_control (
      in_ALUOp,
      in_extended_bits[5:0],
      aluControlInput
  );

  // ALU
  ALU alu (
      in_read_data1,
      second_alu_input,
      aluControlInput,
      in_extended_bits[10:6],
      aluResult_out,
      zero_out
  );

  // PC calculation unit
  EX_PC_Calculation pc_calculator (
      in_new_pc_value,
      in_extended_bits,
      pc_out
  );

  // multiplexer for write_back_destination
  assign writebackDestination_out = (in_RegDst === 1) ? in_instr_bits_15_11 : in_instr_bits_20_16;

endmodule
