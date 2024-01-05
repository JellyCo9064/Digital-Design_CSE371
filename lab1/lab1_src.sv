/*********************************** 

sensor.sv

***********************************/

/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/*
 * FSM implementation to determine whether a car has entered/exited the lot given sensor inputs.

 * Inputs:
 *		a [1 bit] - The status of sensor a. a is 1 if sensor a is blocked. a is 0 if sensor a is not blocked.
 *		b [1 bit] - The status of sensor b. b is 1 if sensor b is blocked. b is 0 if sensor b is not blocked.
 *		clk [1 bit] - The clock signal to use for this module.
 
 * Outputs:
 * 	enter [1 bit] - Signal indicating whether a car has entered the lot. enter is 1 if a car has entered the lot during the current clock cycle, 0 otherwise.
 *		exit [1 bit]  - Signal indicating whether a car has exited the lot. exit is 1 if a car has exited the lot during the current clock cycle, 0 otherwise.
*/
module sensor(
	output logic enter, exit
	,input logic a, b, clk
	);

	// FSM states
	typedef enum logic [1:0] {s00, s01, s10, s11} state;
	
	state ps, ns;
	
	// Handle FSM transitions
	always_comb begin
		
		if (ps == s11) begin
			// Transition out of s11 only if b nor a
			
			if (b | a) ns = s11;
			else ns = s00;
		
		end else begin
			// Transition to state determined by 'ba'
		
			ns = state'({b, a});
		
		end
		
		enter = 1'b0;
		exit = 1'b0;
		
		// Raise enter if going from s01->s11
		if (ps == s01 & ns == s11)
			enter = 1'b1;
			
		// Raise exit if going from s10->s11
		if (ps == s10 & ns == s11)
			exit = 1'b1;
		
	end
	
	// Update present state on posedge clk
	always_ff @(posedge clk) begin
	
		ps <= ns;
	
	end
	
endmodule  // sensor

/*
 * Tests the functionality of the sensor module.
*/
module sensor_testbench();

	logic enter, exit;
	logic a, b, clk;
	
	sensor dut(.a, .b, .clk, .enter, .exit);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i, j;
		
		// Test transition between every pair of states
		for (i = 0; i < 4; i++) begin
			for (j = 0; j < 4; j++) begin
				@(posedge clk) {b, a} <= i;
				@(posedge clk) {b, a} <= j;
			end
		end
	
		@(posedge clk);
		@(posedge clk);
	
		$stop;
	end

endmodule  // sensor_testbench

/*********************************** 

fiveb_counter.sv

***********************************/

/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/**
 * A five-bit increment/decrement counter. Overflows to 5'b00000; underflows to 5'11111.
 * reset takes precedence; if inc and dec are simultaneously raised, count is unchanged.
 * Inputs:
 * 	inc [1 bit] - Increments the count by 1 when raised. Does nothing if signal is low.
 * 	dec [1 bit] - Decrements the count by 1 when raised. Does nothing if signal is low.
 * 	clk [1 bit] - The clock to use for this module.
 * 	reset [1 bit] - Resets the counter to 0 when raised. Does nothing if signal is low.

 * Outputs:
 *		count [5 bit] - The count of this counter.
 */
module fiveb_counter(
	output logic [4:0] count
	,input logic inc, dec, clk, reset
	);

	// Handles increment/decrement/reset operations
	always_ff @(posedge clk) begin
	
		if (reset)
			count <= 5'b0;
		else if (inc & ~dec)
			count <= count + 5'b1;
		else if (dec & ~inc)
			count <= count - 5'b1;
	
	end
	
endmodule  // fiveb_counter

/*
 * Tests the functionality of the fiveb_counter module.
*/
module fiveb_counter_testbench();

	logic [4:0] count;
	logic inc, dec, clk, reset;
	
	fiveb_counter dut (.count, .inc, .dec, .clk, .reset);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever  #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0; inc <= 0; dec <= 0;
		
		// Increment counter from 0 to max, then past max
		@(posedge clk) inc <= 1;
		for (i = 0; i < 40; i++) begin
			@(posedge clk);
		end
		
		// Hold counter constant
		@(posedge clk) inc <= 0;		
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		// Decrement counter below 0, then max to 0, etc.
		@(posedge clk) dec <= 1;
		for (i = 0; i < 45; i++) begin
			@(posedge clk);
		end
		
		// Hold counter constant
		@(posedge clk) dec <= 0;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end
		
		// reset to 0
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		
		@(posedge clk)
		@(posedge clk)
		
		$stop;
	end
	
endmodule  // fiveb_counter_testbench

/*********************************** 

parking_lot.sv

***********************************/

