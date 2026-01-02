module IF_Sel_TB ();

  reg clk;
  reg [31:0] MUX_OPT_0, MUX_OPT_1;
  reg PCSrc;
  wire [31:0] NEXT_INS_ADR, CUR_INS;

  initial begin
    clk = 1;
    MUX_OPT_0 = 50;
    MUX_OPT_1 = 100;
    PCSrc = 0;
  end

  initial repeat (16) #10 clk <= ~clk;

  IF_Sel IF_Sel_Module (
      clk,
      MUX_OPT_0,
      MUX_OPT_1,
      PCSrc,
      NEXT_INS_ADR,
      CUR_INS
  );

  always @(posedge clk) begin
    $display(
        "time=%d, MUX_OPT_0=%d, MUX_OPT_1=%d, PCSrc=%d, NEXT_INS_ADR=%d, CUR_INS=%d, PC Var=%d",
        $time, MUX_OPT_0, MUX_OPT_1, PCSrc, NEXT_INS_ADR, CUR_INS, IF_Sel_Module.PC);
  end

  initial begin
    #20 PCSrc = 1;
    #40 $finish;
  end

endmodule
