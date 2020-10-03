`define     BCOND_PC   4'b0010
`define     JAL_PC     4'b0110
`define     LW_PC      4'b0111
`define     SW_PC      4'b0011

module PipelinedProcessor(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);
	parameter DBITS         			 = 32;
	parameter INST_SIZE      			 = 32'd4;
	parameter INST_BIT_WIDTH			 = 32;
	parameter START_PC       			 = 32'h40;
	parameter REG_INDEX_BIT_WIDTH 	 = 4;
	parameter ADDR_KEY  					 = 32'hF0000010;
	parameter ADDR_SW   					 = 32'hF0000014;
	parameter ADDR_HEX  					 = 32'hF0000000;
	parameter ADDR_LEDR 					 = 32'hF0000004;
	
	parameter IMEM_INIT_FILE				 = "Test2.mif";
	parameter IMEM_ADDR_BIT_WIDTH 		 = 11;
	parameter IMEM_DATA_BIT_WIDTH 		 = INST_BIT_WIDTH;
	parameter IMEM_PC_BITS_HI     		 = IMEM_ADDR_BIT_WIDTH + 2;
	parameter IMEM_PC_BITS_LO     		 = 2;
	
	parameter DMEMADDRBITS 				 = 13;
	parameter DMEMWORDBITS				 = 2;
	parameter DMEMWORDS					 = 2048;
	
	//OUR PARAMETERS
	parameter IMM_BITS = 16;
	parameter OP_FN_SIZ = 4;


	//ALL WIRES
	//TOP LEVEL
	input[9:0] SW;
	input[3:0] KEY;
	input  CLOCK_50;	
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	//CLOCK DIVIDER
	wire clk;

	//PC SEL MUX
	wire [DBITS - 1 : 0] branch_pc, jal_pc;
	assign branch_pc = incPC_M + (signExtImm_M << 2);
	assign jal_pc = rs1_out_M  + (signExtImm_M << 2);
	wire [1 : 0] pc_sel;
	assign pc_sel = (i_op_M == `BCOND_PC && cond_flag_M) ? 2'b01 : pc_sel_M;
	wire [DBITS - 1 : 0] pc_mux_out;

	//PC
	wire [DBITS - 1 : 0] pc_out;

	//INST MEMORY
	wire [DBITS - 1 : 0] instWord;
	
	//NOOP SEL MUX
	wire [DBITS - 1 : 0] instWord_F;
	
	//FD BUFFER
	wire [DBITS - 1 : 0] incPC_F;
	assign incPC_F = pc_out + 32'd4;
	wire [DBITS - 1 : 0] incPC_D;
	wire [DBITS - 1 : 0] instWord_D;
	wire noop_D;
	wire flush;
	assign flush = ((cond_flag_M & (i_op_M == `BCOND_PC)) || (i_op_M == `JAL_PC));
	
	//DECODER
	wire [REG_INDEX_BIT_WIDTH - 1 : 0] rd_D;
	wire [REG_INDEX_BIT_WIDTH - 1 : 0] rs1_D;
	wire [REG_INDEX_BIT_WIDTH - 1 : 0] rs2_D;
	wire [IMM_BITS - 1 : 0] imm_D;
	wire [OP_FN_SIZ - 1 : 0] i_op_D, i_fn_D;

	//CONTROLLER
	wire	pc_wrt_en_D;
	wire	regfile_wrt_en_D;
	wire	mem_wrt_en_D;
	wire [1 : 0]	pc_sel_D;
	wire [1 : 0]	regfile_sel_D;
	wire	ALU_src1_sel_D;
	wire [1 : 0]	ALU_src2_sel_D;
	wire [4 : 0]	ALU_op_D;
	
	//REGFILE
	wire[DBITS - 1 : 0] rs1_out_D, rs2_out_D;

	//SIGN EXTENDER
	wire [DBITS - 1 : 0] signExtImm_D;

	//FORWARDING UNIT
	wire[1:0] rs1_sel_D;
	wire[1:0] rs2_sel_D;
	
	//FORWARDING UNIT MUXES
	wire[DBITS - 1 : 0] rs1_forward_out_D;
	wire[DBITS - 1 : 0] rs2_forward_out_D;
	
	//DE BUFFER
	wire [REG_INDEX_BIT_WIDTH - 1 : 0] rd_E;
	wire [REG_INDEX_BIT_WIDTH - 1 : 0] rs1_E;
	wire [REG_INDEX_BIT_WIDTH - 1 : 0] rs2_E;
	wire [DBITS - 1 : 0] signExtImm_E;
	wire [OP_FN_SIZ - 1 : 0] i_op_E;
	wire[DBITS - 1 : 0] rs1_out_E, rs2_out_E;
	wire [DBITS - 1 : 0] incPC_E;
	// wire	pc_wrt_en_E;
	wire	regfile_wrt_en_E;
	wire	mem_wrt_en_E;
	wire [1 : 0]	regfile_sel_E;
	// wire	ALU_src1_sel_D;
	wire [1 : 0]	ALU_src2_sel_E;
	wire [4 : 0]	ALU_op_E;
	wire noop_E;
	wire [1 : 0] pc_sel_E;
	
	//ALU SRC2 MUX
	wire[DBITS - 1 : 0] ALU_src2_data_E;

	//ALU
	wire[DBITS - 1 : 0] ALU_out_E;
	wire cond_flag_E;
	
	//STALLER
	wire stall;
	
	//EM BUFFER
	wire[DBITS - 1 : 0] incPC_M, ALU_out_M, rs1_out_M, rs2_out_M;
	wire[REG_INDEX_BIT_WIDTH - 1 : 0] rs1_M, rs2_M, rd_M;
	wire [3 : 0] i_op_M;
	wire mem_wrt_en_M, regfile_sel_M, regfile_wrt_en_M;
	wire noop_M;
	wire [1 : 0] pc_sel_M;
	wire cond_flag_M;
	wire [DBITS - 1 : 0] signExtImm_M;
	
	//DATA MEMORY
	wire[15:0] hex_intermediate;
	wire[DBITS - 1 : 0] mem_out_M;
	
	//MEM FWD MUX
	wire mem_fwd_sel;
	assign mem_fwd_sel = (i_op_M == `LW_PC || i_op_M == `SW_PC) ? 1'b1 : 1'b0;
	wire [DBITS - 1 : 0] mem_fwd_out;
	
	//MW BUFFER
	wire[DBITS - 1 : 0] incPC_W, ALU_out_W, mem_out_W;
	wire[3 : 0] rs1_W, rs2_W, rd_W;
	wire[3 : 0] i_op_W;
	wire regfile_sel_W, regfile_wrt_en_W;
	wire noop_W;
	
	//REG SEL MUX
	wire[DBITS - 1 : 0] regfile_din_W;
	
	///////////////////////////////////

	//FETCH
	
	Mux4to1 pc_sel_mux((pc_out + 4), branch_pc, jal_pc, 32'd0, pc_sel, pc_mux_out);

	Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, 1'b0, !stall, pc_mux_out, pc_out);
	//Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, 1'b0, !full_noop, pc_mux_out, pc_out);
	
	InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) inst_mem (pc_out[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);

	Mux2to1 noop_sel_mux(instWord, 32'b1100_0000_0000_0000_0000_0000_0000_0000, stall | flush, instWord_F);
	//Mux2to1 noop_sel_mux(instWord, 32'b1100_0000_0000_0000_0000_0000_0000_0000, full_noop, instWord_F);
	
	FDBuffer #(32, 32'b0010_0011_0000_0000_0000_0000_0000_0000) fdbuf (
		clk,
		flush,
		1'b1,
		incPC_F,
		instWord_F,
		incPC_D,
		instWord_D,
		
		stall,
		//full_noop,
		
		noop_D
		); 

		
	//DECODE
	
	Decoder pp_kidneys(
		instWord_D,
		rs1_D,
		rs2_D,
		rd_D,
		imm_D,
		i_op_D,
		i_fn_D
		);

	Controller pp_bladder(
		i_op_D,
		i_fn_D,
		pc_wrt_en_D,
		regfile_wrt_en_D,
		mem_wrt_en_D,
		pc_sel_D,
		regfile_sel_D,
		ALU_src1_sel_D,
		ALU_src2_sel_D,
		ALU_op_D
		);

	RegFile #(.DATA_BITS(DBITS), .ADDRESS_BITS(REG_INDEX_BIT_WIDTH)) pp_tommyPickles(
		rs1_D,
		rs1_out_D,
		rs2_D,
		rs2_out_D,
		rd_W,
		regfile_din_W,
		regfile_wrt_en_W & !noop_W,
		clk
		);

	SignExtension #(.IN_BIT_WIDTH(DBITS/2), .OUT_BIT_WIDTH(DBITS)) pp_xxxpander(
		imm_D,
		signExtImm_D
		);

	ForwardingUnit #(.REGNO_SEL(4), .MUX_SEL(2)) funit(
		rd_E,
		rd_M,
		rd_W,

		rs1_D,
		rs2_D,

		rs1_sel_D,
		rs2_sel_D,
		
		noop_E,
		noop_M,
		noop_W,
		
		regfile_wrt_en_E,
		regfile_wrt_en_M,
		regfile_wrt_en_W
		);

	Mux4to1 #(32) rs1_sel_debuf(
		rs1_out_D,
		ALU_out_E,
		mem_fwd_out,
		regfile_din_W,
		rs1_sel_D,
		rs1_forward_out_D
		);
		
	Mux4to1 #(32) rs2_sel_debuf(
		rs2_out_D,
		ALU_out_E,
		mem_fwd_out,
		regfile_din_W,
		rs2_sel_D,
		rs2_forward_out_D
		);
		
	DEBuffer #(.DBITS(DBITS), .REGBITS(REG_INDEX_BIT_WIDTH), .OPBITS(OP_FN_SIZ)) debuf(
		clk,
		1'b0,
		1'b1,

		incPC_D,
		rs1_D,
		rs1_forward_out_D,
		rs2_D,
		rs2_forward_out_D,
		rd_D,
		signExtImm_D,
		i_op_D,

		ALU_op_D,
		ALU_src2_sel_D,
		regfile_sel_D,
		mem_wrt_en_D,
		regfile_wrt_en_D,

		incPC_E,
		rs1_E,
		rs1_out_E,
		rs2_E,
		rs2_out_E,
		rd_E,
		signExtImm_E,
		i_op_E,

		ALU_op_E,
		ALU_src2_sel_E,
		regfile_sel_E,
		mem_wrt_en_E,
		regfile_wrt_en_E,
		
		noop_D,
		pc_sel_D,
		noop_E,
		pc_sel_E
		);

	//EXEC

	Mux4to1 #(32) alu_src2_sel_mux(
		rs2_out_E,
		signExtImm_E,
		incPC_E,
		32'd0,
		ALU_src2_sel_E,
		ALU_src2_data_E
		);

	ALU #(.BIT_WIDTH(DBITS), .OP_BITS(5), .COND_BITS(1)) da_alu_g_show_e(
		rs1_out_E, 
		ALU_src2_data_E,
		ALU_op_E,
		ALU_out_E,
		cond_flag_E
		);

		
		
		
		
	//test wires
	wire full_noop;
	Staller #(.OPBITS(OP_FN_SIZ)) staller(
		i_op_D,
		i_op_E,
		stall,
		full_noop,
		clk);

	EMBuffer #(.DBITS(DBITS), .REGNO(REG_INDEX_BIT_WIDTH), .OPNO(OP_FN_SIZ)) embuf(
		clk,
		1'b0,
		1'b1,

		incPC_E,
		rs1_E,
		rs2_E,
		ALU_out_E,
		rs1_out_E,
		rs2_out_E,
		rd_E,
		i_op_E,

		mem_wrt_en_E,
		regfile_sel_E,
		regfile_wrt_en_E,


		incPC_M,
		rs1_M,
		rs2_M,
		ALU_out_M,
		rs1_out_M,
		rs2_out_M,
		rd_M,
		i_op_M,

		mem_wrt_en_M,
		regfile_sel_M,
		regfile_wrt_en_M,
		
		noop_E,
		noop_M,
		pc_sel_E,
		pc_sel_M,
		cond_flag_E,
		cond_flag_M,
		signExtImm_E,
		signExtImm_M
		);

	//MEM	

	wire [8:0]leds;
	
	DataMemory #(.MEM_INIT_FILE(IMEM_INIT_FILE), .ADDR_BIT_WIDTH(32), .DATA_BIT_WIDTH(32), .TRUE_ADDR_BIT_WIDTH(11)) daytona5000memory(
		clk,
		mem_wrt_en_M & !noop_M,
		ALU_out_M,
		rs2_out_M,
		SW[8:0],
		KEY,
		LEDR[8:0],
		hex_intermediate,
		mem_out_M
		);
		
	Mux2to1 mem_fwd_mux(ALU_out_M, mem_out_M, mem_fwd_sel, mem_fwd_out);

	MWBuffer #(.DBITS(DBITS), .REGNO(REG_INDEX_BIT_WIDTH), .OPNO(OP_FN_SIZ)) mwbuf(
		clk,
		1'b0,
		1'b1,

		incPC_M,
		rs1_M,
		rs2_M,
		ALU_out_M,
		mem_out_M,
		rd_M,
		i_op_M,

		regfile_sel_M,
		regfile_wrt_en_M,

		incPC_W,
		rs1_W,
		rs2_W,
		ALU_out_W,
		mem_out_W,
		rd_W,
		i_op_W,

		regfile_sel_W,
		regfile_wrt_en_W,
		
		noop_M,
		noop_W
		);

	//WRITE BACK

	Mux4to1 #(32) regfile_sel_data(
		ALU_out_W,
		mem_out_W,
		incPC_W,
		32'd0,

		regfile_sel_W,
		regfile_din_W
		);

	//OTHER

	ClockDivider pp_heart(CLOCK_50, clk, 1'b0);
	//FlipFlop fl(KEY[0], 1'b1, 1'b1, clk);
	
	SevenSeg ss0(hex_intermediate[3:0], HEX0);
	SevenSeg ss1(hex_intermediate[7:4], HEX1);
	SevenSeg ss2(hex_intermediate[11:8], HEX2);
	SevenSeg ss3(hex_intermediate[15:12], HEX3);
	
	/*
	SevenSeg ss0(realPC_W[3:0], HEX0);
	SevenSeg ss1(realPC_W[7:4], HEX1);
	SevenSeg ss2(realPC_M[3:0], HEX2);
	SevenSeg ss3(realPC_M[7:4], HEX3);
	SevenSeg ss4(pc_out[3:0], HEX4);
	SevenSeg ss5(pc_out[7:4], HEX5);

	//SevenSeg ss0(pc_mux_out[7:4], HEX1);
	//SevenSeg ss1(pc_mux_out[3:0], HEX0);
	
	//SevenSeg ss0(ALU_out_M[7:4], HEX1);
	//SevenSeg ss1(ALU_out_M[3:0], HEX0);
	
	
	//SevenSeg ss2(realPC_M[3:0], HEX2);
	//SevenSeg ss3(realPC_M[7:4], HEX3);
	
	wire [31:0] realPC_W;
	assign realPC_W = incPC_W - 32'd4;
	
	wire [31:0] realPC_M;
	assign realPC_M = incPC_M - 32'd4;
	
	wire [31:0] realPC_E;
	assign realPC_E = incPC_E - 32'd4;
	
	//SevenSeg ss4(realPC_E[3:0], HEX4);
	//SevenSeg ss5(realPC_E[7:4], HEX5);
	
	assign LEDR[9] = !stall;
	//assign LEDR[9] = !full_noop;
	
	//assign LEDR[4] = full_noop;
	assign LEDR[4] = stall | flush;
	assign LEDR[3] = noop_D;
	assign LEDR[2] = noop_E;
	assign LEDR[1] = noop_M;
	assign LEDR[0] = noop_W;
	
	//assign LEDR[7] = pc_sel_M[1];
	//assign LEDR[6] = pc_sel_M[0];
	
	assign LEDR[7] = ALU_src2_sel_E[1];
	assign LEDR[6] = ALU_src2_sel_E[0];
	*/
endmodule