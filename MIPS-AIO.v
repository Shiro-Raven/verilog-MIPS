module ALU_Control (
    aluOp,
    funct,
    aluControlInput
);

  // TODO finalize the codes used for aluOp
  input [2:0] aluOp;
  input [5:0] funct;

  output reg [3:0] aluControlInput;

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

module ALU (
    firstOperand,
    secondOperand,
    aluControlInput,
    shamt,
    aluResult,
    zero
);

  input signed [31:0] firstOperand, secondOperand;
  input [4:0] shamt;
  input [3:0] aluControlInput;

  output zero;
  output reg [31:0] aluResult;

  assign zero = (firstOperand === secondOperand);

  always @(firstOperand, secondOperand, aluControlInput, shamt) begin
    case (aluControlInput)
      4'b0000: aluResult <= firstOperand & secondOperand;  // and
      4'b0001: aluResult <= firstOperand | secondOperand;  // or
      4'b0010: aluResult <= firstOperand + secondOperand;  // add
      4'b0011: aluResult <= secondOperand << shamt;  // sll
      4'b0100: aluResult <= secondOperand >> shamt;  // srl
      4'b0110: aluResult <= firstOperand - secondOperand;  // sub
      4'b0111: aluResult <= firstOperand < secondOperand;  // slt
      4'b1011: aluResult <= $unsigned(firstOperand) < $unsigned(secondOperand);  // sltu
      default: aluResult <= 0;  // undefined operation
    endcase
  end

endmodule

module EX_MEM_Reg (
    input clk,
    input RegWrite_in,
    input MemWrite_in,
    input MemRead_in,
    input MemToReg_in,
    input [31:0] pc_in,
    input zero_in,
    input [31:0] aluResult_in,
    input [31:0] rt_in,
    input [4:0] writebackDestination_in,
    input [1:0] load_mode_in,
    input branch_in,
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg MemRead_out,
    output reg MemToReg_out,
    output reg [31:0] pc_out,
    output reg zero_out,
    output reg [31:0] aluResult_out,
    output reg [31:0] rt_out,
    output reg [4:0] writebackDestination_out,
    output reg [1:0] load_mode_out,
    output reg branch_out
);

  always @(posedge clk) begin
    zero_out <= zero_in;
    writebackDestination_out <= writebackDestination_in;
    aluResult_out <= aluResult_in;
    rt_out <= rt_in;
    pc_out <= pc_in;

    // control signals passed from decode stage to mem stage
    RegWrite_out <= RegWrite_in;
    MemWrite_out <= MemWrite_in;
    MemRead_out <= MemRead_in;
    MemToReg_out <= MemToReg_in;
    load_mode_out <= load_mode_in;
    branch_out <= branch_in;

  end

endmodule

module EX_PC_Calculation (
    PC_in,
    offset,
    PC_out
);

  input [31:0] PC_in;
  input [31:0] offset;

  output [31:0] PC_out;


  assign PC_out = PC_in + (offset << 2);

endmodule

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

