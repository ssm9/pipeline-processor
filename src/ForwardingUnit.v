module ForwardingUnit(
		//destination addresses for regfile
		// dest_D,
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
		
		//noop?
		noop_E, noop_M, noop_W,
		
		//wrtens
		wrt_en_E, wrt_en_M, wrt_en_W
	);

	parameter REGNO_SEL = 4;
	parameter MUX_SEL = 2;

	input [REGNO_SEL-1 : 0] dest_E, dest_M, dest_W, src1_D, src2_D;
	input noop_E, noop_M, noop_W;
	input wrt_en_E, wrt_en_M, wrt_en_W;

	output reg [MUX_SEL-1 : 0] src1_sel_D, src2_sel_D;
	always @(*) begin
// 		if(!noop) begin
			if (src1_D == dest_E && !noop_E && wrt_en_E) begin
				src1_sel_D = 2'd1;
			end
			else if (src1_D == dest_M && !noop_M && wrt_en_M) begin
				src1_sel_D = 2'd2;
			end
			else if (src1_D == dest_W && !noop_W && wrt_en_W) begin
				src1_sel_D = 2'd3;
			end
			else begin
				src1_sel_D = 2'd0;
			end

			if (src2_D == dest_E && !noop_E && wrt_en_E) begin
				src2_sel_D = 2'd1;
			end
			else if (src2_D == dest_M && !noop_M && wrt_en_M) begin
				src2_sel_D = 2'd2;
			end
			else if (src2_D == dest_W && !noop_W && wrt_en_W) begin
				src2_sel_D = 2'd3;
			end
			else begin
				src2_sel_D = 2'd0;
			end
// 		end
// 		else begin
// 			src1_sel_D = 2'd0;
// 			src2_sel_D = 2'd0;
// 		end
			
	end
endmodule