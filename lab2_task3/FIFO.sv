/*
 * Connor Aksama
 * 01/19/2023
 * CSE 371
 * Lab 2
*/

/**
 * FIFO Module to handle logic between the FIFO Controller and the physical RAM.
 
 * Inputs:
 * 	inputBus [8 (width) bit] - Data to enqueue in the buffer.
 *  read     [1 bit] - Signal to enable reading an element from the buffer. If raised and buffer is not empty, the least recent word is output on the outputBus, o.w. the outputBus is unchanged.
 *  write    [1 bit] - Signal to enable writing an element to the buffer. If raised and buffer is not full, the word on the inputBus is enqueued, o.w. the buffer is unchanged.
 *  reset    [1 bit] - Resets the FIFO buffer - removes all elements from the buffer.
 *  clk      [1 bit] - The clock to use for this module.
 
 * Outputs:
 * 	outputBus [8 (width) bit] - The data most recently dequeued from the buffer.
 *  empty     [1 bit] - This signal is raised when there are no elements in the buffer, and lowered otherwise.
 *  full      [1 bit] - This signal is raised when the buffer is at capacity, and lowered otherwise.
 *  error	  [1 bit] - This signal is raised when reading while the buffer is empty, or when writing while the buffer is full
*/
module FIFO #(
				  parameter depth = 4,
				  parameter width = 8
				  )(
					output logic empty, full, error
					,output logic [width-1:0] outputBus
					,input logic clk, reset
					,input logic read, write
					,input logic [width-1:0] inputBus
				   );
					
	logic [3:0] rdaddress;  // Read Address from Control module
	logic [3:0] wraddress;  // Write Address from Control module
	logic wren;  // Write enable from Control Module
	logic [width-1:0] outputBus_temp;  // Temporary read output from RAM
	
	// 16x8 RAM module instantiation
	// Inputs: sys clock, Data_In from user, Read Address, Write Address, Write Enable
	// Outputs: Data at Read Address -> outputBus_temp
	ram16x8 ram (.clock(clk), .data(inputBus), .rdaddress, .wraddress, .wren, .q(outputBus_temp));

	
	// FIFO Control Module
	// Inputs: sys clock, read signal from user, write from user
	// Outputs: Write Enable, Empty/Full/Error, Read Address, Write Address
	FIFO_Control #(depth) FC (.clk, .reset, 
									  .read, 
									  .write, 
									  .wr_en(wren),
									  .empty,
									  .full,
									  .error,
									  .readAddr(rdaddress), 
									  .writeAddr(wraddress)
									 );
									 
	always_ff @(posedge clk) begin
		// Change outputBus only if valid read is raised
		if (read & ~empty) outputBus <= outputBus_temp;
		else 		 outputBus <= outputBus;
	end
	
endmodule  // FIFO

// Module to test the functionality of the FIFO module
`timescale 1 ps / 1 ps
module FIFO_testbench();
	
	parameter depth = 4, width = 8;
	
	logic clk, reset;
	logic read, write;
	logic [width-1:0] inputBus;
	logic empty, full, error;
	logic [width-1:0] outputBus;
	
	FIFO #(depth, width) dut (.*);
	
	parameter CLK_Period = 100;
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) reset <= 1; write <= 0; read <= 0; inputBus <= 0;

		// Write to queue until full, try to write while full
		@(posedge clk) write <= 1; reset <= 0;
		for (i = 0; i < 25; i++) begin
			@(posedge clk) inputBus <= (i << 4);
		end

		// Read from queue until empty, try to read while empty
		@(posedge clk) write <= 0; read <= 1;
		for (i = 24; i >= 0; i--) begin
			@(posedge clk);
		end

		// Write some elements
		@(posedge clk) write <= 1; read <= 0;
		for (i = 0; i < 5; i++) begin
			@(posedge clk) inputBus <= i;
		end

		// Reset
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		@(posedge clk);
		@(posedge clk);
		
		$stop;
	end
	
endmodule  // FIFO_testbench