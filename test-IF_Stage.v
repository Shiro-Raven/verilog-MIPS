module IF_Stage_TB ();

  reg CLK;
  reg [31:0] MUX_OPT_0, MUX_OPT_1;
  reg MEM_WRITE;
  wire [31:0] NEXT_INS_ADR_OUT, CUR_INS_OUT;

  IF_Stage IF_Stage_Module (
      CLK,
      MUX_OPT_0,
      MUX_OPT_1,
      MEM_WRITE,
      NEXT_INS_ADR_OUT,
      CUR_INS_OUT
  );

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  initial
    $monitor(
        "time=%d, CLK=%d, MUX_OPT_0=%d, MUX_OPT_1=%d, MEM_WRITE=%d, NEXT_INS_ADR=%d, CUR_INS=%d",
        $time,
        CLK,
        MUX_OPT_0,
        MUX_OPT_1,
        MEM_WRITE,
        NEXT_INS_ADR_OUT,
        CUR_INS_OUT
    );

  initial begin
    #10 MEM_WRITE = 0;
    #10 MUX_OPT_0 = 50;
    #10 MUX_OPT_1 = 100;
    #10 MEM_WRITE = 1;
    #10 $finish;
  end

endmodule
