/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Top-level module for Lab 4 Task 2. Instantiates binary search module and connects I/O to peripherals.
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	LEDR [10 bit] - Signal to output to 10 onboard LEDs, respectively.
*/
module DE1_SoC_task2 (
    output logic [6:0] HEX0, HEX1
    ,output logic [9:0] LEDR
    ,input logic [9:0] SW
    ,input logic [3:0] KEY
    ,input logic CLOCK_50
    );
	 
	 assign LEDR[7:0] = 8'b0;

	// Seven-Segment display
	// In: num
	// Out: HEX0, HEX1
	logic [7:0] index;
	double_seg7 addr (
          .HEX0(HEX0)
         ,.HEX1(HEX1)
         ,.num(index)
    );

	// Binary search module
	// In: num (switch input), start (switch), clk, reset (key)
	// Out: index (final answer), found (success), not_found (failure)
    binary_search bs (
         .index(index)
        ,.found(LEDR[9])
        ,.not_found(LEDR[8])
        ,.num(SW[7:0])
        ,.start(SW[9])
        ,.clk(CLOCK_50)
        ,.reset(~KEY[0])
    );

endmodule  // DE1_SoC_task2

/*
 * Testbench to test the functionality of the DE1_SoC_task2 module
 */
`timescale 1 ps / 1 ps
module DE1_SoC_task2_testbench();

    logic [6:0] HEX0, HEX1;
    logic [9:0] LEDR;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic CLOCK_50, clk;
	 
	 assign CLOCK_50 = clk;
	 
	 DE1_SoC_task2 dut (.*);
	 
	 parameter CLOCK_PERIOD = 100;
	 initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	 end
	 
	 initial begin
		integer i;
		
		// Load num
		@(posedge clk) KEY[0] <= 1'b0; SW[9] <= 1'b0; SW[7:0] <= 8'b00001011;
		@(posedge clk) KEY[0] <= 1'b1;
		@(posedge clk);
		@(posedge clk);
		// Start
		@(posedge clk) SW[9] <= 1'b1;
		// Search
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		
		// Load
		@(posedge clk) SW[9] <= 1'b0; SW[7:0] <= 8'b00110111;
		@(posedge clk);
		@(posedge clk);
		// Start
		@(posedge clk) SW[9] <= 1'b1;
		// Search
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  // DE1_SoC_task2_testbench
