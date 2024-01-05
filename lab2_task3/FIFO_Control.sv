/*
 * Connor Aksama
 * 01/19/2023
 * CSE 371
 * Lab 2
*/

/**
 * FIFO Control Module to handle logic of what and when to read/write from the RAM given user inputs.
 
 * Inputs:
 *  read  [1 bit] - Signal to enable reading an element from the buffer. If raised and buffer is not empty, the next address to read is output on readAddr
 *  write [1 bit] - Signal to enable writing an element to the buffer. If raised and buffer is not full, the next address to write is output on writeAddr
 *  reset [1 bit] - Resets the FIFO buffer - removes all elements from the buffer.
 *  clk   [1 bit] - The clock to use for this module.
 
 * Outputs:
 * 	readAddr  [4 (depth) bit] - The next address to read from in the RAM.
 *  writeAddr [4 (depth) bit] - The next address to write to in the RAM.
 *  empty     [1 bit] - This signal is raised when there are no elements in the buffer, and lowered otherwise.
 *  full      [1 bit] - This signal is raised when the buffer is at capacity, and lowered otherwise.
 *  error	  [1 bit] - This signal is raised when reading while the buffer is empty, or when writing while the buffer is full
 *  wr_en     [1 bit] - This signal is raised when data should be written to the location specified by writeAddr, and lowered otherwise.
*/
module FIFO_Control #(
							 parameter depth = 4
							 )(
								output  logic wr_en
								,output logic empty, full, error
								,output logic [depth-1:0] readAddr, writeAddr
								,input  logic clk, reset
								,input  logic read, write
							  
							  );
	
	logic [4:0] fifo_size;  // Number of elements in the buffer
	logic read_reg, write_reg;  // Registered read/write inputs
	logic dead;  // Temporary variable for five bit counter output
	
	// Counter to store current Read Address in RAM
	// Inputs: Increment signal -> read detected and not empty
	// Outputs: Count -> Read Address
	fiveb_counter read_ptr  (.count({dead, readAddr}), .inc(read_reg & ~empty), .dec(0), .clk, .reset);
	
	// Counter to store current Write Address in RAM
	// Inputs: Increment signal -> write detected and not full
	// Outputs: Count -> Write Address
	fiveb_counter write_ptr (.count({dead, writeAddr}), .inc(write_reg & ~full), .dec(0), .clk, .reset);
	
	// Counter to store number of elements in buffer
	// Inputs: Increment signal -> write detected and not full; Decrement signal -> read detected and not empty
	// Outputs: Count -> FIFO Size
	fiveb_counter num_elts (.count(fifo_size), .inc(write_reg & ~full), .dec(read_reg & ~empty), .clk, .reset);
	
	// Compare against FIFO size
	assign empty = fifo_size == '0;
	assign full  = fifo_size == (depth ** 2);
	// Check for invalid read/writes
	assign error = (read_reg & empty) | (write_reg & full);
	
	// Enable write if write detected and not full
	assign wr_en = write_reg & ~full;
	
	always_ff @(posedge clk) begin
		// Register read/write inputs
		read_reg <= read;
		write_reg <= write;
	end

endmodule  // FIFO_Control

// Module to test the functionality of the FIFO_Control module
`timescale 1 ps / 1 ps
module FIFO_Control_testbench();

	parameter depth = 4;

	logic wr_en;
	logic empty, full, error;
	logic [depth-1:0] readAddr, writeAddr;
	logic clk, reset;
	logic read, write;

	FIFO_Control #(depth) dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= 1; write <= 0; read <= 0;

		// Write until full, try writing while full
		@(posedge clk) write <= 1; reset <= 0;
		for (i = 0; i < 25; i++) begin
			@(posedge clk);
		end

		// Read until empty, try reading while empty
		@(posedge clk) read <= 1; write <= 0;
		for (i = 0; i < 25; i++) begin
			@(posedge clk);
		end

		// Write some elements
		@(posedge clk) write <= 1; read <= 0;
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end

		// Reset
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		@(posedge clk);
		@(posedge clk);
		
		$stop;
	end

endmodule  // FIFO_Control_testbench