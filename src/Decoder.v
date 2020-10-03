`define     ALUR_D    4'b1100
`define     ALUI_D    4'b0100
`define     CMPR_D    4'b1101
`define     CMPI_D    4'b0101
`define     LW_D      4'b0111
`define     SW_D      4'b0011
`define     BCOND_D   4'b0010
`define     JAL_D     4'b0110

module Decoder(
	i_word,
	rs1,
	rs2,
	rd,
	imm,
	i_op,
	i_fn);

	parameter DATA_BITS = 32;
	parameter REGNO_SEL = 4;
	parameter OP_FN_SIZ = 4;
	
	input [DATA_BITS - 1 : 0] i_word;

	output [REGNO_SEL - 1 : 0] rs1, rs2, rd;
	output [(DATA_BITS / 2) - 1 : 0] imm;
	output [OP_FN_SIZ - 1 : 0] i_op, i_fn;

    reg [REGNO_SEL - 1 : 0] rd_temp, rs1_temp, rs2_temp;
	reg [(DATA_BITS / 2) - 1 : 0] imm_temp;

	assign rd = rd_temp;
	assign rs1 = rs1_temp;
	assign rs2 = rs2_temp;
	assign imm = imm_temp;
	assign i_op = i_word[31 : 28];
	assign i_fn = i_word[27 : 24];

	always @(*) begin
	    rd_temp = 0;
		rs1_temp = 0;
		rs2_temp = 0;
		imm_temp = 0;
	
		case (i_op)
            `ALUR_D: begin
            	rd_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	rs2_temp = i_word[15 : 12];
            end
                
            `ALUI_D: begin
            	rd_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	imm_temp = i_word[15 : 0];
            end
                
            `CMPR_D: begin
            	rd_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	rs2_temp = i_word[15 : 12];
            end

            `CMPI_D: begin
            	rd_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	imm_temp = i_word[15 : 0];
            end

            `LW_D: begin
            	rd_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	imm_temp = i_word[15 : 0];
            end

            `SW_D: begin
            	rs2_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	imm_temp = i_word[15 : 0];
            end

            `BCOND_D: begin
                rs1_temp = i_word[23 : 20];
            	rs2_temp = i_word[19 : 16];
            	imm_temp = i_word[15 : 0];            
            end

            `JAL_D: begin
            	rd_temp = i_word[23 : 20];
            	rs1_temp = i_word[19 : 16];
            	imm_temp = i_word[15 : 0];
            end

            //default: begin
            //    rd_temp = 4'd0;
            //    rs1_temp = 4'd0;
            //    rs2_temp = 4'd0;
            //    imm_temp = 4'd0;
            //end
        endcase
    end
endmodule