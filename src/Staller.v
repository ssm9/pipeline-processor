`define     LW_S      4'b0111
`define     SW_S      4'b0011
`define     BCOND_S   4'b0010
`define     JAL_S     4'b0110

module Staller(op_D, op_E, noop, full_noop, clk);
	parameter OPBITS = 4;
	
	input [OPBITS - 1 : 0] op_D;
	input [OPBITS - 1 : 0] op_E;
	output reg noop = 0;	
	
	always @(*) begin
		if(op_D == `LW_S || op_D == `SW_S || op_D == `BCOND_S || op_D == `JAL_S)
			noop = 1'b1;
		else if(op_E == `BCOND_S || op_E == `JAL_S)
			noop = 1'b1;
		else
			noop = 1'b0;
	end
	
	
	//testing "single cycle"
	input clk;
	output reg full_noop = 1;
	reg [2:0] count = 3'd5;
	always @(posedge clk) begin
		if(count == 0) begin
			full_noop <= 0;
			count <= 3'd5;
		end
		else begin
			full_noop <= 1;
			count <= count - 3'd1;
		end
			
			
	end

endmodule