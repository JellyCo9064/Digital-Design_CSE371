/*
 * Connor Aksama
 * 01/30/2023
 * CSE 371
 * Lab 3
*/

/**
 * Given two endpoints (x0, y0), (x1, y1), outputs a sequence of points (x,y) that connect the two points.
 * Outputs at most one new point (x,y) every clock cycle starting on the cycle after the input endpoints change.
 
 * Inputs:
 * 	clk [1 bit] - the clock to use for this module
 *	reset [1 bit] - the reset signal for this module; resets algorithm to first iteration given inputs
 * 	x0 [10 bit] - The x coordinate of the first point of the line to draw
 *  y0 [9 bit] - The y coordinate of the first point of the line to draw 
 *	x1 [10 bit] - The x coordinate of the second point of the line to draw 
 *	y1 [9 bit] - The y coordinate of the second point of the line to draw 

 * Outputs:
 * 	x [10 bit] - The x coordinate of the current pixel to draw
 *  y [9 bit] - The y coordinate of the current pixel to draw
*/
module line_drawer(
	input logic clk, reset,
	
	// x and y coordinates for the start and end points of the line
	input logic [9:0] x0, x1, 
	input logic [8:0] y0, y1,

	//outputs cooresponding to the coordinate pair (x, y)
	output logic [9:0] x,
	output logic [8:0] y 
	);
	
	// Bresenham error
	logic signed [11:0] error, p_error, n_error;

	// Temp swap logic
	logic signed [9:0] x_min, x_max, y_start,  y_end;
	logic signed [9:0] x0_r, x1_r, y0_r, y1_r;
	// Bresenham temp calculations
	logic is_steep, is_steep_r;
	logic signed [10:0] delta_x;
	logic signed [10:0] delta_y;
	logic signed [9:0] step;

	// Registered output
	logic signed [9:0] px, nx;
	logic signed [8:0] py, ny;
	logic [9:0] prev_x0, prev_x1;
	logic [8:0] prev_y0, prev_y1;

	// Compute initial values before entering main loop
	always_comb begin
	
		delta_x = x1 - x0;
		delta_y = y1 - y0;

		is_steep = (delta_y < 0 ? -delta_y : delta_y) > (delta_x < 0 ? -delta_x : delta_x);

		if (is_steep) begin
			// Swap x, y
			x0_r = y0;
			y0_r = x0;
			x1_r = y1;
			y1_r = x1;
		end else begin
			x0_r = x0;
			x1_r = x1;
			y0_r = y0;
			y1_r = y1;
		end

		if (x0_r > x1_r) begin
			// swap p0, p1
			x_min = x1_r;
			x_max = x0_r;
			y_start = y1_r;
			y_end = y0_r;
		end else begin
			x_min = x0_r;
			x_max = x1_r;
			y_start = y0_r;
			y_end = y1_r;
		end

		delta_x = x_max - x_min;
		delta_y = (y_end - y_start < 0 ? -(y_end - y_start) : y_end - y_start);
		error = -(delta_x / 2);

		if (y_start < y_end) step = 1;
		else 			     step = -1;
		
		if (p_error + delta_y >= 0 && px < x_max) begin
			// Step x and y, compute next error
			ny = py + step;
			nx = px + 1;
			n_error = p_error + delta_y - delta_x;
		end else if (px < x_max) begin
			// Step x, compute next error
			ny = py;
			nx = px + 1;
			n_error = p_error + delta_y;
		end else begin
			// Reached end of line, keep outputting same point
			nx = px;
			ny = py;
			n_error = p_error;
		end

		if (is_steep_r) begin
			// Swap x,y
			x = py;
			y = px;
		end else begin
			x = px;
			y = py;
		end

	end

	// Update new values of current x,y in main loop
	always_ff @(posedge clk) begin
		prev_x0 <= x0;
		prev_x1 <= x1;
		prev_y0 <= y0;
		prev_y1 <= y1;
		is_steep_r <= is_steep;
		
		if (reset || prev_x0 != x0 || prev_y0 != y0 || prev_x1 != x1 || prev_y1 != y1) begin
			// Reset initial values to input if input changes or reset
			px <= x_min;
			py <= y_start;
			p_error <= error;
		end else begin
			// Output computed next values
			px <= nx;
			py <= ny;
			p_error <= n_error;
		end

	end
     
endmodule  // line_drawer

// Module to test the functionality of the line_drawer module
module line_drawer_testbench();

	logic clk, reset;
	
	logic [9:0]	x0, x1;
	logic [8:0] y0, y1;

	logic [9:0] x;
	logic [8:0] y;

	line_drawer dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD  / 2) clk <= ~clk;
	end

	initial begin
		integer i;

		@(posedge clk) reset <= 1; x0 <= 0; y0 <= 0; x1 <= 0; y1 <= 0;

		// Horizontal
		@(posedge clk) reset <= 0; x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 0;
		for (i = 0; i < 20; i++) begin
			@(posedge clk);
		end

		// Vertical
		@(posedge clk) x0 <= 0; y0 <= 0; x1 <= 0; y1 <= 10;
		for (i = 0; i < 20; i++) begin
			@(posedge clk);
		end

		// Diagonal
		@(posedge clk) x0 <= 0; y0 <= 0; x1 <= 5; y1 <= 5;
		for (i = 0; i < 20; i++) begin
			@(posedge clk);
		end

		// Shallow
		@(posedge clk) x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 2;
		for (i = 0; i < 20; i++) begin
			@(posedge clk);
		end

		// Steep
		@(posedge clk) x0 <= 0; y0 <= 0; x1 <= 2; y1 <= 10;
		for (i = 0; i < 20; i++) begin
			@(posedge clk);
		end

		$stop;
	end

endmodule  // line_drawer_testbench
