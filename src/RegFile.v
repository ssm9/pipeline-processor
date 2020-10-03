module RegFile (r_addr1, d_out1, r_addr2, d_out2, w_addr, d_in, wrt_en, clk);
	parameter DATA_BITS = 32;
	parameter ADDRESS_BITS = 4;
	parameter WORDS = (1 << ADDRESS_BITS);

	//16 x 32-bit regs
	reg [(DATA_BITS - 1) : 0] mem [(WORDS - 1) : 0];

	input clk;

	//Read reg 1
	input [ADDRESS_BITS - 1 : 0] r_addr1;
	output wire [DATA_BITS - 1 : 0] d_out1;

	//Read reg 2
	input [ADDRESS_BITS - 1 : 0] r_addr2;
	output [DATA_BITS - 1 : 0] d_out2;

	//Write reg
	input [ADDRESS_BITS - 1 : 0] w_addr;
	input [DATA_BITS - 1 : 0] d_in;
	input wrt_en;

	always @ (posedge clk) begin
		if (wrt_en)
			mem[w_addr] = d_in;
	end

	assign d_out1 = mem[r_addr1];
	assign d_out2 = mem[r_addr2];

endmodule