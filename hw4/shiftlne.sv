/* left shift register for use in homework 4.
 *
 * Inputs:
 *   R      - input to load into register
 *   L      - signal to load new value
 *   E      - enable signal to shift bits
 *   w      - new bit to shift into register
 *   Clock  - should be connected to a 50 MHz clock
 *
 * Outputs:
 *   Q     - current stored value
 *
 * Parameters:
 *   n     - bit-length of register
 */
module shiftlne (R, L, E, w, Clock, Q);
	parameter n = 4;
	input [n-1:0] R;
	input L, E, w, Clock;
	output logic [n-1:0] Q;
	integer k;

	always_ff @(posedge Clock)
	begin
		if (L)
			Q <= R;
		else if (E)
			begin
				// CHANGE: Changed from right shifter to left shifter
				Q[0] <= w;
				for (k = n-2; k >= 0; k = k-1)
					Q[k+1] <= Q[k];
			end
	end

endmodule

module shiftlne_testbench();

	parameter n = 4;
	
	logic [n-1:0] R, Q;
	logic L, E, w, Clock, clk;
	
	assign Clock = clk;
	
	shiftlne #(.n(n)) dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) R <= 4'b1101; L <= 1'b1; E <= 1'b0; w <= 1'b0;
		@(posedge clk) L <= 1'b0;
		
		for (i = 0; i < 5; i++) begin
			@(posedge clk) E <= 1'b1; w <= 1'b0;
			@(posedge clk) E <= 1'b0;
			@(posedge clk) E <= 1'b1; w <= 1'b1;
			@(posedge clk);
		end
		
		
		$stop;
	end

endmodule