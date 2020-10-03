//OP
`define     ALUR    4'b1100
`define     ALUI    4'b0100
`define     CMPR    4'b1101
`define     CMPI    4'b0101
`define     LW      4'b0111
`define     SW      4'b0011
`define     BCOND   4'b0010
`define     JAL     4'b0110

//fn
`define		ADD		4'b0111
`define		SUB		4'b0110
`define		AND		4'b0000
`define		OR		4'b0001
`define		XOR		4'b0010
`define		NAND	4'b1000
`define		NOR		4'b1001
`define		XNOR	4'b1010

`define		ADDI	4'b0111
`define		SUBI	4'b0110
`define		ANDI	4'b0000
`define		ORI		4'b0001
`define		XORI	4'b0010
`define		NANDI	4'b1000
`define		NORI	4'b1001
`define		XNORI	4'b1010
`define		MVHI	4'b1111

`define		F		4'b0011
`define		EQ		4'b0110
`define		LT		4'b1001
`define		LTE		4'b1100
`define		T		4'b0000
`define		NE		4'b0101
`define		GTE		4'b1010
`define		GT		4'b1111

`define		FI		4'b0011
`define		EQI		4'b0110
`define		LTI		4'b1001
`define		LTEI	4'b1100
`define		TI		4'b0000
`define		NEI		4'b0101
`define		GTEI	4'b1010
`define		GTI		4'b1111

`define		BF		4'b0011
`define		BEQ		4'b0110
`define		BLT		4'b1001
`define		BLTE	4'b1100
`define		BEQZ	4'b0010
`define		BLTZ	4'b1101
`define		BLTEZ	4'b1000

