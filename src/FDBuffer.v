module FDBuffer(clk,
				reset,
				wrtEn,

				//input data
				incPC_F,
				instWord_F,

				//output data
				incPC_D,
				instWord_D,

				noop_F,
				noop_D);
				
	parameter DBITS = 32;
	parameter RESETVAL = 32'b0010_0011_0000_0000_0000_0000_0000_0000;

	input noop_F;
	output reg noop_D;

	input clk, reset, wrtEn;

	//Data
	input [DBITS - 1 : 0] incPC_F;
	output reg [DBITS - 1 : 0] incPC_D;

	input [DBITS - 1 : 0] instWord_F;
	output reg [DBITS - 1 : 0] instWord_D;

	always @(posedge clk) begin
		if(reset) begin
			instWord_D = RESETVAL;
			noop_D <= 1'b1;
		end
		else if(wrtEn) begin
			incPC_D <= incPC_F;
			instWord_D <= instWord_F;

			//new additions
			noop_D <= noop_F;
		end
	end
endmodule