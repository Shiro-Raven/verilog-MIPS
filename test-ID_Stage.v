module _ID_Stage_testbench ();

  reg clk;
  reg [5:0] write_register;
  reg [31:0] write_data;
  reg in_RegWrite;
  reg [1:0] in_load_mode;
  reg [31:0] instruction;
  reg [31:0] in_new_pc_value;
  reg [31:0] registers_input;

  wire [4:0] instr_bits_15_11;
  wire [4:0] instr_bits_20_16;
  wire [31:0] extended_bits;
  wire [31:0] read_data1;
  wire [31:0] read_data2;
  wire [31:0] new_pc_value;
  wire RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch;
  wire [1:0] load_mode;
  wire [2:0] ALUOp;

  ID_Stage my_damn_stage (
      clk,
      write_register,
      write_data,
      in_RegWrite,
      in_load_mode,
      instruction,
      in_new_pc_value,
      registers_input,
      instr_bits_15_11,
      instr_bits_20_16,
      extended_bits,
      read_data1,
      read_data2,
      new_pc_value,
      RegDst,
      RegWrite,
      ALUSrc,
      MemWrite,
      MemRead,
      MemToReg,
      Branch,
      load_mode,
      ALUOp
  );

  initial clk = 1;
  always #1000 clk <= ~clk;

  initial begin
    $monitor("time=%d, instruction=%b, read_data1=%d ", $time, instruction, read_data1);
  end

  initial begin
    #2000 instruction = 32'b00000000001000010000100000000000;  //add 1 1 1
    #2000 instruction = 32'b00000000010000100001000000000000;  //add 2 2 2
    #2000 instruction = 32'b00000000011000110001100000000000;  //add 3 3 3
    #2000 $stop;
  end

endmodule
