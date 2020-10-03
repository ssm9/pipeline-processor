module TestEMBuffer();

	parameter DBITS = 32;
	parameter REGBITS = 4;
	parameter OPBITS = 4;

	reg clk = 1'b0;
	reg reset = 1'b0;
	reg wrtEn = 1'b0;
	
	reg noop_E;
	wire noop_M;
	
	reg [1:0] pc_sel_E;
	wire [1:0] pc_sel_M;
	
	reg cond_flag_E;
	wire cond_flag_M;
	
	reg [31:0] signExtImm_E;
	wire [31:0] signExtImm_M;

	reg [DBITS - 1 : 0] incPC_E, ALUresult_E, src1Data_E, src2Data_E;
	wire [DBITS - 1 : 0] incPC_M, ALUresult_M, src1Data_M, src2Data_M;

	reg [OPBITS - 1 : 0] i_op_E;
	wire [OPBITS - 1 : 0] i_op_M;

	reg [REGBITS - 1 : 0] src1Index_E, src2Index_E, destIndex_E;
	wire [REGBITS - 1 : 0] src1Index_M, src2Index_M, destIndex_M;

	reg memWrtEn_E, regWrtEn_E;
	wire memWrtEn_M, regWrtEn_M;

	reg [1 : 0] regFileMux_E;
	wire [1 : 0] regFileMux_M;

	always begin
        #500
        clk <= ~clk;
    end

	EMBuffer #(DBITS) embuf(clk,
							reset,
							wrtEn,

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

							//output data
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
							
							//noop
							noop_E,
							noop_M,
							pc_sel_E,
							pc_sel_M,
							cond_flag_E,
							cond_flag_M,
							signExtImm_E,
							signExtImm_M);

	initial begin
		#1000
		incPC_E = 32'd1;
		src1Index_E = 4'd15;
		src2Index_E = 4'd14;
		ALUresult_E = 32'd999;
		src1Data_E = 32'd777;
		src2Data_E = 32'd666;
		destIndex_E = 4'd13;
		i_op_E = 4'd12;
		noop_E = 1'b1;
		pc_sel_E = 2'b11;
		cond_flag_E = 1'b1;
		signExtImm_E = 32'd17;

		memWrtEn_E = 1'b1;
		regFileMux_E = 2'd2;
		regWrtEn_E = 1'b1;

		#1000
		wrtEn = 1'b1;

		#1000
		wrtEn = 1'b0;

		incPC_E = 32'd0;
		src1Index_E = 4'd0;
		src2Index_E = 4'd0;
		ALUresult_E = 32'd0;
		src1Data_E = 32'd0;
		src2Data_E = 32'd0;
		destIndex_E = 4'd0;
		i_op_E = 4'd0;
		noop_E = 1'b0;
		pc_sel_E = 2'b00;
		cond_flag_E = 1'b0;
		signExtImm_E = 32'd0;

		memWrtEn_E = 1'b0;
		regFileMux_E = 2'd0;
		regWrtEn_E = 1'b0;

		#2000
		$stop;
	end

endmodule
