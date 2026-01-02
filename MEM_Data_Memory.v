module MEM_Data_Memory (
    output reg [31:0] read_data,
    input mem_write,
    input mem_read,
    input [1:0] load_mode,
    input [31:0] address,
    input [31:0] write_data
);
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
