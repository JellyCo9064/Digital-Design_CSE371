/*
 * Connor Aksama
 * 01/30/2023
 * CSE 371
 * Lab 3
*/

/**
 * A thirty two-bit increment/decrement counter. Overflows to 8'h0; underflows to 8'hFFFF_FFFF.
 * reset takes precedence; if inc and dec are simultaneously raised, count is unchanged.
 * Inputs:
 * 	inc [1 bit] - Increments the count by 1 when raised. Does nothing if signal is low.
 * 	dec [1 bit] - Decrements the count by 1 when raised. Does nothing if signal is low.
 * 	clk [1 bit] - The clock to use for this module.
 * 	reset [1 bit] - Resets the counter to 0 when raised. Does nothing if signal is low.

 * Outputs:
 *		count [32 bit] - The count of this counter.
 */
module counter_32b(
	output logic [31:0] count
	,input logic inc, dec, clk, reset
	);

	// Handles increment/decrement/reset operations
	always_ff @(posedge clk) begin
	
		if (reset)
			count <= 32'b0;
		else if (inc & ~dec)
			count <= count + 32'b1;
		else if (dec & ~inc)
			count <= count - 32'b1;
	
	end
	
endmodule  // counter_32b

// Module to test the functionality of the counter_32b module
module counter_32b_testbench();

	logic [31:0] count;
	logic inc, dec, clk, reset;
	
	counter_32b dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;

		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0; inc <= 1; dec <= 0;
		for (i = 0; i < 40; i++) begin
			@(posedge clk);
		end

		@(posedge clk) reset <= 0; inc <= 0; dec <= 1;
		for (i = 0; i < 50; i++) begin
			@(posedge clk);
		end
		
		@(posedge clk) reset <= 0; inc <= 1; dec <= 0;
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end

endmodule  // counter_32b_testbench
