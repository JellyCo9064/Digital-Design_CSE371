/*
 * Connor Aksama
 * 01/19/2023
 * CSE 371
 * Lab 2
*/

/**
 * Top-level module for Lab 2 Task 3. Instantiates a 16x8 RAM module, FIFO Controller, and connects I/O to board peripherals
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.
*/
module DE1_SoC  #(
	parameter depth = 4
	,parameter width = 8
	)
	(
	output logic [6:0] HEX5, HEX4, HEX1, HEX0
	,output logic [9:0] LEDR
	,input logic [9:0] SW
	,input logic [3:0] KEY
	,input logic CLOCK_50
	);
	
	logic [width-1:0] output_data;
	
	// HEX display for FIFO output
	double_seg7 output_data_display (.HEX0(HEX0), .HEX1(HEX1), .num(output_data));
	
	// HEX display for input data
	double_seg7 input_data_display (.HEX0(HEX4), .HEX1(HEX5), .num(SW[7:0]));
	
	// FIFO Module
	// Inputs: read/write from KEYs, input data from SW[7:0]
	// Outputs: output element line from outputBus; empty/full/error signals -> LEDRs
	FIFO #(depth, width) fifo  (
										.empty(LEDR[8])
										, .full(LEDR[9])
										, .error(LEDR[0])
										, .outputBus(output_data)
										, .clk(CLOCK_50)
										, .reset(~KEY[3])
										, .read(~KEY[0])
										, .write(~KEY[1])
										, .inputBus(SW[7:0])
										);
	
endmodule  // DE1_SoC

// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (
  input   logic        clock
  ,output logic [31:0] divided_clocks
  );

  initial begin
    divided_clocks = '0;
  end

  always_ff @(posedge clock) begin
    divided_clocks <= divided_clocks + 'd1;
  end

endmodule  // clock_divider

// Module to test the functionality of the DE1_SoC module
`timescale 1 ps / 1 ps
module DE1_SoC_task3_testbench();
	parameter depth = 4;
	parameter width = 8;

	logic [6:0] HEX5, HEX4, HEX1, HEX0;
	logic [9:0] LEDR;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic clk;

	logic write, read, reset;
	logic [width-1:0] inputBus;

	assign KEY[1] = ~write;
	assign KEY[0] = ~read;
	assign KEY[3] = ~reset;
	assign SW[7:0] = inputBus;

	DE1_SoC #(depth, width) dut (.HEX5, .HEX4, .HEX1, .HEX0, .LEDR, .SW, .KEY, .CLOCK_50(clk));

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= 1;

		// Write to queue until full, try to write while full
		@(posedge clk) write <= 1; read <= 0; reset <= 0; inputBus <= 0;
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

endmodule  // DE1_SoC_task3_testbench