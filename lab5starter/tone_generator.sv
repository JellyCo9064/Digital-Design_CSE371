/*
 * Connor Aksama
 * 02/23/2023
 * CSE 371
 * Lab 5
*/

/**
 * Module to output sound data to generate a tone.
 
 * Inputs:
 *		write [1 bit] - 1 if the next sample should be output on this cycle, 0 o.w.
 *		clk [1 bit] - the clock to use for this module
 *		reset [1 bit] - resets the module to the first sample in the cycle if 1
 
 * Outputs:
 *		tone_data [24 bit] - the current sample for the tone
*/
module tone_generator (
	output [23:0] tone_data
	,input write, clk, reset
	);
	
	localparam num_samples = 520;
	
	reg [9:0] rom_addr;
	wire [23:0] rom_data;
	
	// ROM storing tone samples
	// rom_addr - address to read from
	// clk - clock to use
	// tone_data - output data
	lab5rom rom (
		 rom_addr
		,clk
		,tone_data
	);
	
	always @(posedge clk) begin
		if (reset || (rom_addr == num_samples - 1)) begin
			// Reset to 0 on reset or end of samples reached
			rom_addr <= 0;
		end else if (write) begin
			// Read from next address
			rom_addr <= rom_addr + 1;
		end
	end
	
endmodule  // tone_generator


/*
 * Testbench to test the functionality of the tone_generator module
 */
`timescale 1 ps / 1 ps
module tone_generator_testbench();

	logic [23:0] tone_data;
	logic write, clk, reset;
	
	tone_generator dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		integer i;
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		@(posedge clk) reset <= 1'b1;
		@(posedge clk) reset <= 1'b0; write <= 1'b1;
		// Get every sample in the ROM and cycle back
		for (i = 0; i < 530; i++) begin
			@(posedge clk);
		end
		// Don't read anything
		@(posedge clk) write <= 1'b0;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  //tone_generator_testbench