module tone_generator_testbench();

	logic [23:0] tone_data;
	logic write, clk, reset;
	
	tone_generator dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		@(posedge clk) reset <= 1'b1;
		@(posedge clk) reset <= 1'b0; write <= 1'b1;
		for (i = 0; i < 50; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  //tone_generator_testbench