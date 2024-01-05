/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * Controller module for the rush hour system.
 
 * Inputs:
 *		pp [3 bit] - Parking spaces currently occupied
 *		hour [3 bit] - The current hour
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the FSM to its initial state.
 
 * Outputs:
 *      rh_start [3 bit] - The saved start of rush hour
 *      rh_end [3 bit] - The saved end of rush hour
 *      rh_start_valid [1 bit] - 1 if rh_start is valid, 0 o.w.
 *      rh_end_valid [1 bit] - 1 if rh_end is valid, 0 o.w.
*/
module rh_ctrl (
		output logic [2:0] rh_start, rh_end
		,output logic rh_start_valid, rh_end_valid
		,input logic [2:0] pp, hour
		,input logic clk, reset
	);
	
	
	typedef enum { s_normal, s_rush, s_end } state;
	
	state ps, ns;
	
	logic full, empty, hour0;
	logic save_start, save_end, reset_data;
	
	// Datapath module
	// rh_start -> rh_start (saved start hour)
	// rh_end -> rh_end (saved end hour)
	// rh_start_valid -> rh_start_valid (rh_start valid?)
	// rh_end_valid -> rh_end_valid (rh_end valid?)
	// hour -> hour (current hour of system)
	// save_start -> save_start (current hour is start)
	// save_end -> save_end (current hour is end)
	// clk -> clk
	// reset | reset_data -> reset (reset FSM to start)
	rh_data rush_hour_data (
		.rh_start(rh_start)
		,.rh_end(rh_end)
		,.rh_start_valid(rh_start_valid)
		,.rh_end_valid(rh_end_valid)
		,.hour(hour)
		,.save_start(save_start)
		,.save_end(save_end)
		,.clk(clk)
		,.reset(reset | reset_data)
	);
	
	always_comb begin
	
		// Handle state transitions
		case (ps)
		
			s_normal: begin
				if (full) begin
					ns = s_rush;
				end else begin
					ns = s_normal;
				end
			end
			
			s_rush: begin
				if (empty) begin
					ns = s_end;
				end else begin
					ns = s_rush;
				end
			end
			
			s_end: begin
				if (hour0) begin
					ns = s_normal;
				end else begin
					ns = s_end;
				end
			end
		
		endcase
		
		// Control signals
		save_start = (ps == s_normal) & full;
		save_end = (ps == s_rush) & empty;
		reset_data = (ps == s_end) & hour0;
	
	end
	
	
	always_ff @(posedge clk) begin
		// Update FSM
		if (reset) begin
			ps <= s_normal;
		end else begin
			ps <= ns;
		end
		
		// Register control signals
		full <= (pp == 3'b111);
		empty <= (pp == 3'b000);
		hour0 <= (hour == 3'b000);
	end
	
	
endmodule  // rh_ctrl

/*
 * Testbench to test the functionality of the rh_ctrl module
 */
module rh_ctrl_testbench();

	logic [2:0] rh_start, rh_end;
	logic rh_start_valid, rh_end_valid;
	
	logic [2:0] pp, hour;
	logic clk, reset;
	
	rh_ctrl dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= '0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= '1; pp <= '0; hour <= '0;
		@(posedge clk) reset <= '0;
		
		for (i = 0; i < 40; i++) begin
			@(posedge clk);
			@(posedge clk)
			if (i % 2 == 0) begin
				// Increment hour
				hour <= hour + 3'd1;
			end
			if (i % 3 == 0) begin
				// Add car to lot
				pp <= pp + 3'd1;
			end
		end
		
		$stop;
	end

endmodule  // rh_ctrl_testbench
