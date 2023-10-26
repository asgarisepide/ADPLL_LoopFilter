module INT (
  input wire clk,     // Clock signal
  input wire reset,   // Reset signal
  input wire early,   // Early signal from PFD
  output reg [4:0] INT_OUT,
  output reg overflow,
  output reg underflow
);

  reg [4:0] integral = 5'b0;    // 5-bit accumulator
  reg [3:0] plusInt  = 4'b0010; // 4-bit +Int constant
  reg [3:0] minusInt = 4'b1010; // 4-bit -Int constant
 

  always @(posedge clk or posedge reset) begin
    
    overflow  <= 0;
    underflow <= 0;
    
    if (reset) begin           //integral <= (early) ? (integral + 1) * plusInt : (integral - 1) * minusInt;
      integral  <= 5'b0;       // Reset the accumulator to zero
      overflow  <= 0;
      underflow <= 0;
    end else if (early) begin
      if (integral < 5'b11111) begin       
       overflow  <= 1;     // overflow condition
       underflow <= 0;
       integral  <= integral + 1; // // Increment the accumulator for early condition
       INT_OUT   <= plusInt * integral;

      end else begin   // if (integral > 5'b11111), again overflow condition
          overflow <= 1;
	  INT_OUT   <= plusInt * integral; // integral = 5'b11111
          //integral <= 5'b00000;
	end
      end
    if (early != 1) begin
      if (integral > 5'b00000) begin
	  overflow  <= 0;
	  underflow <= 1;
	  integral  <= integral - 1;  // Decrement the accumulator for late condition
	  INT_OUT   <= minusInt * integral;
       end else begin    //if (integral < 5'b00000), again underflow condition
	  underflow <= 1;
	  INT_OUT   <= minusInt * integral; // integral = 5'b00000
	  //integral <= 5'b00000;
    end
   end
  end
    
endmodule