`define		BT		4'b0000
`define		BNE		4'b0101
`define		BGTE	4'b1010
`define		BGT		4'b1011
`define		BNEZ	4'b0001
`define		BGTEZ	4'b1110
`define		BGTZ	4'b1111

module Controller(
						i_op,
						i_fn,
						pc_wrt_en, regfile_wrt_en, mem_wrt_en,
						pc_sel, regfile_sel, ALU_src1_sel, ALU_src2_sel,
						ALU_op);
						
	parameter DEFAULT_CONTROL_SIGNALS = 15'b000000000000001;
	parameter BIT_WIDTH = 32;
	parameter OP_FN_BITS = 4;
	parameter REG_BITS = 4;
	parameter IMM_BITS = 16;

	//inputs
	// input [BIT_WIDTH - 1 : 0] i_word;
	// input cond_flag;
	input [OP_FN_BITS - 1 : 0] i_op, i_fn;
	
	//decoded values
	// output [REG_BITS - 1 : 0] rd;
	// output [REG_BITS - 1 : 0] rs1;
	// output [REG_BITS - 1 : 0] rs2;
	// output [IMM_BITS - 1 : 0] imm;

	//alu_op
	output [4 : 0] ALU_op;					//10-14	[14:10]
	
	//sel
	output [1 : 0] ALU_src2_sel;			//8,9
	output ALU_src1_sel;					//7
	output [1 : 0] regfile_sel;				//5,6
	output [1 : 0] pc_sel;					//3,4	[9:3]

	//wrt_en
	output mem_wrt_en;						//2
	output regfile_wrt_en;					//1
	output pc_wrt_en;						//0		[2:0]

	//intermediate values
	reg [14 : 0] control_signals = DEFAULT_CONTROL_SIGNALS;
	
	// wire [3 : 0] op_code = i_word[31 : 28];
	// wire [3 : 0] fn_code = i_word[27 : 24];
	
	// reg [REG_BITS - 1 : 0] rd_temp = 0;
	// reg [REG_BITS - 1 : 0] rs1_temp = 0;
	// reg [REG_BITS - 1 : 0] rs2_temp = 0;
	// reg [IMM_BITS - 1 : 0] imm_temp = 0;

	//assign outputs
	assign {ALU_op,
			ALU_src2_sel, ALU_src1_sel, regfile_sel, pc_sel,
			mem_wrt_en, regfile_wrt_en, pc_wrt_en}									
			= control_signals;

	// assign rd = rd_temp;
	// assign rs1 = rs1_temp;
	// assign rs2 = rs2_temp;
	// assign imm = imm_temp;
	
	//Manage control signals
	always @(*) begin
		// rd_temp = 0;
		// rs1_temp = 0;
		// rs2_temp = 0;
		// imm_temp = 0;
		
		case (i_op)
            `ALUR: begin
            	// rd_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// rs2_temp = i_word[15 : 12];
                
                case (i_fn)
                    `ADD: begin
                        control_signals = 15'b000000000000011; 
                    end
                    `SUB: begin
                        control_signals = 15'b000010000000011; 
                    end
                    `AND: begin
                        control_signals = 15'b000100000000011; 
                    end
                    `OR: begin
                        control_signals = 15'b000110000000011; 
                    end
                    `XOR: begin
                        control_signals = 15'b001000000000011; 
                    end
                    `NAND: begin
                        control_signals = 15'b001010000000011; 
                    end
                    `NOR: begin
                        control_signals = 15'b001100000000011; 
                    end
                    `XNOR: begin
                        control_signals = 15'b001110000000011; 
                    end
                    
                    default:
                        control_signals = DEFAULT_CONTROL_SIGNALS;
                endcase
            end
                
            `ALUI: begin
            	// rd_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// imm_temp = i_word[15 : 0];

                case (i_fn)
                    `ADDI: begin
                        control_signals = 15'b000000100000011; 
                    end
                    `SUBI: begin
                        control_signals = 15'b000010100000011; 
                    end
                    `ANDI: begin
                        control_signals = 15'b000100100000011; 
                    end
                    `ORI: begin
                        control_signals = 15'b000110100000011; 
                    end
                    `XORI: begin
                        control_signals = 15'b001000100000011; 
                    end
                    `NANDI: begin
                        control_signals = 15'b001010100000011; 
                    end
                    `NORI: begin
                        control_signals = 15'b001100100000011; 
                    end
                    `XNORI: begin
                        control_signals = 15'b001110100000011; 
                    end
                    `MVHI: begin
                        control_signals = 15'b010000110000011; 
                    end
                    
                    default:
                        control_signals = DEFAULT_CONTROL_SIGNALS;
                endcase
            end
                
            `CMPR: begin
            	// rd_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// rs2_temp = i_word[15 : 12];

                case (i_fn)
                    `F: begin
                        control_signals = 15'b010010000000011; 
                    end
                    `EQ: begin
                        control_signals = 15'b010100000000011; 
                    end
                    `LT: begin
                        control_signals = 15'b010110000000011; 
                    end
                    `LTE: begin
                        control_signals = 15'b011000000000011; 
                    end
                    `T: begin
                        control_signals = 15'b011010000000011; 
                    end
                    `NE: begin
                        control_signals = 15'b011100000000011; 
                    end
                    `GTE: begin
                        control_signals = 15'b011110000000011; 
                    end
                    `GT: begin
                        control_signals = 15'b100000000000011; 
                    end

                    default:
                        control_signals = DEFAULT_CONTROL_SIGNALS;
                endcase
            end

            `CMPI: begin
            	// rd_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// imm_temp = i_word[15 : 0];

                case (i_fn)
                    `FI: begin
                        control_signals = 15'b010010100000011; 
                    end
                    `EQI: begin
                        control_signals = 15'b010100100000011; 
                    end
                    `LTI: begin
                        control_signals = 15'b010110100000011; 
                    end
                    `LTEI: begin
                        control_signals = 15'b011000100000011; 
                    end
                    `TI: begin
                        control_signals = 15'b011010100000011; 
                    end
                    `NEI: begin
                        control_signals = 15'b011100100000011; 
                    end
                    `GTEI: begin
                        control_signals = 15'b011110100000011; 
                    end
                    `GTI: begin
                        control_signals = 15'b100000100000011; 
                    end

                    default:
                        control_signals = DEFAULT_CONTROL_SIGNALS;
                endcase
            end

            `LW: begin
            	// rd_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// imm_temp = i_word[15 : 0];

                control_signals = 15'b000000100100011;
            end

            `SW: begin
            	// rs2_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// imm_temp = i_word[15 : 0];

                control_signals = 15'b000000100000101;
            end

            `BCOND: begin
             	//rs1_temp = i_word[23 : 20];
            	// rs2_temp = i_word[19 : 16];
            	// imm_temp = i_word[15 : 0];

                case (i_fn)
                    `BF: begin
                        control_signals = 15'b010010000000001; 
                    end
                    `BEQ: begin
                        control_signals = 15'b010100000000001; 
                    end
                    `BLT: begin
                        control_signals = 15'b010110000000001; 
                    end
                    `BLTE: begin
                        control_signals = 15'b011000000000001; 
                    end
                    `BEQZ: begin
                        control_signals = 15'b010101100000001; 
                    end
                    `BLTZ: begin
                        control_signals = 15'b010111100000001; 
                    end
                    `BLTEZ: begin
                        control_signals = 15'b011001100000001; 
                    end
                    `BT: begin
                        control_signals = 15'b011010000001001; 
                    end
                    `BNE: begin
                        control_signals = 15'b011100000000001; 
                    end
                    `BGTE: begin
                        control_signals = 15'b011110000000001; 
                    end
                    `BGT: begin
                        control_signals = 15'b100000000000001; 
                    end
                    `BNEZ: begin
                        control_signals = 15'b011101100000001; 
                    end
                    `BGTEZ: begin
                        control_signals = 15'b011111100000001; 
                    end
                    `BGTZ: begin
                        control_signals = 15'b100001100000001; 
                    end
                    
                    default:
                        control_signals = DEFAULT_CONTROL_SIGNALS;
                endcase
                
                // control_signals[4:3] = cond_flag ? 2'b01 : 2'b00;
                
            end

            `JAL: begin
            	// rd_temp = i_word[23 : 20];
            	// rs1_temp = i_word[19 : 16];
            	// imm_temp = i_word[15 : 0];
            	
                control_signals = 15'b000001001010011;
            end

            default:
                control_signals = DEFAULT_CONTROL_SIGNALS;
        endcase
	end
	
endmodule