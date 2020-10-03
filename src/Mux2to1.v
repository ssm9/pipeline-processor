module Mux2to1(data_in0, data_in1, sel, data_out);
	parameter BIT_WIDTH = 32;

	input [BIT_WIDTH - 1 : 0] data_in0;
	input [BIT_WIDTH - 1 : 0] data_in1;
	input [1 : 0] sel;

	output [BIT_WIDTH - 1 : 0] data_out;

	assign data_out = (sel == 0) ? data_in0 : data_in1;


endmodule