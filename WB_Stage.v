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
