module MWBuffer(
	clk,
	reset,
	wrt_en,

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

	//new additions
	noop_M,
	noop_W
	// pc_sel_M,
	// pc_sel_W,
	);

	parameter DBITS = 32;
	parameter REGNO = 4;
	parameter OPNO = 4;

	//new additions
	input noop_M;
	output reg noop_W;
	// input[1:0] pc_sel_M;
	// output reg[1:0] pc_sel_W;

	input clk, reset, wrt_en;

	input [DBITS - 1 : 0] incPC_M, ALUresult_M, MEMresult_M;
	output reg [DBITS - 1 : 0] incPC_W, ALUresult_W, MEMresult_W;

	input [OPNO - 1 : 0] i_op_M;
	output reg [OPNO - 1 : 0] i_op_W;

	input [REGNO - 1 : 0] src1Index_M, src2Index_M, destIndex_M;
	output reg [REGNO - 1 : 0] src1Index_W, src2Index_W, destIndex_W;

	input regWrtEn_M; 
	output reg regWrtEn_W; 

	input [1 : 0] regFileMux_M;
	output reg [1 : 0] regFileMux_W;

	always @(posedge clk) begin
		//MIGHT NEED TO CHANGE
		if (reset) begin
			// memWrtEn_W <= 1'b0;
			regWrtEn_W <= 1'b0;
		end		

		else if (wrt_en) begin
			incPC_W <= incPC_M;
			ALUresult_W <= ALUresult_M;
			MEMresult_W <= MEMresult_M;

			i_op_W <= i_op_M;

			src1Index_W <= src1Index_M;
			src2Index_W <= src2Index_M;
			destIndex_W <= destIndex_M;

			regWrtEn_W <= regWrtEn_M;

			regFileMux_W <= regFileMux_M;

			//new addtions
			noop_W <= noop_M;
			// pc_sel_W <= pc_sel_M;
		end
	end
endmodule