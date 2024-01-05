/* Module for EE/CSE371 Homework 1 Problem 2.
 * An arbitrary Mealy FSM.
 */
module hw1p2 (
	output logic out
	,input logic in, clk, reset
	);
	
	typedef enum {s000, s001, s010, s011, s100} state;
	
	state ps, ns;
	
	// handle state transitions
	always_comb begin
		case (ps)
			s000: begin
				ns = in ? s100 : s011;
				out = in;
			end
			s001: begin
				ns = in ? s100 : s001;
				out = in;
			end
			s010: begin
				ns = in ? s000 : s010;
				out = in;
			end
			s011: begin
				ns = in ? s010 : s001;
				out = in;
			end
			s100: begin
				ns = in ? s011 : s010;
				out = 0;
			end
		endcase
	end
	
	// update present state on clock edge
	always_ff @(posedge clk) begin
		if (reset)
			ps <= s000;
		else
			ps <= ns;
	end

endmodule  // hw1p2


/* Testbench for Homework 1 Problem 2 */
module hw1p2_testbench();

	logic out;
   logic in, clk, reset;
	
	hw1p2 dut (.out, .in, .clk, .reset);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
	
		@(posedge clk); reset <= 1;
		@(posedge clk); reset <= 0; in <= 1;
		@(posedge clk); in <= 1;
		@(posedge clk); in <= 0;
		@(posedge clk); in <= 0;
		@(posedge clk); in <= 1;
		@(posedge clk); in <= 0;
		@(posedge clk); in <= 0;
		@(posedge clk); in <= 1;
		@(posedge clk); in <= 0;
		@(posedge clk); in <= 1;
		
		@(posedge clk); 
		
		$stop;
	end  // initial
	
endmodule  // hw1p2_testbench