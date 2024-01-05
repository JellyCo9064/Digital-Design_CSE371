/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/*
 * FSM implementation to determine whether a car has entered/exited the lot given sensor inputs.

 * Inputs:
 *		a [1 bit] - The status of sensor a. a is 1 if sensor a is blocked. a is 0 if sensor a is not blocked.
 *		b [1 bit] - The status of sensor b. b is 1 if sensor b is blocked. b is 0 if sensor b is not blocked.
 *		clk [1 bit] - The clock signal to use for this module.
 
 * Outputs:
 * 	enter [1 bit] - Signal indicating whether a car has entered the lot. enter is 1 if a car has entered the lot during the current clock cycle, 0 otherwise.
 *		exit [1 bit]  - Signal indicating whether a car has exited the lot. exit is 1 if a car has exited the lot during the current clock cycle, 0 otherwise.
*/
module sensor(
	output logic enter, exit
	,input logic a, b, clk
	);

	// FSM states
	typedef enum logic [1:0] {s00, s01, s10, s11} state;
	
	state ps, ns;
	
	// Handle FSM transitions
	always_comb begin
		
		if (ps == s11) begin
			// Transition out of s11 only if b nor a
			
			if (b | a) ns = s11;
			else ns = s00;
		
		end else begin
			// Transition to state determined by 'ba'
		
			ns = state'({b, a});
		
		end
		
		enter = 1'b0;
		exit = 1'b0;
		
		// Raise enter if going from s01->s11
		if (ps == s01 & ns == s11)
			enter = 1'b1;
			
		// Raise exit if going from s10->s11
		if (ps == s10 & ns == s11)
			exit = 1'b1;
		
	end
	
	// Update present state on posedge clk
	always_ff @(posedge clk) begin
	
		ps <= ns;
	
	end
	
endmodule  // sensor

/*
 * Tests the functionality of the sensor module.
*/
module sensor_testbench();

	logic enter, exit;
	logic a, b, clk;
	
	sensor dut(.a, .b, .clk, .enter, .exit);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i, j;
		
		// Test transition between every pair of states
		for (i = 0; i < 4; i++) begin
			for (j = 0; j < 4; j++) begin
				@(posedge clk) {b, a} <= i;
				@(posedge clk) {b, a} <= j;
			end
		end
	
		@(posedge clk);
		@(posedge clk);
	
		$stop;
	end

endmodule  // sensor_testbench
