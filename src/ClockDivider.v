module ClockDivider (
	inclk0,
	c0,
	locked);

	parameter secondCount = 50000000; //Test clock one second
	parameter slowCount = 1000000; //Processor clock

	input inclk0;
	input locked;
	output c0;
	// clock is paused when locked is 1

  // Implement this yourself
  // Slow down the clock to ensure the cycle is long enough for all operations to execute
  // If you don't, you might get weird errors

  	reg [25:0] pulseCounter = 0;
	reg c0_temp = 0;
	
	assign c0 = c0_temp;

  	always @ (posedge inclk0) begin
  		//c0_temp = 0;

  		if (pulseCounter == (slowCount/2)) begin
  			pulseCounter = 0;
  			//c0_temp = 1;
			c0_temp = ~c0_temp;
  		end

	  	else if (~locked)
  			pulseCounter = pulseCounter + 1;
  	end
endmodule
