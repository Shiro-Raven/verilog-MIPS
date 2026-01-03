module MIPS_testbench ();

  reg clk;
  integer cycle_counter;
  integer i;

  MIPS mips (clk);

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

  always @(posedge clk) cycle_counter <= cycle_counter + 1;

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
             "Register File At the End of Cycle:\n",
             "==============================================================\n",
             "==============================================================");
  end

  // Expected register file:
  // {ra: 0, fp:0, sp:4000, gp:0,k1:0, k0:0,t9 lhu:65280,t8 lh:4294967040,s7:0,s6:1,s5:2,s4:20,s3:7,s2:5,s1:2,
  //  s0:12,t7:4095,t6:4095,t5:7,t4:1,t3:42967276,t2:7,t1:5,t0:0,a3:0,a2:0,a1:0,a0:0,v1:0,v2:0,zero:0}
  initial begin
    #5000 begin
      $display("\n==============================================================");
      $display("Register File:");
      $display("==============================================================");
      for (i = 0; i < 32; i = i + 1) begin
        $display("Register[%2d] = %d (0x%h)", i,
                 MIPS_testbench.mips.ID_Stage_Module.Registers.registers[i],
                 MIPS_testbench.mips.ID_Stage_Module.Registers.registers[i]);
      end
      $display("\n==============================================================");
      $display("Data Memory (first 100 bytes):");
      $display("==============================================================");
      for (i = 0; i < 100; i = i + 1) begin
        if (i % 16 == 0) $write("\n[%4d] ", i);
        $write("%02h ", MIPS_testbench.mips.MEM_Stage_Module.mem_ram.ram[i]);
      end
      $display("\n");
      $finish;
    end
  end


endmodule
