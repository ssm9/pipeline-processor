module DEBuffer(clk, 
				reset, 
				wrtEn,

				//input data
				incPC_D,
				src1Index_D,
				src1Data_D,
				src2Index_D,
				src2Data_D,
				destIndex_D,
				signExtImm_D,
				opCode_D,

				//input signals
				aluOp_D,
				src2Mux_D,
				regFileMux_D,
				memWrtEn_D,
				regWrtEn_D,

				//output data
				incPC_E,
				src1Index_E,
				src1Data_E,
				src2Index_E,
				src2Data_E,
				destIndex_E,
				signExtImm_E,
				opCode_E,

				//output signals
				aluOp_E,
				src2Mux_E,
				regFileMux_E,
				memWrtEn_E,
				regWrtEn_E,

				//new additions
				noop_D,
				pc_sel_D,
				//new additions
				noop_E,
				pc_sel_E);

	parameter DBITS = 32;
	parameter REGBITS = 4;
	parameter OPBITS = 4;

	input noop_D;
	output reg noop_E;

	input[1:0] pc_sel_D;
	output reg[1:0] pc_sel_E;

	input clk, reset, wrtEn;

	//Data
	input [DBITS - 1 : 0] incPC_D, src1Data_D, src2Data_D, signExtImm_D;
	output reg [DBITS - 1 : 0] incPC_E, src1Data_E, src2Data_E, signExtImm_E;

	input [REGBITS - 1 : 0] src1Index_D, src2Index_D, destIndex_D;
	output reg [REGBITS - 1 : 0] src1Index_E, src2Index_E, destIndex_E;

	input [OPBITS - 1 : 0] opCode_D;
	output reg [OPBITS - 1 : 0] opCode_E; 

	//Signals
	input [4 : 0] aluOp_D;
	output reg [4 : 0] aluOp_E;

	input [1 : 0] src2Mux_D, regFileMux_D;
	output reg [1 : 0] src2Mux_E, regFileMux_E;

	input memWrtEn_D, regWrtEn_D;
	output reg memWrtEn_E, regWrtEn_E;

	always @(posedge clk) begin
		if(reset) begin
			memWrtEn_E <= 1'b0;
			regWrtEn_E <= 1'b0;
		end
		else if(wrtEn) begin
			//output assignments
			incPC_E <= incPC_D;
			src1Index_E <= src1Index_D;
			src1Data_E  <= src1Data_D;
			src2Index_E <= src2Index_D;
			src2Data_E <= src2Data_D;
			destIndex_E <= destIndex_D;
			signExtImm_E <= signExtImm_D;
			opCode_E <= opCode_D;

			//signal assignments
			aluOp_E <= aluOp_D;
			src2Mux_E <= src2Mux_D;
			regFileMux_E <= regFileMux_D;
			memWrtEn_E <= memWrtEn_D;
			regWrtEn_E <= regWrtEn_D;

			//new additions
			noop_E <= noop_D;
			pc_sel_E <= pc_sel_D;
		end
	end
endmodule