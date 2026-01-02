// extended_bits refer to the ouput of the extender
module ID_Register_File (
    // Input
    input clk,
    input [31:0] instruction,
    input [31:0] write_data,
    input [4:0] write_register,
    input RegWrite,
    // Output
    output [31:0] read_data1,
    output [31:0] read_data2,
    output [31:0] extended_bits
);

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
