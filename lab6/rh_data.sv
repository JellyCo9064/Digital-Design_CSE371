/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * Datapath module for the rush hour system.
 
 * Inputs:
 *		hour [3 bit] - The current hour
 *		save_start [1 bit] - 1 if hour should be saved for start, 0 o.w.
 *		save_end [1 bit] - 1 if hour should be saved for end, 0 o.w.
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the FSM to its initial state.
 
 * Outputs:
 *      rh_start [3 bit] - The saved start of rush hour
 *      rh_end [3 bit] - The saved end of rush hour
 *      rh_start_valid [1 bit] - 1 if rh_start is valid, 0 o.w.
 *      rh_end_valid [1 bit] - 1 if rh_end is valid, 0 o.w.
*/
module rh_data (
		output logic [2:0] rh_start, rh_end
		,output logic rh_start_valid, rh_end_valid
		,input logic [2:0] hour
		,input logic save_start, save_end, clk, reset
	);
	
	
	always_ff @(posedge clk) begin
		// Register hour/valid bits based on ctrl signals
		if (reset) begin
			rh_start <= '0;
			rh_end <= '0;
			rh_start_valid <= '0;
			rh_end_valid <= '0;
		end else if (save_start) begin
			rh_start <= hour;
			rh_start_valid <= '1;
		end else if (save_end) begin
			rh_end <= hour;
			rh_end_valid <= '1;
		end
	
	
	end
		
endmodule  // rh_data

/*
 * Testbench to test the functionality of the rh_ctrl module
 */
module rh_data_testbench();

	logic [2:0] rh_start, rh_end;
	logic rh_start_valid, rh_end_valid;
	logic [2:0] hour;
	logic save_start, save_end, clk, reset;

	rh_data dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= '0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= '1; save_start <= '0; save_end <= '0; hour <= '0;
		@(posedge clk) reset <= '0;
		
		// Do nothing
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
			hour <= i;
		end
		
		// Save start hour
		@(posedge clk) save_start <= '1;
		@(posedge clk) save_start <= '0;
		
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		// Save end hour
		@(posedge clk); hour <= hour + 3;
		@(posedge clk); save_end <= '1;
		@(posedge clk); save_end <= '0;
		
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		@(posedge clk); hour <= '0; reset <= '1;
		@(posedge clk); reset <= '0;
		
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end

endmodule  // rh_data_testbench
