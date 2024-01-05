module tone_generator (
	output [23:0] tone_data
	,input write, clk, reset
	);
	
	localparam num_samples = 520;
	
	reg [9:0] rom_addr;
	wire [23:0] rom_data;
	
	lab5rom rom (
		 rom_addr
		,clk
		,tone_data
	);
	
	always @(posedge clk) begin
		if (reset || (rom_addr == num_samples - 1)) begin
			rom_addr <= 0;
		end else if (write) begin
			rom_addr <= rom_addr + 1;
		end
	end
	
endmodule  // tone_generator

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
		for (i = 0; i < 520; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  //tone_generator_testbench