/*
 * Connor Aksama
 * 01/30/2023
 * CSE 371
 * Lab 3
*/

/**
 * Top-level module for Lab 3. Instantiates drawing logic modules and connections to VGA controller
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX2 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 *	HEX3 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.
 * 	LEDR [10 bit] - Signal to output to 10 onboard LEDs, respectively.
 *	VGA_R [8 bit] - The red channel value of the pixel to write to the display
 *	VGA_G [8 bit] - The green channel value of the pixel to write to the display
 *	VGA_B [8 bit] - The blue channel value of the pixel to write to the display
 *	VGA_BLANK_N [1 bit] - Blank area signal
 * 	VGA_CLK [1 bit] - Divided clock for VGA signal
 *	VGA_HS [1 bit] - VGA timing signal
 *	VGA_SYNC_N [1 bit] - Unused
 *	VGA_VS [1 bit] - VGA timing signal
*/
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX1 = '1;
	assign HEX0 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	// Outputs from drawing modules
	logic [9:0] x0_l, x0_a, x1, x1_l, x1_a;
	logic [8:0] y0_l, y0_a, y1, y1_l, y1_a;
	// Inputs into frame buffer
	logic [9:0] x_l, x_a, x_c, x;
	logic [8:0] y_l, y_a, y_c, y;
	logic frame_start;
	logic pixel_color;
	logic reset, clear_screen;
	
	assign reset = SW[9];
	assign clear_screen = SW[8];
	
	
	//////// DOUBLE_FRAME_BUFFER ////////
	logic dfb_en;
	assign dfb_en = 1'b0;
	/////////////////////////////////////
	
	VGA_framebuffer fb(.clk(CLOCK_50), .rst(1'b0), .x, .y,
				.pixel_color, .pixel_write(1'b1), .dfb_en, .frame_start,
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_N, .VGA_SYNC_N);
	
	// Line Drawing Module
	// Inputs -> system clock, reset signal, (x0_l, y0_l), (x1_l, y1_l) -> from local temp logic; defines endpoints of line
	// Outputs -> (x_l, y_l) -> pixel to draw to VGA - changes by at most one pixel each clock cycle, starting one
	//							cycle after input points change
	line_drawer lines (.clk(CLOCK_50), .reset,
				.x0(x0_l), .y0(y0_l), .x1(x1_l), .y1(y1_l), .x(x_l), .y(y_l));
	
	// Animator Module
	// Inputs -> system clock, reset signal
	// Outputs -> (x0_a, y0_a), (x1_a, y1_a) -> Endpoints of line to draw
	//			  clear -> signal is high when screen should be cleared
	logic clear;
	animator #(50) anim (.x0(x0_a), .x1(x1_a), .y0(y0_a), .y1(y1_a), .clear, .clk(CLOCK_50), .reset);
	
	// Screen Clearning Module; cycles through each pixel on screen
	// Inputs -> system clock, reset signal
	// Output -> (x_c, y_c) -> Coordinate of pixel to clear on display
	fill_space #(640,480) clearer (.x(x_c), .y(y_c), .clk(CLOCK_50), .reset);
	
	// Multiplex endpoints into line drawing module
	// Multiplex coordinates into frame buffer
	always_comb begin
		if (SW[7]) begin
			// Display arbitrary lines based on SW input
			case (SW[2:0])
				0: begin
					// vertical
					x0_l = 50;
					y0_l = 50;
					x1_l = 50;
					y1_l = 400;
					pixel_color = 1'b1; 
				end
				1: begin
					// horizontal
					x0_l = 90;
					y0_l = 90;
					x1_l = 450;
					y1_l = 90;
					pixel_color = 1'b1;
				end
				2: begin
					// negative diagonal
					x0_l = 240;
					y0_l = 240;
					x1_l = 0;
					y1_l = 0;
					pixel_color = 1'b1;
				end
				3: begin
					// positive diagonal
					x0_l = 400;
					y0_l = 40;
					x1_l = 40;
					y1_l = 400;
					pixel_color = 1'b1;
				end
				4: begin
					// positive shallow
					x0_l = 400;
					y0_l = 40;
					x1_l = 40;
					y1_l = 100;
					pixel_color = 1'b1;
				end
				5: begin
					// negative shallow
					x0_l = 300;
					y0_l = 200;
					x1_l = 40;
					y1_l = 100;
					pixel_color = 1'b1;
				end
				6: begin
					// positive steep
					x0_l = 40;
					y0_l = 400;
					x1_l = 80;
					y1_l = 40;
					pixel_color = 1'b1;
				end
				7: begin
					// negative steep
					x0_l = 40;
					y0_l = 40;
					x1_l = 80;
					y1_l = 400;
					pixel_color = 1'b1;
				end
				default: begin
					x0_l = 0;
					y0_l = 0;
					x1_l = 0;
					y1_l = 0;
					pixel_color = 1'b1;
				end

			endcase
			x = x_l;
			y = y_l;
		end 
		else if (clear | clear_screen) begin
			// Clear Screen
			x0_l = 0;
			y0_l = 0;
			x1_l = 0;
			y1_l = 0;
			pixel_color = 1'b0;
			x = x_c;
			y = y_c;
		end 
		else begin
			// Display animation
			x0_l = x0_a;
			y0_l = y0_a;
			x1_l = x1_a;
			y1_l = y1_a;
			pixel_color = 1'b1;
			x = x_l;
			y = y_l;
		end
	end
	
	
endmodule  // DE1_SoC

// Module to test the functionality of the DE1_SoC module
module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	logic clk;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5
					,.LEDR, .KEY, .SW, .CLOCK_50(clk)
					,.VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N
					,.VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
					
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) SW[9] <= 1; SW[8] <= 0;
		@(posedge clk) SW[9] <= 0;
		
		// Run through each of the arbitrary lines
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b000;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b001;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b010;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b011;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b100;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b101;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b110;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk) SW[7] <= 1; SW[2:0] <= 3'b111;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		// Clear the screen
		@(posedge clk) SW[7] <= 0; SW[8] <= 1;
		for (i = 0; i < 20; i++) begin
			@(posedge clk);
		end
		// Run through the animation
		@(posedge clk) SW[8] <= 0;
		for (i = 0; i < 100; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end

endmodule  // DE1_SoC_testbench
