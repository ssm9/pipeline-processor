module TestFDBuffer();

	parameter DBITS = 32;

	reg clk = 1'b0;
	reg reset = 1'b0;
	reg wrtEn = 1'b0;
	
	reg noop_F;
	wire noop_D;

	reg [DBITS - 1 : 0] incPC_F;
	wire [DBITS - 1 : 0] incPC_D;

	reg [DBITS - 1 : 0] instWord_F;
	wire [DBITS - 1 : 0] instWord_D;

	always begin
        #500
        clk <= ~clk;
    end

	FDBuffer #(DBITS) fdbuf(clk,
							reset,
							wrtEn,

							//input data
							incPC_F,
							instWord_F,

							//output data
							incPC_D,
							instWord_D,
							
							//noop
							noop_F,
							noop_D);

	initial begin
		#1000
		incPC_F = 32'd44;
		instWord_F = 32'd1101029;
		noop_F = 1'b1;

		#1000
		wrtEn = 1'b1;

		#1000
		wrtEn = 1'b0;
		
		incPC_F = 32'd19;
		instWord_F = 32'd27;

		#2000
		$stop;
	end

endmodule
