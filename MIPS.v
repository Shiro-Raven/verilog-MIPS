module MIPS (
    input clk
);

  // --- IF Wires --- //
  wire IF_PCSrc;
  wire [31:0] IF_branch_address;
  wire [31:0] instruction_IF;
  wire [31:0] pc_plus_four_IF;
  // --- END IF Wires --- //

  // --- ID Wires --- //
  wire [4:0] ID_write_register;
  wire [31:0] ID_write_data;
  wire ID_RegWrite;
  wire [31:0] ID_instruction;
  wire [31:0] ID_new_pc_value;
  wire [4:0] instr_bits_15_11_ID;
  wire [4:0] instr_bits_20_16_ID;
  wire [31:0] extended_bits_ID;
  wire [31:0] read_data1_ID;
  wire [31:0] read_data2_ID;
  wire [31:0] new_pc_value_ID;
  wire RegDst_ID;
  wire RegWrite_ID;
  wire ALUSrc_ID;
  wire MemWrite_ID;
  wire MemRead_ID;
  wire MemToReg_ID;
  wire Branch_ID;
  wire [1:0] load_mode_ID;
  wire [2:0] ALUOp_ID;
  // --- END ID Wires --- //

  // --- EX Wires --- //
  wire EX_RegDst;
  wire EX_RegWrite;
  wire EX_ALUSrc;
  wire EX_MemWrite;
  wire EX_MemRead;
  wire EX_MemToReg;
  wire [2:0] EX_ALUOp;
  wire [4:0] EX_instr_bits_15_11;
  wire [4:0] EX_instr_bits_20_16;
  wire [31:0] EX_extended_bits;
  wire [31:0] EX_read_data1;
  wire [31:0] EX_read_data2;
  wire [31:0] EX_new_pc_value;
  wire [1:0] EX_load_mode;
  wire EX_branch;
  wire zero_EX;
  wire RegWrite_EX;
  wire MemWrite_EX;
  wire MemRead_EX;
  wire MemToReg_EX;
  wire [1:0] load_mode_EX;
  wire [4:0] writebackDestination_EX;
  wire [31:0] aluResult_EX;
  wire [31:0] rt_EX;
  wire [31:0] pc_EX;
  wire branch_EX;
  // --- END EX Wires --- //

  // --- MEM Wires --- //
  wire MEM_mem_to_reg;
  wire [31:0] MEM_address;
  wire [31:0] MEM_write_data;
  wire MEM_mem_write;
  wire MEM_reg_write;
  wire MEM_mem_read;
  wire [1:0] MEM_load_mode;
  wire MEM_zero;
  wire MEM_branch;
  wire [4:0] MEM_write_back_destination;
  wire [31:0] read_data_MEM;
  wire mem_to_reg_MEM;
  wire reg_write_MEM;
  wire [31:0] address_MEM;
  wire [4:0] write_back_destination_MEM;
  // --- END MEM Wires --- //

  // --- WB Wires --- //
  wire WB_mem_to_reg;
  wire WB_reg_write;
  wire [4:0] WB_write_back_destination;
  wire [31:0] WB_address;
  wire [31:0] WB_read_data;
  // --- END WB Wires --- //


  // --- IF Stage --- //
  IF_Stage IF_Stage_Module (
      clk,
      IF_PCSrc,
      IF_branch_address,
      instruction_IF,
      pc_plus_four_IF
  );
  // --- END IF Stage --- //

  // --- IF/ID Pipeline Register --- //
  IF_ID_Reg IF_ID_Pipeline_Register (
      clk,
      instruction_IF,
      pc_plus_four_IF,
      ID_instruction,
      ID_new_pc_value
  );
  // --- END IF/ID Pipeline Register --- //

  // --- ID Stage --- //
  ID_Stage ID_Stage_Module (
      clk,
      ID_write_register,
      ID_write_data,
      ID_RegWrite,
      ID_instruction,
      ID_new_pc_value,
      instr_bits_15_11_ID,
      instr_bits_20_16_ID,
      extended_bits_ID,
      read_data1_ID,
      read_data2_ID,
      new_pc_value_ID,
      RegDst_ID,
      RegWrite_ID,
      ALUSrc_ID,
      MemWrite_ID,
      MemRead_ID,
      MemToReg_ID,
      Branch_ID,
      load_mode_ID,
      ALUOp_ID
  );
  // --- END ID Stage -- //

  // --- ID/EX Pipeline Register --- //
  ID_EX_Reg ID_EX_Pipeline_Register (
      clk,
      instr_bits_15_11_ID,
      instr_bits_20_16_ID,
      extended_bits_ID,
      read_data1_ID,
      read_data2_ID,
      new_pc_value_ID,
      RegDst_ID,
      RegWrite_ID,
      ALUSrc_ID,
      MemWrite_ID,
      MemRead_ID,
      MemToReg_ID,
      Branch_ID,
      load_mode_ID,
      ALUOp_ID,
      EX_instr_bits_15_11,
      EX_instr_bits_20_16,
      EX_extended_bits,
      EX_read_data1,
      EX_read_data2,
      EX_new_pc_value,
      EX_RegDst,
      EX_RegWrite,
      EX_ALUSrc,
      EX_MemWrite,
      EX_MemRead,
      EX_MemToReg,
      EX_branch,
      EX_load_mode,
      EX_ALUOp
  );
  // --- END ID/EX Pipeline Register --- //

  // --- EX Stage --- //
  EX_Stage EX_Stage_Module (
      clk,
      EX_RegDst,
      EX_RegWrite,
      EX_ALUSrc,
      EX_MemWrite,
      EX_MemRead,
      EX_MemToReg,
      EX_ALUOp,
      EX_instr_bits_15_11,
      EX_instr_bits_20_16,
      EX_extended_bits,
      EX_read_data1,
      EX_read_data2,
      EX_new_pc_value,
      EX_load_mode,
      EX_branch,
      zero_EX,
      RegWrite_EX,
      MemWrite_EX,
      MemRead_EX,
      MemToReg_EX,
      load_mode_EX,
      writebackDestination_EX,
      aluResult_EX,
      rt_EX,
      pc_EX,
      branch_EX
  );
  // --- END EX Stage --- //

  // --- EX/MEM Pipeline Register --- //
  EX_MEM_Reg EX_MEM_Pipeline_Register (
      clk,
      RegWrite_EX,
      MemWrite_EX,
      MemRead_EX,
      MemToReg_EX,
      pc_EX,
      zero_EX,
      aluResult_EX,
      rt_EX,
      writebackDestination_EX,
      load_mode_EX,
      branch_EX,
      MEM_reg_write,
      MEM_mem_write,
      MEM_mem_read,
      MEM_mem_to_reg,
      IF_branch_address,
      MEM_zero,
      MEM_address,
      MEM_write_data,
      MEM_write_back_destination,
      MEM_load_mode,
      MEM_branch
  );
  // --- END EX/MEM Pipeline Register --- //

  // --- MEM Stage --- //
  MEM_Stage MEM_Stage_Module (
      clk,
      MEM_mem_to_reg,
      MEM_address,
      MEM_write_data,
      MEM_mem_write,
      MEM_reg_write,
      MEM_mem_read,
      MEM_load_mode,
      MEM_zero,
      MEM_branch,
      MEM_write_back_destination,
      IF_PCSrc,
      read_data_MEM,
      mem_to_reg_MEM,
      reg_write_MEM,
      address_MEM,
      write_back_destination_MEM
  );
  // --- END MEM Stage --- //

  // --- MEM/WB Pipeline Register --- //
  MEM_WB_Reg MEM_WB_Pipeline_Register (
      clk,
      write_back_destination_MEM,
      reg_write_MEM,
      read_data_MEM,
      address_MEM,
      mem_to_reg_MEM,
      WB_write_back_destination,
      WB_reg_write,
      WB_read_data,
      WB_address,
      WB_mem_to_reg
  );
  // --- END MEM/WB Pipeline Register --- //

  // --- WB Stage --- //
  WB_Stage WB_Stage_Module (
      WB_mem_to_reg,
      WB_reg_write,
      WB_write_back_destination,
      WB_address,
      WB_read_data,
      ID_write_data,
      ID_RegWrite,
      ID_write_register
  );
  // --- END WB Stage --- //

endmodule
