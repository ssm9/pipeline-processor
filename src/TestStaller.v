`define     LW_TS      4'b0111
`define     SW_TS      4'b0011
`define     BCOND_TS   4'b0010
`define     JAL_TS     4'b0110

module TestStaller();
	parameter REGBITS = 4;

	reg [REGBITS - 1 : 0] op_D;
	reg [REGBITS - 1 : 0] op_E;
	wire noop;

	wire full_noop;
	reg clk;
	
	Staller stall(op_D, op_E, noop, full_noop, clk);
	
	initial begin
		#10
		op_D = `LW_TS;
		op_E = 4'b0000;
		//noop = 1;
		
		#10
		op_D = 4'b0000;
		op_E = `LW_TS;
		//noop = 0;
		
		#10
		op_D = `SW_TS;
		op_E = 4'b0000;
		//noop = 1;
		
		#10
		op_D = 4'b0000;
		op_E = `SW_TS;
		//noop = 0;
		
		#10
		op_D = `BCOND_TS;
		op_E = 4'b0000;
		//noop = 1;
		
		#10
		op_D = 4'b0000;
		op_E = `BCOND_TS;
		//noop = 1;
		
		#10
		op_D = `JAL_TS;
		op_E = 4'b0000;
		//noop = 1;
		
		#10
		op_D = 4'b0000;
		op_E = `JAL_TS;
		//noop = 1;
		
		#10
		op_D = 4'b0000;
		op_E = 4'b0000;
		//noop = 0;
		
		#10
		$stop;
	end
endmodule