/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/**
 * Top-level module for Lab 1. Handles GPIO connections, HEX displays, and connections between submodules.
 
 * Inputs:f
 * 	CLOCK_50 [1 bit] - The system clock source to use for this system.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	HEX2 [7 bit] - Data to show on the HEX2 display, formatted in standard 7 segment display format.
 * 	HEX3 [7 bit] - Data to show on the HEX3 display, formatted in standard 7 segment display format.
 * 	HEX4 [7 bit] - Data to show on the HEX4 display, formatted in standard 7 segment display format.
 * 	HEX5 [7 bit] - Data to show on the HEX5 display, formatted in standard 7 segment display format.

 * Inouts:
 *		GPIO_0 [34 bit] - GPIO ports on the target board. Ports 5-22 are inputs and ports 26-27 are outputs.
*/
module parking_lot #(
	parameter capacity = 25
	)
	(
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
	,input logic CLOCK_50
	,inout logic [33:0] GPIO_0
	);

	// Connections between sensor output and counter input
	logic enter, exit;
	
	logic [6:0] HEX1_temp;
	
	assign reset = GPIO_0[7];
	
	// Connect SW1 and SW2 to the sensor a and b inputs of the sensor module
	// Store outputs to local logic
	sensor s (.a(GPIO_0[5]), .b(GPIO_0[6]), .enter, .exit, .clk(CLOCK_50));
	
	// Connect the data from SW1 and SW2 to the left and right LEDs, respectively
	assign GPIO_0[26] = GPIO_0[5];  // Left LED
	assign GPIO_0[27] = GPIO_0[6];  // Right LED
	
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
	wire [33:0] GPIO_0;
	
	parking_lot dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .CLOCK_50(clk), .GPIO_0);
	
	assign GPIO_0[5] = SW1;
	assign GPIO_0[6] = SW2;
	assign GPIO_0[7] = reset;
	
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

/*********************************** 

double_seg7.sv

***********************************/

/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/**
 * Defines data for 2-digit decimal HEX display given a 7-bit unsigned integer from [0-99].
 * Output data for input numbers with 3 digits is undefined.
 
 * Inputs:
 *		num [7 bit] - An unsigned integer value [0-99] to display
 
 * Outputs:
 * 	HEX0 [7 bit] - A HEX display for the ones digit of the input num, formatted in standard seven segment display format
 * 	HEX1 [7 bit] - A HEX display for the tens digit of the input num, formatted in standard seven segment display format
 *							HEX1 is blank if num < 10.
*/
module double_seg7(
	output logic [6:0] HEX0, HEX1
	,input logic [6:0] num
	);

	// Drive HEX output signals given num
	always_comb begin
		// Light HEX0 using ones place of num
		case (num % 10)
		   //     Light: 6543210
			0: HEX0 = ~7'b0111111;  // 0 
			1: HEX0 = ~7'b0000110;  // 1 
			2: HEX0 = ~7'b1011011;  // 2 
			3: HEX0 = ~7'b1001111;  // 3 
			4: HEX0 = ~7'b1100110;  // 4 
			5: HEX0 = ~7'b1101101;  // 5 
			6: HEX0 = ~7'b1111101;  // 6 
			7: HEX0 = ~7'b0000111;  // 7 
			8: HEX0 = ~7'b1111111;  // 8 
			9: HEX0 = ~7'b1101111;  // 9 
			default: HEX0 = 7'bX;
		endcase
		
		// Light HEX1 using tens place of num
		case (num / 10)
		   //     Light: 6543210
			0: HEX1 = ~7'b0000000;  // 0 
			1: HEX1 = ~7'b0000110;  // 1 
			2: HEX1 = ~7'b1011011;  // 2 
			3: HEX1 = ~7'b1001111;  // 3 
			4: HEX1 = ~7'b1100110;  // 4 
			5: HEX1 = ~7'b1101101;  // 5 
			6: HEX1 = ~7'b1111101;  // 6 
			7: HEX1 = ~7'b0000111;  // 7 
			8: HEX1 = ~7'b1111111;  // 8 
			9: HEX1 = ~7'b1101111;  // 9 
			default: HEX1 = 7'bX;
		endcase

	end
	
endmodule  // double_seg7

/*
 * Tests the functionality of the double_seg7 module.
*/
module double_seg7_testbench();

	logic [6:0] HEX0, HEX1;
	logic [6:0] num;
	
	double_seg7 dut (.HEX0, .HEX1, .num);
	
	initial begin
	
		integer i;
		
		// Check HEX displays for integers 0-99
		for (i = 0; i <= 99; i++) begin
			#10 num = i;
		end
		#50;
	end

endmodule  // double_seg7_testbench
