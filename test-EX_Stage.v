module EX_Stage_testbench ();

  reg clk, in_RegDst, in_RegWrite, in_ALUSrc, in_MemWrite, in_MemRead, in_MemToReg;
  reg [1:0] in_load_mode;
  reg [2:0] in_ALUOp;
  reg [4:0] in_instr_bits_15_11, in_instr_bits_20_16;
  reg [31:0] in_extended_bits, in_read_data1, in_read_data2, in_new_pc_value;

  wire zero_out, RegWrite_out, MemWrite_out, MemRead_out, MemToReg_out;
  wire [1:0] load_mode_out;
  wire [4:0] writebackDestination_out;
  wire [31:0] aluResult_out, rt_out, pc_out;

  EX_Stage myStage (
      clk,
      in_RegDst,
      in_RegWrite,
      in_ALUSrc,
      in_MemWrite,
      in_MemRead,
      in_MemToReg,
      in_ALUOp,
      in_instr_bits_15_11,
      in_instr_bits_20_16,
      in_extended_bits,
      in_read_data1,
      in_read_data2,
      in_new_pc_value,
      in_load_mode,
      zero_out,
      RegWrite_out,
      MemWrite_out,
      MemRead_out,
      MemToReg_out,
      load_mode_out,
      writebackDestination_out,
      aluResult_out,
      rt_out,
      pc_out
  );

  always #1000 clk = ~clk;

  initial
    // $monitor("time=%d, in_MemWrite=%d, MemWrite_out=%d, in_MemRead=%d, MemRead_out=%d",
    $monitor(
        "time=%d,in_RegDst=%d, in_RegWrite=%d, in_ALUSrc=%d, in_MemWrite=%d, in_MemRead=%d, in_MemToReg=%d, ",
        "in_ALUOp=%d, in_instr_bits_15_11=%d, in_instr_bits_20_16=%d, in_extended_bits=%d, in_read_data1=%d, ",
        "in_read_data2=%d, in_new_pc_value=%d, in_load_mode=%d, ",
        "zero_out=%d, RegWrite_out=%d, MemWrite_out=%d, MemRead_out=%d, MemToReg_out=%d,load_mode_out=%d, ",
        "writebackDestination_out=%d, aluResult_out=%d, rt_out=%d pc_out=%d",
        $time,
        in_RegDst,
        in_RegWrite,
        in_ALUSrc,
        in_MemWrite,
        in_MemRead,
        in_MemToReg,
        in_ALUOp,
        in_instr_bits_15_11,
        in_instr_bits_20_16,
        in_extended_bits,
        in_read_data1,
        in_read_data2,
        in_new_pc_value,
        in_load_mode,
        zero_out,
        RegWrite_out,
        MemWrite_out,
        MemRead_out,
        MemToReg_out,
        load_mode_out,
        writebackDestination_out,
        aluResult_out,
        rt_out,
        pc_out
    );
  // $time, in_MemWrite, MemWrite_out,in_MemRead,MemRead_out);
  initial begin
    clk = 1;
    // add
    #2000 in_MemWrite = 0;
    in_MemRead = 1;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 7;
    in_ALUOp = 3'b100;
    in_extended_bits = 32;
    #2000 in_MemWrite = 1;
    in_MemRead = 1;
    in_load_mode = 1;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 8;
    in_ALUOp = 3'b100;
    in_extended_bits = 32;
    #2000 in_MemWrite = 0;
    in_MemRead = 0;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 7;
    in_ALUOp = 3'b100;
    in_extended_bits = 32;
    #2000 in_MemWrite = 1;
    in_MemRead = 1;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 8;
    in_ALUOp = 3'b100;
    in_extended_bits = 32;
    #2000 in_MemWrite = 0;
    in_MemRead = 0;
    in_load_mode = 2;
    in_MemToReg = 1;
    in_read_data1 = 7;
    in_read_data2 = 7;
    in_ALUOp = 3'b100;
    in_extended_bits = 32;
    #2000 in_MemWrite = 1;
    in_MemRead = 1;
    in_load_mode = 2;
    in_MemToReg = 0;
    in_read_data1 = 7;
    in_read_data2 = 8;
    in_ALUOp = 3'b100;
    in_extended_bits = 32;
    #2000 $stop;
  end



endmodule
