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
