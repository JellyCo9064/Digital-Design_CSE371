/*
 * Connor Aksama
 * 01/18/2023
 * CSE 371
 * Lab 2
*/

/**
 * Top-level module for Lab 2 Task 1. Instantiates a 32x4 RAM module and connects I/O to board peripherals
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX2 [7 bit] - Data to show on the HEX2 display, formatted in standard 7 segment display format.
 * 	HEX3 [7 bit] - Data to show on the HEX3 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.
*/
module DE1_SoC(
    output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
    ,input logic [9:0] SW
    ,input logic [3:0] KEY
    );

    // Turn off HEX3 and HEX1
    assign HEX3 = ~7'b0;
    assign HEX1 = ~7'b0; 

    // Use KEY0 as system clock
    logic SYS_CLOCK;
    assign SYS_CLOCK = KEY[0];

    logic [3:0] data_in, data_out;
    logic [4:0] addr;
    logic write;

    assign data_in = SW[3:0];  // SW3-0 specifies input data
    assign addr = SW[8:4];     // SW8-4 specifies adddress
    assign write = SW[9];      // SW9 is write signal

    // Connect RAM input ports to SW inputs
    // Store RAM output in local logic
    ram r (.data_out, .addr, .data_in, .write(write), .clk(SYS_CLOCK));

    // Display address on HEX4-5
    double_seg7 addr_display (.HEX0(HEX4), .HEX1(HEX5), .num({3'b0, addr}));

    // Display data_in on HEX2
    double_seg7 data_in_display (.HEX0(HEX2), .HEX1(), .num({4'b0, data_in}));

    // Display data_out on HEX0
    double_seg7 data_out_display(.HEX0(HEX0), .HEX1(), .num({4'b0, data_out}));

endmodule

// Module to test the functionality of the DE1_SoC module
module DE1_SoC_task1_testbench();

    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic [9:0] SW;
    logic [3:0] KEY;

    DE1_SoC dut (.HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0, .SW, .KEY);

    logic write, clk;
	 logic [3:0] data_in;
	 logic [4:0] addr;
    assign KEY[0] = clk;
    assign SW[9] = write;
    assign SW[3:0] = data_in;
    assign SW[8:4] = addr;

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk;
    end

    initial begin
        integer i;

        // Write to every address in the RAM
        @(posedge clk) write <= 1; addr <= 0; data_in <= 0;
        for (i = 0; i < 32; i++) begin
            @(posedge clk) addr <= i; data_in <= i;
				@(posedge clk);
				@(posedge clk);
        end

        // Read from every address in the RAM
        @(posedge clk) write <= 0;
        for (i = 0; i < 32; i++) begin
            @(posedge clk) addr <= i;
				@(posedge clk);
				@(posedge clk);
        end
		  
		  $stop;
    end

endmodule
