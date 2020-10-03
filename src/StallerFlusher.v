/*`define     LW_SF      4'b0111
`define     BCOND_SF   4'b0010
`define     JAL_SF     4'b0110

module StallerFlusher(i_op, cond_flag, src1_index_D, src2_index_D, rd_index_E, flush_a, flush_b, stall, pc_sel);
	input[3:0] i_op, src1_index_D, src2_index_D, rd_index_E;
	input cond_flag;

	output reg flush_a, flush_b, stall;
	output reg [1:0] pc_sel;

	always @(*) begin
		flush_a = 1'b0;
		flush_b = 1'b0;
		stall = 1'b0;
		pc_sel = 2'b00;
		case (i_op)
			`LW_SF: begin
				if (src1_index_D == rd_index_E || src2_index_D == rd_index_E) begin
					flush_a = 1'b0;
					flush_b = 1'b1;
					stall = 1'b1;
					pc_sel = 2'b00;
				end
			end
			`BCOND_SF: begin
				if (cond_flag) begin
					flush_a = 1'b1;
					flush_b = 1'b1;
					stall = 1'b0;
					pc_sel = 2'b01;
				end
			end
			`JAL_SF: begin
				flush_a = 1'b1;
				flush_b = 1'b1;
				stall = 1'b0;
				pc_sel = 2'b10;
			end
			default: begin
				flush_a = 1'b0;
				flush_b = 1'b0;
				stall = 1'b0;
				pc_sel = 2'b00;
			end
		endcase
	end
endmodule*/