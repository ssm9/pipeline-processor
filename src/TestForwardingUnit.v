module TestForwardingUnit();
	parameter REGBITS = 4;
	parameter MUXBITS = 2;

	reg [REGBITS - 1 : 0] dest_E;
	reg [REGBITS - 1 : 0] dest_M;
	reg [REGBITS - 1 : 0] dest_W;
	reg [REGBITS - 1 : 0] src1_D;
	reg [REGBITS - 1 : 0] src2_D;
	reg noop_E;
	reg noop_M;
	reg noop_W;
	reg wrt_en_E;
	reg wrt_en_M;
	reg wrt_en_W;


	//0 = regfile, 1 = exec, 2 = mem, 3 = write back
	wire [MUXBITS - 1 : 0] src1_sel_D;
	wire [MUXBITS - 1 : 0] src2_sel_D;

	ForwardingUnit #(REGBITS, MUXBITS) fUnit(
		//destination addresses for regfile
		dest_E,
		dest_M,
		dest_W,

		//source 1 addresses for regfile
		src1_D,

		//source 2 addresses for regfile
		src2_D,

		//ouput selects
		src1_sel_D,
		src2_sel_D,
		
		//noop
		noop_E,
		noop_M,
		noop_W,
		
		//wrtens
		wrt_en_E,
		wrt_en_M,
		wrt_en_W);

		initial begin
			#10
			src1_D = 4'd4;
			src2_D = 4'd5;
			noop_E = 1'b0;
			noop_M = 1'b0;
			noop_W = 1'b0;
			wrt_en_E = 1'b1;
			wrt_en_M = 1'b1;
			wrt_en_W = 1'b1;

			//no forwarding
			#10
			dest_E = 4'd7;
			dest_M = 4'd9;
			dest_W = 4'd2;

			//single forwardable value
			//forward from mem to src1
			#10
			dest_M = 4'd4;	//src1_sel_D = 2, src2_sel_D = 0

			//forward from mem to src1 and from exec to src2
			#10
			dest_E = 4'd5;	//src2_sel_D = 1, src1_sel_D = 2

			//forward from wb to src1 and from mem to src2
			#10
			dest_E = 4'd1;	
			dest_M = 4'd5;	//src2_sel_D = 2
			dest_W = 4'd4;	//src1_sel_D = 3

			//multiple forwardable values
			//forward from mem over wb to src1
			#10
			dest_E = 4'd0;	
			dest_M = 4'd4;	
			dest_W = 4'd4;	//src1_sel_D = 2, src2_sel_D = 0

			//forward from exec over wb to src1
			#10
			dest_E = 4'd4;	
			dest_M = 4'b0;	
			dest_W = 4'd4;	//src1_sel_D = 1, src2_sel_D = 0

			//forward from exec over mem to src1
			#10
			dest_E = 4'd4;	
			dest_M = 4'd4;	
			dest_W = 4'd0;	//src1_sel_D = 2, src2_sel_D = 0
			noop_E = 1'b1;
			noop_M = 1'b0;
			noop_W = 1'b0;

			//forward from exec over mem and wb to src1
			#10
			dest_E = 4'd4;	
			dest_M = 4'd4;	
			dest_W = 4'd4;	//src1_sel_D = 2, src2_sel_D = 0
			noop_E = 1'b1;
			noop_M = 1'b1;
			noop_W = 1'b1;
			#10
			$stop;
		end

endmodule