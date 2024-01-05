/* down counting circuit for use in homework 4.
 *
 * Inputs:
 *   R     - input to load into counter
 *   Clock - should be connected to a 50 MHz clock
 *   E     - enable signal to decrement count
 *   L     - signal to load new value
 *
 * Outputs:
 *   Q     - current count
 *
 * Parameters:
 *   n     - bit-length of count
 */
module downcount (R, Clock, E, L, Q);
	parameter n = 8;
	input [n-1:0] R;
	input Clock, L, E;
	output logic [n-1:0] Q;

	always @(posedge Clock)
		if (L)
			Q <= R;
		else if (E)
			Q <= Q + '1;

endmodule

module downcount_testbench();

	parameter n = 3;

	logic [n-1:0] R, Q;
	logic Clock, L, E, clk;
	
	assign Clock = clk;
	
	downcount #(.n(n)) dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) R <= 3'd7; L <= 1'b1; E <= 1'b0;
		@(posedge clk) L <= 1'b0;
		
		for (i = 0; i < 5; i++) begin
			@(posedge clk) E <= 1'b1;
			@(posedge clk) E <= 1'b0;
			@(posedge clk);
		end
		
		$stop;
	end


endmodule  // downcount_tesbench