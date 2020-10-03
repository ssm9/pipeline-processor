module TestMWBuffer();

	parameter DBITS = 32;
	parameter REGBITS = 4;
	parameter OPBITS = 4;

	reg clk = 1'b0;
	reg reset = 1'b0;
	reg wrtEn = 1'b0;
	
	reg noop_M;
	wire noop_W;

	reg [DBITS - 1 : 0] incPC_M, ALUresult_M, MEMresult_M;
	wire [DBITS - 1 : 0] incPC_W, ALUresult_W, MEMresult_W;

	reg [OPBITS - 1 : 0] i_op_M;
	wire [OPBITS - 1 : 0] i_op_W;

	reg [REGBITS - 1 : 0] src1Index_M, src2Index_M, destIndex_M;
	wire [REGBITS - 1 : 0] src1Index_W, src2Index_W, destIndex_W;

	reg regWrtEn_M; 
	wire regWrtEn_W; 

	reg [1 : 0] regFileMux_M;
	wire [1 : 0] regFileMux_W;

	always begin
        #500
        clk <= ~clk;
    end

	MWBuffer #(DBITS) mwbuf(clk,
							reset,
							wrtEn,

							//input data
							incPC_M,
							src1Index_M,
							src2Index_M,
							ALUresult_M,
							MEMresult_M,
							destIndex_M,
							i_op_M,
							
							//input signals
							regFileMux_M,
							regWrtEn_M,
							
							//output data
							incPC_W,
							src1Index_W,
							src2Index_W,
							ALUresult_W,
							MEMresult_W,
							destIndex_W,
							i_op_W,
							
							//output signals
							regFileMux_W,
							regWrtEn_W,
							
							//noop
							noop_M,
							noop_W);

	initial begin
		#1000
		incPC_M = 32'd1;
		src1Index_M = 4'd15;
		src2Index_M = 4'd14;
		ALUresult_M = 32'd999;
		MEMresult_M = 32'd777;
		destIndex_M = 4'd13;
		i_op_M = 4'd12;
		noop_M = 1'b1;
		
		regFileMux_M = 1'b1;
		regWrtEn_M = 1'b1;

		#1000
		wrtEn = 1'b1;

		#1000
		wrtEn = 1'b0;

		incPC_M = 32'd0;
		src1Index_M = 4'd0;
		src2Index_M = 4'd0;
		ALUresult_M = 32'd0;
		MEMresult_M = 32'd0;
		destIndex_M = 4'd0;
		i_op_M = 4'd0;
		noop_M = 1'b0;
		
		regFileMux_M = 1'b0;
		regWrtEn_M = 1'b0;

		#2000
		$stop;
	end

endmodule
