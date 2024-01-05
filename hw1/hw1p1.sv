/* Module for EE/CSE371 Homework 1 Problem 1.
 * A simple synchronous signal with a DFF and fullAdder.
 */
module hw1p1 (
	output logic S
	,input logic x, y, clk, reset
	);
	
	logic Q, C;
	
	full_adder f (.a(x), .b(y), .cin(Q), .S, .C);
	
	always_ff @(posedge clk) begin
		if (reset)
			Q <= 0;
		else
			Q <= C;
	end

endmodule  // hw1p1


/* Testbench for Homework 1 Problem 1 */
module hw1p1_testbench();

	logic S;
	logic x, y;
	logic clk, reset;
	
	hw1p1 dut (.S, .x, .y, .clk, .reset);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i, j;
	
		@(posedge clk); reset <= 1; {x, y} <= 0;
		@(posedge clk); reset <= 0;
		
		// Test s00, s10 transitions
		for (i = 0; i < 3; i=i+1) begin
			for (j = 0; j < 4; j=j+1) begin
				@(posedge clk); reset <= 0; {x, y} <= i;
				@(posedge clk); {x, y} <= j;
			end
			@(posedge clk); reset <= 1;
		end
		
		// Test s20 transitions
		for (i = 0; i < 4; i=i+1) begin
			@(posedge clk); reset <= 1;
			@(posedge clk); reset <= 0; {x, y} <= 2'b11;
			@(posedge clk); {x, y} <= i;
		end
		
		// Test sX1 transitions
		for (i = 0; i < 4; i=i+1) begin
			for (j = 0; j < 4; j=j+1) begin
				@(posedge clk); reset <= 1;
				@(posedge clk); reset <= 0; {x, y} <= 2'b11;
				@(posedge clk); {x, y} <= i;
				@(posedge clk); {x, y} <= j;
			end
		end
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		$stop;
	end  // initial
	
endmodule  // hw1p1_testbench