/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * Top-level module for Lab 6 task 1. Handles GPIO connections, HEX displays, and connections between submodules.
 
 * Inputs:
 * 	CLOCK_50 [1 bit] - The system clock source to use for this system.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX2 [7 bit] - Data to show on the HEX2 display, formatted in standard 7 segment display format.
 * 	HEX3 [7 bit] - Data to show on the HEX3 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.

 * Inouts:
 *		V_GPIO [34 bit] - GPIO ports on the target board. Ports 5-22 are inputs and ports 26-27 are outputs.
*/
module parking_lot #(
	parameter capacity = 25
	)
	(
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
	,input logic CLOCK_50
	,inout logic [35:23] V_GPIO
	);

	// Connections between sensor output and counter input
	logic enter, exit;
	
	logic [6:0] HEX1_temp;
	
	assign reset = V_GPIO[24];
	
	// Connect SW1 and SW2 to the sensor a and b inputs of the sensor module
	// Store outputs to local logic
	sensor s (.a(V_GPIO[23]), .b(V_GPIO[30]), .enter, .exit, .clk(CLOCK_50));
	
	// Connect the data from SW1 and SW2 to the left and right LEDs, respectively
	assign V_GPIO[32] = V_GPIO[23];  // Left LED
	assign V_GPIO[35] = V_GPIO[30];  // Right LED
	
	logic [4:0] car_count;
	logic reset;
	
	// Store counter output in local logic bus
	// Connect local enter/exit signals to inc/dec counter input, respectively
	fiveb_counter counter (.count(car_count), .inc(enter), .dec(exit), .clk(CLOCK_50), .reset);
	
	// Determine HEX0 and HEX1 displays using local count
	double_seg7 count_display (.HEX0, .HEX1(HEX1_temp), .num({2'b00, car_count}));
	
	// Handle HEX displays
	always_comb begin
	
		if (car_count == capacity) begin
			// Lot is at capacity
			HEX5 = ~7'b1110001;  // F
			HEX4 = ~7'b0111110;  // U
			HEX3 = ~7'b0111000;  // L
			HEX2 = ~7'b0111000;  // L
			HEX1 = HEX1_temp;
		end else if (car_count == 0) begin
			// Lot is empty
			HEX5 = ~7'b0111001;  // C
			HEX4 = ~7'b0111000;  // L
			HEX3 = ~7'b1111001;  // E
			HEX2 = ~7'b1110111;  // A
			HEX1 = ~7'b0110001;  // R
		end else begin
			HEX5 = ~7'b0000000;
			HEX4 = ~7'b0000000;
			HEX3 = ~7'b0000000;
			HEX2 = ~7'b0000000;
			HEX1 = HEX1_temp;
		end
	
	end
	
endmodule  // parking_lot

/*
 * Tests the functionality of the parking_lot module.
*/
module parking_lot_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic CLOCK_50;
	logic SW1, SW2, reset, clk;
	wire [35:23] V_GPIO;
	
	parking_lot dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .CLOCK_50(clk), .V_GPIO);
	
	assign V_GPIO[23] = SW1;
	assign V_GPIO[30] = SW2;
	assign V_GPIO[24] = reset;
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		
		// Increase the lot to capacity
		for (i = 0; i < 5; i++) begin
			
			@(posedge clk) SW1 <= 0; SW2 <= 0;
			@(posedge clk) SW1 <= 1;
			@(posedge clk) SW2 <= 1;
			
		end
		
		// Decrease the lot to empty
		for (i = 0; i < 5; i++) begin
			
			@(posedge clk) SW1 <= 0; SW2 <= 0;
			@(posedge clk) SW2 <= 1;
			@(posedge clk) SW1 <= 1;
			
		end
		
		// Increase lot capacity
		for (i = 0; i < 3; i++) begin
			
			@(posedge clk) SW1 <= 0; SW2 <= 0;
			@(posedge clk) SW1 <= 1;
			@(posedge clk) SW2 <= 1;
			
		end
		
		// Reset simulation
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		@(posedge clk);
	
		$stop;
	end

endmodule  // parking_lot_testbench
