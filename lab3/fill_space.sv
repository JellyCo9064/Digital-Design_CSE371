/*
 * Connor Aksama
 * 01/30/2023
 * CSE 371
 * Lab 3
*/

/**
 * Cycles through each pixel on a screen with the size of the parameterized dimensions.
 * Ex. (0,0) -> (1,0) -> (2,0) -> ... -> (638,479) -> (639, 479) -> (0,0)
 * Outputs a new pixel on each clock cycle. 
 
 * Inputs:
 * 	clk [1 bit] - the clock to use for this module
*	reset [1 bit] - the reset signal for this module; resets to point (0,0)
 
 * Outputs:
 * 	x [10 bit] - The x coordinate of the pixel to draw to
 *  y [9 bit] - The y coordinate of the pixel to draw to
*/
module fill_space #(
	parameter width = 640, height = 480
	)
	(
	output logic [9:0] x
	,output logic [8:0] y
	,input logic clk, reset
	);
	
	logic [9:0] x_d, x_q;
	logic [8:0] y_d, y_q;
	
	assign x = x_q;
	assign y = y_q;
	
	// Determine next coordinate
	always_comb begin
		if (x_q >= width - 1 && y_q >= height - 1) begin
			// Reached x max and y max
			x_d = 0;
			y_d = 0;
		end else if (x_q >= width - 1) begin
			// Reached x max
			x_d = 0;
			y_d = y_q + 1;
		end else begin
			// Reached y max
			x_d = x_q + 1;
			y_d = y_q;
		end
	end
	
	// Register outputs
	always_ff @(posedge clk) begin
		if (reset) begin
			x_q <= 0;
			y_q <= 0;
		end else begin
			x_q <= x_d;
			y_q <= y_d;
		end
	end
	
endmodule  // fill_space

// Module to test the functionality of the fill_space module
module fill_space_testbench();

	logic [9:0] x;
	logic [8:0] y;
	logic clk, reset;
	
	fill_space #(4,5) dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		
		// Run through each pixel in the screen
		for (i = 0; i < 50; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end

endmodule  // fill_space_testbench
