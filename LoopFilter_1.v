// Programmable discrete time PID filter for ADPLL

module LoopFilter_1 (
  input wire clk,       // Clock signal
  input wire reset,     // Reset signal
  input wire early,     // Early signal from PFD
  input wire [1:0] sel,
  input wire signed [4:0] plusInt,
  input wire signed [4:0] minusInt,
  input wire [4:0] plusProp,
  input wire [4:0] plusPropDiff,
  input wire [4:0] minusProp,
  input wire [4:0] minusPropDiff,
  output reg [4:0] INT_OUT,
  output reg [4:0] Fractional_Frequency,
  output reg OverflowP,
  output reg UnderflowP,
  output reg overflow,
  output reg underflow
);

  //logic [4:0] plusInt;
  //logic [4:0] minusInt;
  logic [4:0] mux2to1_out;
  logic [4:0] mux4to1_out;

  reg [5:0] integral = 6'b0;    // 5-bit accumulator
 // reg [5:0] integ = 5'b0;               // 5-bit int accumulator


MuxInt #(5) MuxInt(
   .sel(sel),
   .plusProp(plusProp),
   .plusPropDiff(plusPropDiff),
   .minusProp(minusProp),
   .minusPropDiff(minusPropDiff),
   .mux4to1_out(mux4to1_out)
);



Mux_1 #(5) Mux2to1(
   .early    (early),
   .plusInt  (plusInt),
   .minusInt (minusInt),
   .mux2to1_out (mux2to1_out)
);


vc_Adder #(.p_nbits(5)) adder (
   .in0(mux4to1_out),
   .in1(INT_OUT),
   .out(Fractional_Frequency),
   .cout_1(OverflowP),
   .cout_2(UnderflowP)
);

//assign overflow = (mux2to1_out[5] && INT_OUT[5] && ~INT_OUT[5])| (~mux2to1_out[5] && ~INT_OUT[5] && INT_OUT[5]);

always @(posedge clk or posedge reset) begin
    overflow  <= 0;
    underflow <= 0;
    INT_OUT   <= 0;
    
    if (reset) begin
      integral  <= 6'b0;       // Reset the accumulator to zero     
      overflow  <= 0;
      underflow <= 0;

    end else if (early) begin
        integral  <= INT_OUT + mux2to1_out;
        INT_OUT   <= integral[4:0];  
       if (integral[5]==1)begin    
        overflow  <= 1;     
        underflow <= 0;

        end
    end else begin
        integral  <= INT_OUT + mux2to1_out;
        INT_OUT   <= integral[4:0];  
       if (integral[5]==0)begin    
        overflow  <= 0;     
        underflow <= 1;
        end
    end
    end
endmodule
//------------------------------------------------------------------------
// Mux_1
//------------------------------------------------------------------------


module Mux_1(

  input wire  early,         // 2-bit select signal (early, early_ff)
  input wire [4:0] plusInt,      // 5-bit input data
  input wire [4:0] minusInt,    
  output reg [4:0] mux2to1_out           // Output
);

vc_Mux2 #(.p_nbits(5)) mux2to1 (

  .sel (early),
  .in0 (minusInt), 
  .in1 (plusInt),
  .out (mux2to1_out)
);

endmodule



//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux2
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] in0, in1,
  input                    sel,
  output reg [p_nbits-1:0] out
);

  always @(*)
  begin
    case ( sel )
      1'd0 : out = in0;
      1'd1 : out = in1;
      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule




//------------------------------------------------------------------------
// MuxInt
//------------------------------------------------------------------------


module MuxInt(
  input wire [1:0] sel,         // 2-bit select signal (early, early_ff)
  input wire [4:0] plusProp,      // 5-bit input data
  input wire [4:0] plusPropDiff,    
  input wire [4:0] minusProp,    
  input wire [4:0] minusPropDiff, 
  output reg [4:0] mux4to1_out           // Output
);



vc_Mux4 #(.p_nbits(5)) mux4to1 (

      .sel (sel),
      .in0 (plusProp),
      .in1 (plusPropDiff),
      .in2 (minusProp),
      .in3 (minusPropDiff),
      .out (mux4to1_out)
);


  //assign sel[0] = early;
  //assign sel[1] = early;

endmodule
//------------------------------------------------------------------------
// 4 Input Mux
//------------------------------------------------------------------------

module vc_Mux4
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] in0, in1, in2, in3,
  input              [1:0] sel,
  output reg [p_nbits-1:0] out
);

  always @(*)
  begin
    case ( sel )
      2'd0 : out = in0;
      2'd1 : out = in1;
      2'd2 : out = in2;
      2'd3 : out = in3;
      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule







//------------------------------------------------------------------------
// Adders
//------------------------------------------------------------------------

module vc_Adder
#(
  parameter p_nbits = 1
)(
  input  [p_nbits-1:0] in0,
  input  [p_nbits-1:0] in1,
  output [p_nbits-1:0] out,
  output               cout_1,
  output               cout_2
);

  assign {cout_1,out} = in0 + in1;
  assign cout_2 = ~cout_1;
endmodule







