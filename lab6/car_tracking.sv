/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * Controller module for the car tracking system.
 
 * Inputs:
 *		wr_num [16 bit] - The number of cars to track for the current hour
 *		wr_hour [3 bit] - The hour for which to update the number of cars
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the cyclic display to hour 0.
 
 * Outputs:
 *      curr_num [16 bit] - The number of cars that have entered in the corresponding hour
 *      curr_hour [3 bit] - The hour at which the corresponding number of cars have entered
*/
module car_tracking #(
		parameter clk_freq = 50000000, duration_sec = 1
	)(
		output logic [15:0] curr_num
		,output logic [2:0] curr_hour
		,input logic [15:0] wr_num
		,input logic [2:0] wr_hour
		,input logic clk, reset
	);
	
	localparam timer_target = clk_freq * duration_sec;
	
	logic [2:0] rd_addr, rd_out1;
	logic [31:0] timer;
	logic reset_timer;
	
	// RAM module for car tracking data
	// clk -> clock
	// wr_num -> data
	// rd_addr (current hour to read) -> rdaddress
	// wr_hour (current hour to modify) -> wraddress
	// wren -> always write
	// q -> curr_num (current num of cars)
	ram8x16 ram (
		.clock(clk)
		,.data(wr_num)
		,.rdaddress(rd_addr)
		,.wraddress(wr_hour)
		,.wren('1)
		,.q(curr_num)
	);
	
	always_comb begin
		// Reset timer at target
		reset_timer = (timer >= timer_target - 1);
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			// Reset cycle to beginning
			rd_addr <= '0;
			rd_out1 <= '0;
			timer <= '0;
		end else if (reset_timer) begin
			// Reset timer, move to next hour
			timer <= '0;
			rd_addr <= rd_addr + 3'd1;
		end else begin
			// Increment timer
			timer <= timer + 32'd1;
		end
		
		// Sync with RAM output
		curr_hour <= rd_addr;
	end
	
endmodule  // car_tracking

/*
 * Testbench to test the functionality of the car_tracking module
 */
`timescale 1 ps / 1 ps
module car_tracking_testbench();

	logic [15:0] curr_num;
	logic [2:0] curr_hour;
	
	logic [15:0] wr_num;
	logic [2:0] wr_hour;
	logic clk, reset;
	
	car_tracking #(.clk_freq(2), .duration_sec(1)) dut (.*);
	
		parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= '0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= '1; wr_num <= '0; wr_hour <= '0;
		@(posedge clk) reset <= '0;
		
		// Write data to RAM
		for (i = 0; i < 10; i++) begin
			@(posedge clk) wr_hour <= i;
			if (i % 2 == 0) begin
				wr_num <= wr_num + 15'd1;
			end
		end
		
		// Cycle through values
		for (i = 0; i < 30; i++) begin
			@(posedge clk);
		end

		
		$stop;
	end

endmodule  // car_tracking_testbench