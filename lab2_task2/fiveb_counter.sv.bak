/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/**
 * A five-bit increment/decrement counter. Overflows to 5'b00000; underflows to 5'11111.
 * reset takes precedence; if inc and dec are simultaneously raised, count is unchanged.
 * Inputs:
 * 	inc [1 bit] - Increments the count by 1 when raised. Does nothing if signal is low.
 * 	dec [1 bit] - Decrements the count by 1 when raised. Does nothing if signal is low.
 * 	clk [1 bit] - The clock to use for this module.
 * 	reset [1 bit] - Resets the counter to 0 when raised. Does nothing if signal is low.

 * Outputs:
 *		count [5 bit] - The count of this counter.
 */
module fiveb_counter(
	output logic [4:0] count
	,input logic inc, dec, clk, reset
	);

	// Handles increment/decrement/reset operations
	always_ff @(posedge clk) begin
	
		if (reset)
			count <= 5'b0;
		else if (inc & ~dec)
			count <= count + 5'b1;
		else if (dec & ~inc)
			count <= count - 5'b1;
	
	end
	
endmodule  // fiveb_counter

/*
 * Tests the functionality of the fiveb_counter module.
*/
module fiveb_counter_testbench();

	logic [4:0] count;
	logic inc, dec, clk, reset;
	
	fiveb_counter dut (.count, .inc, .dec, .clk, .reset);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever  #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0; inc <= 0; dec <= 0;
		
		// Increment counter from 0 to max, then past max
		@(posedge clk) inc <= 1;
		for (i = 0; i < 40; i++) begin
			@(posedge clk);
		end
		
		// Hold counter constant
		@(posedge clk) inc <= 0;		
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		// Decrement counter below 0, then max to 0, etc.
		@(posedge clk) dec <= 1;
		for (i = 0; i < 45; i++) begin
			@(posedge clk);
		end
		
		// Hold counter constant
		@(posedge clk) dec <= 0;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		// reset to 0
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		
		@(posedge clk)
		@(posedge clk)
		
		$stop;
	end
	
endmodule  // fiveb_counter_testbench
