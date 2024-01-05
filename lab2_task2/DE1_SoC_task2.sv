/*
 * Connor Aksama
 * 01/19/2023
 * CSE 371
 * Lab 2
*/

/**
 * Top-level module for Lab 2 Task 2. Instantiates a 32x4 RAM module and connects I/O to board peripherals
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX2 [7 bit] - Data to show on the HEX2 display, formatted in standard 7 segment display format.
 * 	HEX3 [7 bit] - Data to show on the HEX3 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.
*/
module DE1_SoC #(
	parameter which_clock = 25
	)
	(
	output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	,input logic [9:0] SW
	,input logic [3:0] KEY
	,input logic CLOCK_50
	);

	// Clock divider to cycle through reading RAM addresses
	// Divides the 50 MHz clock into an array of divided clocks (clk)
	logic [31:0] clk;
	clock_divider clk_div (.clock(CLOCK_50), .divided_clocks(clk));
	
	// Aliases for peripherals and RAM output
	logic	[3:0] data;  // Data_In
	logic	[4:0] rdaddress;  // Read Address
	logic	[4:0] wraddress;  // Write Address
	logic wren;  // Write Enable
	logic [3:0] q;  // RAM Data_Out
	logic reset;
	
	// Assign peripherals to aliases
	assign reset = ~KEY[0];
	assign wren = ~KEY[3];
	assign wraddress = SW[8:4];
	assign data = SW[3:0];
	
	// 32x4 RAM Module
	// Inputs: 50 MHz sys. clock, Data_In, Read Address, Write Address, Write Enable
	// Outputs: q -> RAM Data_Out
	ram32x4 ram (.clock(CLOCK_50), .data, .rdaddress, .wraddress, .wren, .q);
	
	// HEX Display for RAM Data_Out
	double_seg7 q_display (.HEX0(HEX0), .HEX1(), .num(q));
	
	// HEX Display for Read Address
	double_seg7 rdaddress_display (.HEX0(HEX2), .HEX1(HEX3), .num(rdaddress));
	
	// HEX Display for Write Address
	double_seg7 wraddress_display (.HEX0(HEX4), .HEX1(HEX5), .num(wraddress));
	
	// HEX Display for Data_In
	double_seg7 data_display (.HEX0(HEX1), .HEX1(), .num(data));
	
	// Counter to cycle through RAM addresses, runs on divided clock
	// Output count to Read Address
	fiveb_counter counter (.count(rdaddress), .inc(1), .dec(0), .clk(clk[which_clock]), .reset);

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

/**
 * Identical to DE1_SoC module, without clock division. Used for testing purposes.
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX2 [7 bit] - Data to show on the HEX2 display, formatted in standard 7 segment display format.
 * 	HEX3 [7 bit] - Data to show on the HEX3 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.
*/
`timescale 1 ps / 1 ps
module DE1_SoC_task2_testmodule 
	(
	output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	,input logic [9:0] SW
	,input logic [3:0] KEY
	,input logic CLOCK_50
	);
	
	// Aliases for peripherals and RAM output
	logic	[3:0] data;  // Data_In
	logic	[4:0] rdaddress;  // Read Address
	logic	[4:0] wraddress;  // Write Address
	logic wren;  // Write Enable
	logic [3:0] q;  // RAM Data_Out
	logic reset;
	
	// Assign peripherals to aliases
	assign reset = ~KEY[0];
	assign wren = ~KEY[3];
	assign wraddress = SW[8:4];
	assign data = SW[3:0];
	
	// 32x4 RAM Module
	// Inputs: 50 MHz sys. clock, Data_In, Read Address, Write Address, Write Enable
	// Outputs: q -> RAM Data_Out
	ram32x4 ram (.clock(CLOCK_50), .data, .rdaddress, .wraddress, .wren, .q);
	
	// HEX Display for RAM Data_Out
	double_seg7 q_display (.HEX0(HEX0), .HEX1(), .num(q));
	
	// HEX Display for Read Address
	double_seg7 rdaddress_display (.HEX0(HEX2), .HEX1(HEX3), .num(rdaddress));
	
	// HEX Display for Write Address
	double_seg7 wraddress_display (.HEX0(HEX4), .HEX1(HEX5), .num(wraddress));
	
	// HEX Display for Data_In
	double_seg7 data_display (.HEX0(HEX1), .HEX1(), .num(data));
	
	// Counter to cycle through RAM addresses, runs on sys clock
	// Output count to Read Address
	fiveb_counter counter (.count(rdaddress), .inc(1), .dec(0), .clk(CLOCK_50), .reset);

endmodule  // DE1_SoC_task2_testmodule

// Module to test the functionality of the lab2_task2 module
module DE1_SoC_task2_testbench();

	logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic clk;

	logic [4:0] wraddress;
	logic [3:0] data;
	logic reset, wren;

	assign SW[8:4] = wraddress;
	assign SW[3:0] = data;
	assign KEY[0] = ~reset;
	assign KEY[3] = ~wren;

	DE1_SoC_task2_testmodule dut (.HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0, .SW, .KEY, .CLOCK_50(clk));

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;

		// Read every address
		@(posedge clk) reset <= 1; wraddress <= 0; data <= 0; wren <= 0;
		@(posedge clk) reset <= 0;
		for (i = 0; i < 32; i++) begin
			@(posedge clk);
		end

		// Write to every address
		@(posedge clk) wren <= 1; wraddress <= 0; data <= 0;
		for (i = 0; i < 32; i++) begin
			@(posedge clk) wraddress <= i; data <= i;
		end

		// Read every address
		@(posedge clk) wren <= 0;
		for (i = 0; i < 32; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  // DE1_SoC_task2_testbench