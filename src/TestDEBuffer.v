module TestDEBuffer();

	parameter DBITS = 32;
	parameter REGBITS = 4;
	parameter OPBITS = 4;

	reg clk = 1'b0;
	reg reset = 1'b0;
	reg wrtEn = 1'b0;
	
	reg noop_D;
	wire noop_E;

	reg [DBITS - 1 : 0] incPC_D, src1Data_D, src2Data_D, signExtImm_D;
	wire [DBITS - 1 : 0] incPC_E, src1Data_E, src2Data_E, signExtImm_E;

	reg [REGBITS - 1 : 0] src1Index_D, src2Index_D, destIndex_D;
	wire [REGBITS - 1 : 0] src1Index_E, src2Index_E, destIndex_E;

	reg [OPBITS - 1 : 0] opCode_D;
	wire [OPBITS - 1 : 0] opCode_E; 

	//Signals
	reg [4 : 0] aluOp_D;
	wire [4 : 0] aluOp_E;

	reg [1 : 0] src2Mux_D, regFileMux_D;
	wire [1 : 0] src2Mux_E, regFileMux_E;
	
	reg [1 : 0] pc_sel_D;
	wire [1 : 0] pc_sel_E;

	reg memWrtEn_D, regWrtEn_D;
	wire memWrtEn_E, regWrtEn_E;

	always begin
        #500
        clk <= ~clk;
    end

	DEBuffer #(DBITS) debuf(clk, 
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
							
							noop_D,
							pc_sel_D,
							noop_E,
							pc_sel_E);

	initial begin
		#1000
		incPC_D = 32'd1;
		src1Index_D = 4'd15;
		src1Data_D = 32'd2;
		src2Index_D = 4'd14;
		src2Data_D = 32'd3;
		destIndex_D = 4'd13;
		signExtImm_D = 32'd4;
		opCode_D = 4'd12;
		noop_D = 1'b1;
		pc_sel_D = 2'b10;

		aluOp_D = 5'd7;
		src2Mux_D = 2'd3;
		regFileMux_D = 2'd2;
		memWrtEn_D = 1'b1;
		regWrtEn_D = 1'b1;

		#1000
		wrtEn = 1'b1;

		#1000
		wrtEn = 1'b0;

		incPC_D = 32'd0;
		src1Index_D = 4'd0;
		src1Data_D = 32'd0;
		src2Index_D = 4'd0;
		src2Data_D = 32'd0;
		destIndex_D = 4'd0;
		signExtImm_D = 32'd0;
		opCode_D = 4'd0;
		noop_D = 1'b0;
		pc_sel_D = 2'b00;

		aluOp_D = 5'd0;
		src2Mux_D = 2'd0;
		regFileMux_D = 2'd0;
		memWrtEn_D = 1'b0;
		regWrtEn_D = 1'b0;

		#2000
		$stop;
	end

endmodule
