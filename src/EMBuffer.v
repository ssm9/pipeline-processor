module EMBuffer(
	clk,
	reset,
	wrt_en,



	//input data
	incPC_E,
	src1Index_E,
	src2Index_E,
	ALUresult_E,
	src1Data_E,
	src2Data_E,
	destIndex_E,
	i_op_E,

	//input signals
	memWrtEn_E,
	regFileMux_E,
	regWrtEn_E,

	//ouput data
	incPC_M,
	src1Index_M,
	src2Index_M,
	ALUresult_M,
	src1Data_M,
	src2Data_M,
	destIndex_M,
	i_op_M,

	//output signals
	memWrtEn_M,
	regFileMux_M,
	regWrtEn_M,

	noop_E,
	noop_M,
	pc_sel_E,
	pc_sel_M,
	cond_flag_E,
	cond_flag_M,
	signExtImm_E,
	signExtImm_M
	);
	
	parameter DBITS = 32;
	parameter REGNO = 4;
	parameter OPNO = 4;

	//new additions
	input noop_E;
	output reg noop_M;
	input[1:0] pc_sel_E;
	output reg[1:0] pc_sel_M;
	input cond_flag_E;
	output reg cond_flag_M;
	input [31:0] signExtImm_E;
	output reg [31:0] signExtImm_M;

	input clk, reset, wrt_en;

	input [DBITS - 1 : 0] incPC_E, ALUresult_E, src1Data_E, src2Data_E;
	output reg [DBITS - 1 : 0] incPC_M, ALUresult_M, src1Data_M, src2Data_M;

	input [OPNO - 1 : 0] i_op_E;
	output reg [OPNO - 1 : 0] i_op_M;

	input [REGNO - 1 : 0] src1Index_E, src2Index_E, destIndex_E;
	output reg [REGNO - 1 : 0] src1Index_M, src2Index_M, destIndex_M;

	input memWrtEn_E, regWrtEn_E;
	output reg memWrtEn_M, regWrtEn_M;

	input [1 : 0] regFileMux_E;
	output reg [1 : 0] regFileMux_M;

	always @(posedge clk) begin
		//MIGHT NEED TO CHANGE
		if (reset) begin
			memWrtEn_M <= 1'b0;
			regWrtEn_M <= 1'b0;
		end

		else if (wrt_en) begin
			incPC_M <= incPC_E;
			ALUresult_M <= ALUresult_E;
			src1Data_M <= src1Data_E;
			src2Data_M <= src2Data_E;

			i_op_M <= i_op_E;

			src1Index_M <= src1Index_E;
			src2Index_M <= src2Index_E;
			destIndex_M <= destIndex_E;

			memWrtEn_M <= memWrtEn_E;
			regWrtEn_M <= regWrtEn_E;

			regFileMux_M <= regFileMux_E;

			//new addtions
			noop_M <= noop_E;
			pc_sel_M <= pc_sel_E;
			cond_flag_M <= cond_flag_E;
			signExtImm_M <= signExtImm_E;
		end
	end
endmodule