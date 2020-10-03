module FlipFlop(clk, reset, en_flip, flip);
	input clk;
	input reset;
	input en_flip;
	
	output flip;
	reg flip = 0;

	always @(negedge reset or negedge clk) begin
		 if (reset == 1'b0)
			  flip <= 0;
		 else if(en_flip)
			  flip <= ~flip;
	end
endmodule