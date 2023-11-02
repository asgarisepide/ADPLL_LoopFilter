`timescale 1ns/10ps
`include "LoopFilter_1.v"

module LoopFilter_tb;
  reg clk;
  reg reset;
  reg early;
  reg [1:0] sel;
  reg signed [4:0] plusInt;
  reg signed [4:0] minusInt;
  reg [4:0] plusProp;
  reg [4:0] plusPropDiff;
  reg [4:0] minusProp;
  reg [4:0] minusPropDiff;
  wire overflow;
  wire underflow;
  wire OverflowP;
  wire UnderflowP;
  
  wire [4:0] mux2to1_out;  
  wire [4:0] INT_OUT;
  wire [4:0] Fractional_Frequency;

 LoopFilter_1 dut (
    .clk(clk),
    .reset(reset),
    .early(early),
    .sel(sel),
    .INT_OUT(INT_OUT),
    .plusInt(plusInt),
    .minusInt(minusInt),
    .plusProp(plusProp),
    .plusPropDiff(plusPropDiff),
    .minusProp(minusProp),
    .minusPropDiff(minusPropDiff),
    .Fractional_Frequency(Fractional_Frequency),
    .OverflowP(OverflowP),
    .UnderflowP(UnderflowP),
    .overflow(overflow),
    .underflow(underflow)
  );

  initial begin
   $dumpfile("LF_1.vcd");
   $dumpvars;

   
    // Initialize inputs
    plusInt  = 5'b00111;     // Example input values
    minusInt = 5'b11001;
    clk = 0;
    reset = 0;
    early = 0;
    sel = 2'b00;             // Initial select value
    plusProp = 5'b11010;     // Example input values
    plusPropDiff = 5'b01101;
    minusProp = 5'b10110;
    minusPropDiff = 5'b10011;


    // Apply reset
    reset = 1;
    #10 reset = 0;

    // Test case 1: Early condition, expect overflow
    early = 1;
    sel = 2'b01;
    #10 early = 0;
        sel = 2'b01;
    // Wait for overflow
    #20;
      
    // Test case 2: Late condition, expect underflow
    early = 0;
    sel = 2'b00;
    #10 early = 1;
  
    // Wait for underflow
    #20;

    // Test case 3: No overflow or underflow
    early = 1;

    #10 early = 1;
   
    // Wait for stability
    #400;
    
    // Test case 4: No overflow or underflow
    early = 0;

    #10 early = 0;
        sel = 2'b01;
    // Wait for stability
    #400;

    // Terminate simulation
    $finish;
  end

  // Clock generation
  always begin
    #5 clk = ~clk;
  end
endmodule

