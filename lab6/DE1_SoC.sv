/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * Top-level module for Lab 6 Task 2. Instantiates rush hour and car tracking modules and defines logic to connect I/O to peripherals.
 
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

 * Inouts:
 *	V_GPIO [13 bit] - Virtual GPIO Ports
*/
module DE1_SoC #(
		parameter clk_freq = 50000000, display_duration_sec = 1
	)(
		output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
		,input logic [9:0] SW
		,input logic [3:0] KEY
		,input logic CLOCK_50
		,inout logic [35:23] V_GPIO
	);
	
	logic clk;
	assign clk = CLOCK_50;
	
	// Which parking spaces occupied?
	logic [2:0] pp;
	assign pp = V_GPIO[30:28];
	
	// Car waiting at gate
	logic entr_wait, exit_wait;
	assign entr_wait = V_GPIO[23];
	assign exit_wait = V_GPIO[24];
	
	// Light LEDs at each parking spot depending on presence
	assign {V_GPIO[32], V_GPIO[27], V_GPIO[26]} = pp;
	
	// Full LED
	logic led_full;
	assign V_GPIO[34] = led_full;
	
	// Ctrl for gates
	logic entr_open, exit_open;
	assign V_GPIO[31] = entr_open;
	assign V_GPIO[33] = exit_open;
	
	// Remaining spot HEX generator
	logic [1:0] rem_num;
	logic [6:0] rem_hex;
	seg7 rem_spot (.HEX(rem_hex), .num({2'b0, rem_num}));
	
	// Current hour HEX generator
	logic [2:0] curr_hour;
	logic [6:0] ch_hex;
	seg7 hour (.HEX(ch_hex), .num({1'b0, curr_hour}));
	
	logic reset;
	assign reset = SW[9];
	
	logic done;
	
	// Rush Hour Tracker
	// rh_start -> rh_start (saved rush hour start)
	// rh_end -> rh_end (saved rush hour end)
	// rh_start_valid -> rh_start_valid (1 if rh_start data valid)
	// rh_end_valid -> rh_end_valid (1 if rh_end data valid)
	// pp -> pp
	// curr_hour -> hour (current hour)
	// clk -> clk
	// reset -> reset
	logic [2:0] rh_start, rh_end;
	logic rh_start_valid, rh_end_valid;
	rh_ctrl rush_hour (
		.rh_start(rh_start)
		,.rh_end(rh_end)
		,.rh_start_valid(rh_start_valid)
		,.rh_end_valid(rh_end_valid)
		,.pp(pp)
		,.hour(curr_hour)
		,.clk(clk)
		,.reset(reset)
	);
	
	logic [6:0] end_hex, start_hex;
	// Rush Hour End HEX generator
	seg7 end_hour (.HEX(end_hex), .num({1'b0, rh_end}));
	// Rush Hour Start HEX generator
	seg7 start_hour (.HEX(start_hex), .num({1'b0, rh_start}));
	
	// Num Car Tracker/Display
	// curr_num -> num_cars_display (Output for saved # of cars for curr_hour_display)
	// curr_hour -> curr_hour_display (Current hour for which to display # of cars)
	// total_cars -> wr_num (write the total number of cars entered so far)
	// curr_hour -> wr_hour (current hour, write total num cars for this hour)
	// clk -> clk
	// reset -> reset
	logic [15:0] total_cars, num_cars_display;
	logic [2:0] curr_hour_display;
	car_tracking #(
		.clk_freq(clk_freq), .duration_sec(display_duration_sec)
	) results (
		.curr_num(num_cars_display)
		,.curr_hour(curr_hour_display)
		,.wr_num(total_cars)
		,.wr_hour(curr_hour)
		,.clk(clk)
		,.reset(reset)
	);
	
	logic [6:0] ncd_hex, chd_hex;
	// EOD num cars HEX generator
	seg7 ncd (.HEX(ncd_hex), .num(num_cars_display[3:0]));
	// EOD curr hour HEX generator
	seg7 chd (.HEX(chd_hex), .num({1'b0, curr_hour_display}));
	
	logic inc_hour;
	// Generate a one cycle pulse for the inc_hour signal (KEY[0])
	pulse_gen gen_hour (.pulse(inc_hour), .in(~KEY[0]), .clk(clk), .reset(reset));
	
	logic inc_cars;
	pulse_gen gen_cars (.pulse(inc_cars), .in(entr_open), .clk(clk), .reset(reset));
	
	always_comb begin		
		// Ctrl signals
		led_full = (pp == 3'b111);
		entr_open = entr_wait & (pp != 3'b111);
		exit_open = exit_wait;

		// Find remaining number of spots		
		case (pp)
			3'b000:
				rem_num = 2'd3;
			3'b001, 3'b010, 3'b100:
				rem_num = 2'd2;
			3'b011, 3'b101, 3'b110:
				rem_num = 2'd1;
			3'b111:
				rem_num = 2'd0;
		endcase
		
		// ctrl driver for HEX outputs
		if (done) begin
			HEX5 = ~7'b0;
			if (rh_end_valid) begin
				HEX4 = end_hex;
			end else begin
				HEX4 = ~7'b1000000;
			end
			if (rh_start_valid) begin
				HEX3 = start_hex;
			end else begin
				HEX3 = ~7'b1000000;
			end
			HEX2 = chd_hex;
			HEX1 = ncd_hex;
			HEX0 = ~7'b0;	
		end else if (led_full) begin
			HEX5 = ch_hex;
			HEX4 = ~7'b0;
			HEX3 = ~7'b1110001;  // F
			HEX2 = ~7'b0111110;  // U
			HEX1 = ~7'b0111000;  // L
			HEX0 = ~7'b0111000;  // L
		end else begin
			HEX5 = ch_hex;
			HEX4 = ~7'b0;
			HEX3 = ~7'b0;
			HEX2 = ~7'b0;
			HEX1 = ~7'b0;
			HEX0 = rem_hex;	
		end
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			// Reset work day
			curr_hour <= '0;
			done <= '0;
		end else if (inc_hour && curr_hour == 3'd7) begin
			// EOD reached
			done <= '1;
		end else if (inc_hour) begin
			// Increase work hour
			curr_hour <= curr_hour + 3'b001;
		end
		
		if (reset) begin
			// Reset # total cars
			total_cars <= '0;
		end else if (inc_cars) begin
			// Car entering
			total_cars <= total_cars + 16'b1;
		end
	end
	
endmodule  // DE1_SoC

/*
 * Testbench to test the functionality of the DE1_SoC module
 */
`timescale 1 ps / 1 ps
module DE1_SoC_testbench();

	logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic CLOCK_50;
	wire [35:23] V_GPIO;

	logic clk;
	assign CLOCK_50 = clk;
	
	logic reset;
	assign SW[9] = reset;
	
	logic inc_hour;
	assign KEY[0] = ~inc_hour;
	
	logic [2:0] pp;
	assign V_GPIO[30:28] = pp;
	
	logic entr_wait, exit_wait;
	assign V_GPIO[23] = entr_wait;
	assign V_GPIO[24] = exit_wait;
	
	logic [2:0] led_p;
	assign led_p = {V_GPIO[32], V_GPIO[27], V_GPIO[26]};
	
	logic led_full;
	assign led_full = V_GPIO[34];
	
	logic entr_open, exit_open;
	assign entr_open = V_GPIO[31];
	assign exit_open = V_GPIO[33];

	DE1_SoC #(.clk_freq(3), .display_duration_sec(1)) dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= '0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i, j;
		
		@(posedge clk) reset <= '1; inc_hour <= '0; pp <= '0; entr_wait <= '0; exit_wait <= '0;
		@(posedge clk) reset <= '0;
		
		for (i = 0; i < 8; i++) begin
			if (i % 2 == 0) begin
				// Three cars enter
				for (j = 0; j < 3; j++) begin
					@(posedge clk) entr_wait <= '1;
					@(posedge clk);
					if (entr_open) begin
						entr_wait <= '0;
						pp[j] <= '1;
					end else begin
						j--;
					end
				end
			end else begin
				// Three cars leave
				for (j = 0; j < 3; j++) begin
					@(posedge clk) exit_wait <= '1;
					@(posedge clk);
					if (exit_open) begin
						exit_wait <= '0;
						pp[j] <= '0;
					end else begin
						j--;
					end
				end
			end
			@(posedge clk) inc_hour <= '1;
			@(posedge clk) inc_hour <= '0;
		end
		
		for (i = 0; i < 32; i++) begin
			@(posedge clk);
		end
		
		@(posedge clk) reset <= '1; inc_hour <= '0; pp <= '0; entr_wait <= '0; exit_wait <= '0;
		@(posedge clk) reset <= '0;
		for (i = 0; i < 3; i++) begin
			@(posedge clk) entr_wait <= '1;
			@(posedge clk);
			if (entr_open) begin
				entr_wait <= '0;
				pp[j] <= '1;
			end
		end
		for (i = 0; i < 8; i++) begin
			@(posedge clk) inc_hour <= '1;
			@(posedge clk) inc_hour <= '0;
		end
		for (i = 0; i < 32; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  // DE1_SoC_testbench