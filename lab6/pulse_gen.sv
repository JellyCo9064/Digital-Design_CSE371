/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * One cycle pulse generator for arbitrary length input.
 
 * Inputs:
 *		in [1 bit] - Input for which to generate pulse
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the cyclic display to hour 0.
 
 * Outputs:
 *      pulse [1 bit] - The output signal where pulse is sent
*/
module pulse_gen (
		output logic pulse
		,input logic in, clk, reset
	);
	
	typedef enum logic [1:0] { s_wait_rise, s_pulse, s_wait_fall } state;
	
	state ps, ns;
	logic in_reg;
	
	always_comb begin
		ns = ps;
		
		// Handle state transitions
		case (ps)
			s_wait_rise: begin
				if (in_reg) begin
					ns = s_pulse;
				end
			end
			s_pulse: begin
				if (~in_reg) begin
					ns = s_wait_rise;
				end else begin
					ns = s_wait_fall;
				end
			end
			s_wait_fall: begin
				if (~in_reg) begin
					ns = s_wait_rise;
				end
			end
		endcase
		
		pulse = (ps == s_pulse);
	end
	
	always_ff @(posedge clk) begin
		// Update state
		if (reset) begin
			ps <= s_wait_rise;
		end else begin
			ps <= ns;
		end
		// Register input
		in_reg <= in;
	end
	
endmodule  // pulse_gen

/*
 * Testbench to test the functionality of the pulse_gen module
 */
module pulse_gen_testbench();

	logic pulse, in, clk, reset;
	
	pulse_gen dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= '0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= '1; in <= '0;
		@(posedge clk) reset <= '0; in <= '1;
		
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end
		
		@(posedge clk) in <= '0;
		
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end
		
		@(posedge clk) in <= '1;
		@(posedge clk) in <= '0;
		
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end

endmodule  // pulse_gen_testbench