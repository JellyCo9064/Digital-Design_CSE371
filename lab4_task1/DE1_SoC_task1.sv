/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Top-level module for Lab 4 Task 1. Instantiates binary search module and connects I/O to peripherals.
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	LEDR [10 bit] - Signal to output to 10 onboard LEDs, respectively.
*/
module DE1_SoC_task1 (
    output logic [6:0] HEX0
    ,output logic [9:0] LEDR
    ,input logic [3:0] KEY
    ,input logic [9:0] SW
    ,input logic CLOCK_50
    );
	
    // Bit counting module
    // In: num, start, clk, reset
    // Out: result, done
    logic [3:0] result;
    bit_counter bc (
         .result(result)
		,.num(SW[7:0])
        ,.done(LEDR[9])
        ,.start(SW[9])
        ,.clk(CLOCK_50)
        ,.reset(~KEY[0]) 
    );

    // Seven-Segment display
    // In: num
    // Out: HEX0, HEX1(unused)
    double_seg7 res_display (.HEX0(HEX0), .HEX1(), .num({4'b0, result}));
	
endmodule  // DE1_SoC_task1

/*
 * Testbench to test the functionality of the DE1_SoC_task1 module.
 */
module DE1_SoC_task1_testbench();

    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic CLOCK_50, clk;
	
    assign CLOCK_50 = clk;
	
	 DE1_SoC_task1 dut (.*);
	
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk;
    end

    initial begin
        integer i;

        // Load value
        @(posedge clk) KEY[0] <= 1'b0; SW[7:0] <= 8'b10000001; SW[9] <= 0;
        @(posedge clk); KEY[0] <= 1'b1;
        // Start count
        @(posedge clk) SW[9] <= 1;

        for (i = 0; i < 16; i++) begin
            @(posedge clk);
        end
        // Load value
        @(posedge clk) SW[9] <= 0; SW[7:0] <= 8'b0;
        @(posedge clk);
        // Start count
        @(posedge clk) SW[9] <= 1;
        for (i = 0; i < 5; i++) begin
            @(posedge clk);
        end
        
        @(posedge clk);
        @(posedge clk);

        $stop;
    end

endmodule  // DE1_SoC_task1_testbench
