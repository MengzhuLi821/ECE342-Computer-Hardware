`timescale 1ns/1ns
module tb();

	  // Generates a 50MHz clock.
	logic clk;
	initial clk = 1'b0;     // Clock starts at 0
	always #10 clk = ~clk;  // Wait 10ns, flip the clock, repeat forever
	
	// Instantiate the adder we're testing (Design Under Test)
	logic reset, enter;
	logic [7:0] guess, actual;
	logic [8:0] dut_sum;
	logic dp_over, dp_under, dp_equal;
logic [3:0] dp_tries;
	
	part1 DUT
	(
		// Clock pins
		.clk(clk),
		.reset(reset),
		.enter(enter),
		.guess(guess),
		.actual(actual),
		.dp_over(dp_over),
		.dp_under(dp_under),
		.dp_equal(dp_equal)
.dp_tries(dp_tries)
	);
	
	// This block drives the simulation
	initial begin
		reset = 1'b1;   // Start with reset on
		@(posedge clk);
			reset = 1'b0;   // Leave it on for a clock cycle and then turn it off
		
		for(integer x = 1; x<30; x++)
		begin
			if(x>=2) 
				enter = 1'b1; //enter the number
			else
				enter = 1'b0;
			
			guess = x;
			
			@(posedge clk)
				enter = 1'b0;

			for(integer y=1; y<=10; y++)
			begin
				@(posedge clk); // Wait 1 cycle before sending next inputs
			end
			$display("The result is over: %0d under: %0d equal: %0d",dp_over, dp_under, dp_equal);
		end

		$display("Test Finished!");
		$stop();
	end

endmodule
