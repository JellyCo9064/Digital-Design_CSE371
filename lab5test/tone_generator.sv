module tone_generator (
	output [23:0] tone_data
	,input write, clk, reset
	);
	
	localparam num_samples = 480000;
	
	reg [18:0] rom_addr;
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
