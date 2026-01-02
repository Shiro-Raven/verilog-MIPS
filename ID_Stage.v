module ID_Stage (
    input clk,
    input [4:0] in_write_register,
    input [31:0] in_write_data,
    input in_RegWrite,
    input [31:0] in_instruction,
    input [31:0] in_new_pc_value,
    output [4:0] instr_bits_15_11_out,
    output [4:0] instr_bits_20_16_out,
    output [31:0] extended_bits_out,
    output [31:0] read_data1_out,
    output [31:0] read_data2_out,
    output [31:0] new_pc_value_out,
    output RegDst_out,
    output RegWrite_out,
    output ALUSrc_out,
    output MemWrite_out,
    output MemRead_out,
    output MemToReg_out,
    output Branch_out,
    output [1:0] load_mode_out,
    output [2:0] ALUOp_out
);

  assign instr_bits_15_11_out = in_instruction[15:11];
  assign instr_bits_20_16_out = in_instruction[20:16];
  assign new_pc_value_out = in_new_pc_value;

  ID_Register_File Registers (  // INPUT
      clk,
      in_instruction,
      in_write_data,
      in_write_register,
      in_RegWrite,
      // OUTPUT
      read_data1_out,
      read_data2_out,
      extended_bits_out
  );


  ID_Control_Unit Control (  // INPUT
      in_instruction[31:26],
      // OUTPUT
      RegDst_out,
      RegWrite_out,
      ALUSrc_out,
      ALUOp_out,
      MemWrite_out,
      MemRead_out,
      MemToReg_out,
      Branch_out,
      load_mode_out
  );

endmodule
