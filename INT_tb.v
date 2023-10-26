`timescale 1ns/10ps
`include "INT.v"

module INT_tb;
  reg clk;
  reg reset;
  reg early;

  wire overflow;
  wire underflow;
  
  wire [4:0] INT_OUT;

  INT dut (
    .clk(clk),
    .reset(reset),
    .early(early),
    .INT_OUT(INT_OUT),
    .overflow(overflow),
    .underflow(underflow)
  );

  initial begin
   $dumpfile("Integrator.vcd");
   $dumpvars;

   
    // Initialize inputs
    clk = 0;
    reset = 0;
    early = 0;
   
    // Apply reset
    reset = 1;
    #10 reset = 0;

    // Test case 1: Early condition, expect overflow
    early = 1;

    #10 early = 0;

    // Wait for overflow
    #20;

    // Test case 2: Late condition, expect underflow
    early = 0;

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

