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