module ID_Control_Unit (
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

  input [5:0] OP_CODE;
  output reg RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch;
  output reg [1:0] load_mode;
  output reg [2:0] ALUOp;


  always @(OP_CODE) begin
    // Default most common values
    RegWrite <= 1;
    ALUSrc <= 0;
    MemWrite <= 0;
    MemRead <= 0;
    MemToReg <= 1;
    load_mode <= 2'b00;
    Branch <= 0;

    case (OP_CODE)
      // R-Type
      6'b000_000: begin
        RegDst <= 1;
        ALUOp  <= 3'b100;
      end
      // ADD-Immediate
      6'b001_000: begin
        RegDst <= 0;
        ALUSrc <= 1;
        ALUOp  <= 3'b000;
      end
      // LW, LH, LHU
      6'b100_011: begin
        RegDst <= 0;
        ALUSrc <= 1;
        ALUOp <= 3'b000;
        MemRead <= 1;
        MemToReg <= 0;
      end
      6'b100_001: begin
        RegDst <= 0;
        ALUSrc <= 1;
        ALUOp <= 3'b000;
        MemRead <= 1;
        MemToReg <= 0;
        load_mode <= 2'b01;
      end
      6'b100_101: begin
        RegDst <= 0;
        ALUSrc <= 1;
        ALUOp <= 3'b000;
        MemRead <= 1;
        MemToReg <= 0;
        load_mode <= 2'b10;
      end
      // SW
      6'b101_011: begin
        RegWrite <= 0;
        ALUSrc <= 1;
        ALUOp <= 3'b000;
        MemWrite <= 1;
      end
      // BEQ
      6'b000_100: begin
        RegWrite <= 0;
        ALUOp <= 3'b001;
        Branch <= 1;
      end
      // AND-immediate
      6'b001_100: begin
        RegDst <= 0;
        ALUSrc <= 1;
        ALUOp  <= 3'b011;
      end
      // OR-immediate
      6'b001_101: begin
        RegDst <= 0;
        ALUSrc <= 1;
        ALUOp  <= 3'b010;
      end
      default: begin
        RegDst <= 0;
        RegWrite <= 0;
        ALUOp <= 3'b000;
      end
    endcase
  end

endmodule

module ID_EX_Reg (
    input clk,
    input [4:0] in_instr_bits_15_11,
    input [4:0] in_instr_bits_20_16,
    input [31:0] in_extended_bits,
    input [31:0] in_read_data1,
    input [31:0] in_read_data2,
    input [31:0] in_new_pc_value,
    input in_RegDst,
    in_RegWrite,
    in_ALUSrc,
    in_MemWrite,
    in_MemRead,
    in_MemToReg,
    in_Branch,
    input [1:0] in_load_mode,
    input [2:0] in_ALUOp,
    output reg [4:0] instr_bits_15_11,
    output reg [4:0] instr_bits_20_16,
    output reg [31:0] extended_bits,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2,
    output reg [31:0] new_pc_value,
    output reg RegDst,
    RegWrite,
    ALUSrc,
    MemWrite,
    MemRead,
    MemToReg,
    Branch,
    output reg [1:0] load_mode,
    output reg [2:0] ALUOp
);

  always @(posedge clk) begin
    instr_bits_15_11 <= in_instr_bits_15_11;
    instr_bits_20_16 <= in_instr_bits_20_16;
    extended_bits <= in_extended_bits;
    read_data1 <= in_read_data1;
    read_data2 <= in_read_data2;
    new_pc_value <= in_new_pc_value;
    RegDst <= in_RegDst;
    RegWrite <= in_RegWrite;
    ALUSrc <= in_ALUSrc;
    ALUOp <= in_ALUOp;
    MemWrite <= in_MemWrite;
    MemRead <= in_MemRead;
    MemToReg <= in_MemToReg;
    load_mode <= in_load_mode;
    Branch <= in_Branch;
  end

endmodule

// extended_bits refer to the ouput of the extender
module ID_Register_File (  // Input
    clk,
    instruction,
    write_data,
    write_register,
    RegWrite,
    // Output
    read_data1,
    read_data2,
    extended_bits
);

  // INPUT 
  input clk;
  input [31:0] instruction;
  input [31:0] write_data;
  input [4:0] write_register;
  input RegWrite;

  // OUTPUT
  output [31:0] read_data1;
  output [31:0] read_data2;
  output [31:0] extended_bits;

  reg [31:0] registers[31:0];


  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) registers[i] = 32'b0;
    registers[29] = 32'd4000;
  end

  assign read_data1 = registers[instruction[25:21]];
  assign read_data2 = registers[instruction[20:16]];
  assign extended_bits = $signed(instruction[15:0]);


  always @(posedge clk) begin
    if ((RegWrite === 1) && (write_register !== 5'b0)) begin
      registers[write_register] <= write_data;
    end
  end

endmodule

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

module IF_ID_Reg (
    input clk,
    input [31:0] in_instruction,
    input [31:0] in_pc_plus_four,
    output reg [31:0] instruction_out,
    output reg [31:0] pc_plus_four_out
);

  always @(posedge clk) begin
    instruction_out  <= in_instruction;
    pc_plus_four_out <= in_pc_plus_four;
  end

endmodule

module IF_Stage (
    input clk,
    input in_PCSrc,
    input [31:0] in_branch_address,
    output [31:0] instruction_out,
    output [31:0] pc_plus_four_out
);

  reg [31:0] PC = 0;
  reg [31:0] instruction_memory[0:3999];  //adjusted due to constraints by modelsim

  integer i = 0;
  initial begin
    for (i = 0; i < 4000; i = i + 1) instruction_memory[i] = 31'b0;
  end

  assign pc_plus_four_out = PC + 4;
  assign instruction_out  = instruction_memory[PC/4];

  always @(posedge clk) begin
    PC <= ((in_PCSrc === 1) ? in_branch_address : pc_plus_four_out);
  end

endmodule

module MEM_Data_Memory (
    read_data,
    mem_write,
    mem_read,
    load_mode,
    address,
    write_data
);

  input mem_read;
  input mem_write;
  input [1:0] load_mode;
  input [31:0] address;
  input [31:0] write_data;
  output reg [31:0] read_data;
  reg [7:0] ram[0:3999];  //adjusted due to constraints by modelsim

  integer i = 0;
  initial begin
    for (i = 0; i < 4000; i = i + 1) ram[i] <= 8'b0;
  end

  always @(mem_read, mem_write, address, write_data, load_mode) begin
    if (mem_read === 1) begin
      case (load_mode)
        2'b00:   read_data <= {ram[address], ram[address+1], ram[address+2], ram[address+3]};
        2'b01:   read_data <= $signed({ram[address], ram[address+1]});
        2'b10:   read_data <= $unsigned({ram[address], ram[address+1]});
        default: $display("Error in MEM_Data_Memory");
      endcase
    end

    if (mem_write === 1) begin
      {ram[address], ram[address+1], ram[address+2], ram[address+3]} <= write_data;
    end
  end


endmodule

module MEM_Stage (
    input clk,
    input in_mem_to_reg,
    input [31:0] in_address,
    input [31:0] in_write_data,
    input in_mem_write,
    input in_reg_write,
    input in_mem_read,
    input [1:0] in_load_mode,
    input in_zero,
    input in_branch,
    input [4:0] in_write_back_destination,
    output pc_src_out,
    output [31:0] read_data_out,
    output mem_to_reg_out,
    output reg_write_out,
    output [31:0] address_out,
    output [4:0] write_back_destination_out
);

  wire [31:0] read_memory_out;

  and (pc_src_out, in_zero, in_branch);

  assign mem_to_reg_out = in_mem_to_reg;
  assign address_out = in_address;
  assign reg_write_out = in_reg_write;
  assign write_back_destination_out = in_write_back_destination;

  MEM_Data_Memory mem_ram (
      // OUTPUT
      read_data_out,
      // INPUT
      in_mem_write,
      in_mem_read,
      in_load_mode,
      in_address,
      in_write_data
  );

endmodule

module MEM_WB_Reg (
    input clk,
    input [4:0] write_back_destination_in,
    input reg_write_in,
    input [31:0] read_data_in,
    input [31:0] address_in,
    input mem_to_reg_in,
    output reg [4:0] write_back_destination_out,
    output reg reg_write_out,
    output reg [31:0] read_data_out,
    output reg [31:0] address_out,
    output reg mem_to_reg_out
);

  always @(posedge clk) begin
    reg_write_out <= reg_write_in;
    read_data_out <= read_data_in;
    address_out <= address_in;
    write_back_destination_out <= write_back_destination_in;
    mem_to_reg_out <= mem_to_reg_in;
  end

endmodule

module WB_Stage (
    input in_mem_to_reg,
    input in_reg_write,
    input [4:0] in_write_back_destination,
    input [31:0] in_address,
    input [31:0] in_read_data,
    output [31:0] write_data_out,
    output reg_write_out,
    output [4:0] write_back_destination_out
);

  assign write_data_out = (in_mem_to_reg === 1) ? in_address : in_read_data;
  assign reg_write_out = in_reg_write;
  assign write_back_destination_out = in_write_back_destination;

endmodule

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

module MIPS_testbench ();

  // the clock
  reg clk;
  integer cycle_counter;

  // instantiate the mips processor
  MIPS mips (clk);

  // get the clock working
  initial begin
    mips.IF_Stage_Module.instruction_memory[0] <= 32'h20090005;  // addi $t1, $0, 5
    mips.IF_Stage_Module.instruction_memory[1] <= 32'h200A0007;  // addi $t2, $0, 7
    mips.IF_Stage_Module.instruction_memory[2] <= 32'h200BFFEC;  // addi $t3, $0, -20
    mips.IF_Stage_Module.instruction_memory[3] <= 32'h200E0FFF;  // addi $t6, $0, 0x0FFF
    mips.IF_Stage_Module.instruction_memory[4] <= 32'h0;  // nop
    mips.IF_Stage_Module.instruction_memory[5] <= 32'h012A8020;  // add $s0, $t1, $t2
    mips.IF_Stage_Module.instruction_memory[6] <= 32'h01498822;  // sub $s1, $t2, $t1
    mips.IF_Stage_Module.instruction_memory[7] <= 32'hAC0E0000;  // sw $t6 0($0)
    mips.IF_Stage_Module.instruction_memory[8] <= 32'h012A9024;  // and $s2, $t1, $t2
    mips.IF_Stage_Module.instruction_memory[9] <= 32'h012A9825;  // or $s3, $t1, $t2
    mips.IF_Stage_Module.instruction_memory[10] <= 32'h0009A080;  // sll $s4, $t1, 2
    mips.IF_Stage_Module.instruction_memory[11] <= 32'h0009A842;  // srl $s5, $t1, 1
    mips.IF_Stage_Module.instruction_memory[12] <= 32'h012AB02A;  // slt $s6, $t2, $t1
    mips.IF_Stage_Module.instruction_memory[13] <= 32'h0169B82B;  // sltu $s7, $t3, $t1
    mips.IF_Stage_Module.instruction_memory[14] <= 32'h312C0001;  // andi $t4, $t1, 1
    mips.IF_Stage_Module.instruction_memory[15] <= 32'h352D0002;  // ori $t5, $t1, 2
    mips.IF_Stage_Module.instruction_memory[16] <= 32'h8C0F0000;  // lw $t7, 0($0)
    mips.IF_Stage_Module.instruction_memory[17] <= 32'h84180003;  // lh $t8, 3($0)
    mips.IF_Stage_Module.instruction_memory[18] <= 32'h94190003;  // lhu $t9, 3($0)
    mips.IF_Stage_Module.instruction_memory[19] <= 32'h12C0FFE0;  // beq $s6, $0, -32
    mips.IF_Stage_Module.instruction_memory[20] <= 32'h0;  // nop
    mips.IF_Stage_Module.instruction_memory[21] <= 32'h0;  // nop
    mips.IF_Stage_Module.instruction_memory[22] <= 32'h0;  // nop

    cycle_counter <= 0;
    clk <= 1;
    forever begin
      #100 clk <= ~clk;
    end
  end

  // incrememnt cycle counter at each positive edge
  always @(posedge clk) cycle_counter <= cycle_counter + 1;

  // monitor the cycle counter
  initial begin
    $monitor("Cycle %d\n", cycle_counter,
             //--- PC Output ---//
             "PC At the End of Cycle =%h\n", MIPS_testbench.mips.IF_Stage_Module.PC,
             //--- END PC Output ---//
             //--- IF Stage Output ---//
             "IF/ID Stage Pipeline Register:\n", "PC+4=%h\n", MIPS_testbench.mips.ID_new_pc_value,
             "Instruction=%h\n", MIPS_testbench.mips.ID_instruction,
             //--- End IF Stage Output ---//
             "------------------------------------------------------------\n",
             //--- ID Stage Output ---//
             "ID/EX Stage Pipeline Register:\n", "Instruction[15:11]=%h\n",
             MIPS_testbench.mips.EX_instr_bits_15_11, "Instruction[20:16]=%h\n",
             MIPS_testbench.mips.EX_instr_bits_20_16, "Extended Bits=%h\n",
             MIPS_testbench.mips.EX_extended_bits, "Read Data 1 (Decimal)=%d\n",
             MIPS_testbench.mips.EX_read_data1, "Read Data 2 (Decimal)=%d\n",
             MIPS_testbench.mips.EX_read_data2, "PC + 4=%h\n", MIPS_testbench.mips.EX_new_pc_value,
             "RegDst=%b\n", MIPS_testbench.mips.EX_RegDst, "RegWrite=%b\n",
             MIPS_testbench.mips.EX_RegWrite, "ALUSrc=%b\n", MIPS_testbench.mips.EX_ALUSrc,
             "MemWrite=%b\n", MIPS_testbench.mips.EX_MemWrite, "MemRead=%b\n",
             MIPS_testbench.mips.EX_MemRead, "MemToReg=%b\n", MIPS_testbench.mips.EX_MemToReg,
             "Branch=%b\n", MIPS_testbench.mips.EX_branch, "Load Mode=%h\n",
             MIPS_testbench.mips.EX_load_mode, "ALUOp=%h\n", MIPS_testbench.mips.EX_ALUOp,
             //--- End ID Stage Output ---//
             "------------------------------------------------------------\n",
             //--- EX Stage Output ---//
             "EX/MEM Stage Pipeline Register:\n", "RegWrite=%b\n",
             MIPS_testbench.mips.MEM_reg_write, "MemWrite=%b\n", MIPS_testbench.mips.MEM_mem_write,
             "MemRead=%b\n", MIPS_testbench.mips.MEM_mem_read, "MemToReg=%b\n",
             MIPS_testbench.mips.MEM_mem_to_reg, "PC Branch Address=%h\n",
             MIPS_testbench.mips.IF_branch_address, "Zero=%b\n", MIPS_testbench.mips.MEM_zero,
             "ALU Result/Address (decimal) = %d\n", MIPS_testbench.mips.MEM_address,
             "Write Data (decimal) = %d\n", MIPS_testbench.mips.MEM_write_data,
             "Writeback Destination=%h\n", MIPS_testbench.mips.MEM_write_back_destination,
             "Load Mode = %h\n", MIPS_testbench.mips.MEM_load_mode, "Branch=%b\n",
             MIPS_testbench.mips.MEM_branch,
             //--- End EX Stage Output ---//
             "------------------------------------------------------------\n",
             //--- MEM Stage Output ---//
             "MEM/WB Stage Pipeline Register:\n", "Writeback Destination=%h\n",
             MIPS_testbench.mips.WB_write_back_destination, "RegWrite=%b\n",
             MIPS_testbench.mips.WB_reg_write, "Read Data (decimal) = %d\n",
             MIPS_testbench.mips.WB_read_data, "AluResult (decimal) = %d\n",
             MIPS_testbench.mips.WB_address, "MemToReg = %b\n", MIPS_testbench.mips.WB_mem_to_reg,
             //--- End MEM Stage Output ---//
             "------------------------------------------------------------\n",
             "Register File At the End of Cycle: %p\n",
             MIPS_testbench.mips.ID_Stage_Module.Registers.registers,
             "==============================================================\n",
             "==============================================================");
  end

  // stop after program ends
  // expected register file:
  // {ra: 0, fp:0, sp:4000, gp:0,k1:0, k0:0,t9 lhu:65280,t8 lh:4294967040,s7:0,s6:1,s5:2,s4:20,s3:7,s2:5,s1:2,
  //  s0:12,t7:4095,t6:4095,t5:7,t4:1,t3:42967276,t2:7,t1:5,t0:0,a3:0,a2:0,a1:0,a0:0,v1:0,v2:0,zero:0}
  initial begin
    #5000 $display("Register File: %p", MIPS_testbench.mips.ID_Stage_Module.Registers.registers);
    $display("Data Memory (Bytes): %p", MIPS_testbench.mips.MEM_Stage_Module.mem_ram.ram);
    $stop;
  end


endmodule
