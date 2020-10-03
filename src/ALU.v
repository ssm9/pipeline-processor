//ALU-R, ALU_I
`define ALU_ADD 	5'b00000 //SW, LW, JAL
`define ALU_SUB 	5'b00001
`define ALU_AND 	5'b00010
`define ALU_OR  	5'b00011
`define ALU_XOR 	5'b00100
`define ALU_NAND 	5'b00101
`define ALU_NOR 	5'b00110
`define ALU_XNOR 	5'b00111

//ALU_I
`define ALU_MVHI 	5'b01000

//CMP_R, CMP_I
`define ALU_F 		5'b01001
`define ALU_EQ 	5'b01010
`define ALU_LT	 	5'b01011
`define ALU_LTE	5'b01100
`define ALU_T	 	5'b01101
`define ALU_NE	 	5'b01110
`define ALU_GTE 	5'b01111
`define ALU_GT 	5'b10000

module ALU(operand1, operand2, ALU_op, ALU_out, cond_flag);
	parameter BIT_WIDTH = 32;
	parameter OP_BITS = 5;
	parameter COND_BITS = 1;

	input signed [BIT_WIDTH - 1 : 0] operand1;
	input signed [BIT_WIDTH - 1 : 0] operand2;
	input [OP_BITS - 1 : 0] ALU_op;

	output signed [BIT_WIDTH - 1 : 0] ALU_out;
	output [COND_BITS - 1 : 0] cond_flag;
	
	reg [BIT_WIDTH - 1 : 0] ALU_out_temp;
	reg [COND_BITS - 1 : 0] cond_flag_temp;

	always @ (*) begin
		ALU_out_temp = 0;
		cond_flag_temp = 0;
		case (ALU_op)
		//ALU-R, ALU-I
			`ALU_ADD: begin
				ALU_out_temp = (operand1 + operand2);
			end

			`ALU_SUB: begin
				ALU_out_temp = (operand1 - operand2);
			end

			`ALU_AND: begin
				ALU_out_temp = (operand1 & operand2);
			end

			`ALU_OR: begin
				ALU_out_temp = (operand1 | operand2);
			end

			`ALU_XOR: begin
				ALU_out_temp = (operand1 ^ operand2);
			end

			`ALU_NAND: begin
				ALU_out_temp = ~(operand1 & operand2);
			end

			`ALU_NOR: begin
				ALU_out_temp = ~(operand1 | operand2);
			end

			`ALU_XNOR: begin
				ALU_out_temp = ~(operand1 ^ operand2);
			end

		//ALU_I
			`ALU_MVHI: begin
				/*
				ALU_out_temp[BIT_WIDTH - 1 : BIT_WIDTH / 2] = operand2[(BIT_WIDTH / 2) - 1 : 0]; //imm high bits
				ALU_out_temp[(BIT_WIDTH / 2) - 1 : 0] = operand1[(BIT_WIDTH / 2) - 1 : 0]; //rd low bits
				*/

				ALU_out_temp[31 : 16] = operand2[15 : 0];
				//ALU_out_temp[15 : 0] = operand1[15 : 0];
			end

		//CMP_R, CMP_I
			`ALU_F: begin
				ALU_out_temp = 0;
				cond_flag_temp = 0;
			end

			`ALU_EQ: begin
				ALU_out_temp = (operand1 == operand2) ? 1 : 0;
				cond_flag_temp = (operand1 == operand2) ? 1 : 0;
			end

			`ALU_LT: begin
				ALU_out_temp = (operand1 < operand2) ? 1 : 0;
				cond_flag_temp = (operand1 < operand2) ? 1 : 0;
			end

			`ALU_LTE: begin
				ALU_out_temp = (operand1 <= operand2) ? 1 : 0;
				cond_flag_temp = (operand1 <= operand2) ? 1 : 0;
			end

			`ALU_T: begin
				ALU_out_temp = 1;
				cond_flag_temp = 1;
			end

			`ALU_NE: begin
				ALU_out_temp = (operand1 != operand2) ? 1 : 0;
				cond_flag_temp = (operand1 != operand2) ? 1 : 0;
			end

			`ALU_GTE: begin
				ALU_out_temp = (operand1 >= operand2) ? 1 : 0;
				cond_flag_temp = (operand1 >= operand2) ? 1 : 0;
			end

			`ALU_GT: begin
				ALU_out_temp = (operand1 > operand2) ? 1 : 0;
				cond_flag_temp = (operand1 > operand2) ? 1 : 0;
			end

			default: begin
				ALU_out_temp = 0;
				cond_flag_temp = 0;
			end
		endcase
	end
	
	assign ALU_out = ALU_out_temp;
	assign cond_flag = cond_flag_temp;
endmodule