/*********************************** 

bc_ctrl.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Controller module for the bit counting system.
 
 * Inputs:
 *		start [1 bit] - Signal to begin the binary searching process. While start is 0 and the algo is not in progress,
 *						the input value num is loaded into the system. When start is 1, the algo begins. Once the search
 *						is complete, the next value of num will be loaded once start is lowered to 0.
 *      done [1 bit] - 1 if the algo is complete, 0 o.w.
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the system to its initial state before the search process has started.
 
 * Outputs:
 *      load_A [1 bit] - 1 if A should be sampled from the user during this cycle, 0 o.w.
 *      rs_A [1 bit] - 1 if the next bit of the num should be counted, 0 o.w.
*/
module bc_ctrl (
    output logic load_A, rs_A
    ,input logic start, done, clk, reset
    );

    typedef enum logic [1:0] { s_load, s_count, s_done } state;

    state ps, ns;

    logic start_reg;

    always_comb begin
        // Handle state transitions
        case (ps)
            s_load: begin
                if (start_reg) begin
                    ns = s_count;
                end else begin
                    ns = s_load;
                end
            end

            s_count: begin
                if (done) begin
                    ns = s_done;
                end else begin
                    ns = s_count;
                end
            end

            s_done: begin
                if (!start_reg) begin
                    ns = s_load;
                end else begin
                    ns = s_done;
                end
            end

        endcase

        // Control signals
        load_A = (ps == s_load);
        rs_A = (ps == s_count);

    end

    always_ff @(posedge clk) begin
        // Register state, start
        if (reset) begin
            ps <= s_load;
        end else begin
            ps <= ns;
        end

        start_reg <= start;
    end

endmodule  // bc_ctrl

/*
 * Testbench to test the functionality of the bc_ctrl module
 */
module bc_ctrl_testbench();

	logic start, done, clk, reset, load_A, rs_A;
	
	bc_ctrl dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
        // Hold in start state
		@(posedge clk) reset <= 1'b1; start <= 1'b0; done <= 1'b0;
		@(posedge clk); reset <= 1'b0;
		@(posedge clk);
		
        // Start algo
		for (i = 0; i < 15; i++) begin
			@(posedge clk) start <= 1'b1;
		end
		
        // Hold in done state
		for (i = 0; i < 5; i++) begin
			@(posedge clk) done <= 1'b1;
		end
		
        // Back to start state
		start <= 1'b0;
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end

        // Start algo
        start <= 1'b1;
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end

endmodule  // bc_ctrl_testbench

/*********************************** 

bc_data.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Datapath module for the bit counting system.
 
 * Inputs:
 *		a_in [8 bit] - The number to bit count. Latched when load_A is 1.
 *		load_A [1 bit] - 1 if a_in should be sampled, 0 o.w.
 *		rs_A [1 bit] - 1 if the next bit should be counted, 0 o.w.
 *		clk [1 bit] - The clock to use for this module.
 
 * Outputs:
 *      done [1 bit] - 1 if the algo is complete, 0 o.w.
 *      count [4 bit] - The number of 1s in the sampled a_in number. Valid if and only if done is 1.
*/
module bc_data (
    output logic done
	,output logic [3:0] count
    ,input logic load_A, rs_A, clk
    ,input logic [7:0] a_in
    );

    logic [7:0] A;
    logic [3:0] result;

    always_ff @(posedge clk) begin
        if (load_A) begin
			// Sample A
            result <= 4'b0;
            A <= a_in;
        end

        if (rs_A) begin
			// RS and count
            A <= A >> 1;
			if (A[0] == 1'b1) begin
				result <= result + 1'b1;
			end
        end

        done <= (A == 0);
		count <= result;
    end

endmodule  // bc_data

/*
 * Testbench to test the functionality of the bc_data module.
 */
module bc_data_testbench();

	logic done, load_A, rs_A, clk;
	logic [3:0] count;
	logic [7:0] a_in;
	
	bc_data dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		// Load value, hold in start
		@(posedge clk) {load_A, rs_A} <= 2'b10; a_in <= 8'b10011111;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		// Begin algo
		for (i = 0; i < 15; i++) begin
			@(posedge clk) {load_A, rs_A} <= 2'b01;
		end
		// Load value
		@(posedge clk) {load_A, rs_A} <= 2'b10; a_in <= 8'b00000000;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		// Begin
		for (i = 0; i < 15; i++) begin
			@(posedge clk) {load_A, rs_A} <= 2'b01;
		end
		
		$stop;
	end

endmodule

/*********************************** 

bit_counter.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Instantiates the controller and datapath modules and defines connections.
 
 * Inputs:
 *		num [8 bit] - Number to bit count.
 *		start [1 bit] - Signal to begin the bit counting algo. While start is 0 and the algo is not in progress,
 *						the input value num is loaded into the system. When start is 1, the algo begins. Once the algo
 *						is complete, the next value of num will be loaded once start is lowered to 0.
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the system to its initial state before the algo has started.
 
 * Outputs:
 * 	result [4 bit] - The number of 1s in the sampled num. This result value is valid if and only if done is raised.
 *					If found and not_found are 0, the search is not complete.
 *	done [1 bit] - 1 if the algo is complete, 0 o.w.
*/
module bit_counter(
    output logic [3:0] result
    ,output logic done
    ,input logic [7:0] num
    ,input logic start, clk, reset
);

    // Controller module
    // In: start, done, clk, reset
    // Out: load_A, rs_A
    logic load_A, rs_A, d;
    bc_ctrl controller (
         .load_A(load_A)
        ,.rs_A(rs_A)
        ,.start(start)
        ,.done(d)
        ,.clk(clk)
        ,.reset(reset)
    );

    // Datapath module
    // In: load_A, rs_A, a_in, clk
    // Out: done, count
    bc_data datapath (
         .done(d)
		,.count(result)
        ,.load_A(load_A)
        ,.rs_A(rs_A)
        ,.a_in(num)
	    ,.clk(clk)
    );

    assign done = d;

endmodule  // bit_counter

/*
 * Testbench to test the functionality of the bit_counter module.
 */
module bit_counter_testbench();

    logic [3:0] result;
    logic done;
    logic [7:0] num;
    logic start, clk, reset;

    bit_counter dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk;
    end

    initial begin
        integer i;
        // Load value
        @(posedge clk) reset <= 1; num <= 8'b10000001; start <= 0;
        @(posedge clk) reset <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        // Start count
        @(posedge clk) start <= 1;

        for (i = 0; i < 16; i++) begin
            @(posedge clk);
        end
        // Load value
        @(posedge clk) start <= 0; num <= 8'b0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        // Start count
        @(posedge clk) start <= 1;
        for (i = 0; i < 5; i++) begin
            @(posedge clk);
        end
        
        @(posedge clk);
        @(posedge clk);

        $stop;
    end

endmodule  // bit_counter_testbench

/*********************************** 

DE1_SoC_task1.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Top-level module for Lab 4 Task 1. Instantiates binary search module and connects I/O to peripherals.
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	LEDR [10 bit] - Signal to output to 10 onboard LEDs, respectively.
*/
module DE1_SoC_task1 (
    output logic [6:0] HEX0
    ,output logic [9:0] LEDR
    ,input logic [3:0] KEY
    ,input logic [9:0] SW
    ,input logic CLOCK_50
    );
	
    // Bit counting module
    // In: num, start, clk, reset
    // Out: result, done
    logic [3:0] result;
    bit_counter bc (
         .result(result)
		,.num(SW[7:0])
        ,.done(LEDR[9])
        ,.start(SW[9])
        ,.clk(CLOCK_50)
        ,.reset(~KEY[0]) 
    );

    // Seven-Segment display
    // In: num
    // Out: HEX0, HEX1(unused)
    double_seg7 res_display (.HEX0(HEX0), .HEX1(), .num({4'b0, result}));
	
endmodule  // DE1_SoC_task1

/*
 * Testbench to test the functionality of the DE1_SoC_task1 module.
 */
module DE1_SoC_task1_testbench();

    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic CLOCK_50, clk;
	
    assign CLOCK_50 = clk;
	
	 DE1_SoC_task1 dut (.*);
	
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk;
    end

    initial begin
        integer i;

        // Load value
        @(posedge clk) KEY[0] <= 1'b0; SW[7:0] <= 8'b10000001; SW[9] <= 0;
        @(posedge clk); KEY[0] <= 1'b1;
        // Start count
        @(posedge clk) SW[9] <= 1;

        for (i = 0; i < 16; i++) begin
            @(posedge clk);
        end
        // Load value
        @(posedge clk) SW[9] <= 0; SW[7:0] <= 8'b0;
        @(posedge clk);
        // Start count
        @(posedge clk) SW[9] <= 1;
        for (i = 0; i < 5; i++) begin
            @(posedge clk);
        end
        
        @(posedge clk);
        @(posedge clk);

        $stop;
    end

endmodule  // DE1_SoC_task1_testbench

/*********************************** 

double_seg7.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Defines data for 2-digit hexadecimal HEX display given a 8-bit unsigned integer
 
 * Inputs:
 *		num [8 bit] - An unsigned integer value [0x0-0x7F] to display
 
 * Outputs:
 * 	HEX0 [7 bit] - A HEX display for the least significant digit of the input num, formatted in standard seven segment display format
 * 	HEX1 [7 bit] - A HEX display for the most significant digit of the input num, formatted in standard seven segment display format
*/
module double_seg7(
	output logic [6:0] HEX0, HEX1
	,input logic [7:0] num
	);

	// Drive HEX output signals given num
	always_comb begin
		// Light HEX0 using LSD of num
		case (num[3:0])
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
			10: HEX0 = ~7'b1110111;  // A
			11: HEX0 = ~7'b1111100;  // b
			12: HEX0 = ~7'b1011000;  // c
			13: HEX0 = ~7'b1011110;  // d
			14: HEX0 = ~7'b1111001;  // E
			15: HEX0 = ~7'b1110001;  // F
			default: HEX0 = 7'bX;
		endcase
		
		// Light HEX1 using MSD of num
		case (num >> 4)
			//     Light: 6543210
			 0: HEX1 = ~7'b0111111;  // 0 
			 1: HEX1 = ~7'b0000110;  // 1 
			 2: HEX1 = ~7'b1011011;  // 2 
			 3: HEX1 = ~7'b1001111;  // 3 
			 4: HEX1 = ~7'b1100110;  // 4 
			 5: HEX1 = ~7'b1101101;  // 5 
			 6: HEX1 = ~7'b1111101;  // 6 
			 7: HEX1 = ~7'b0000111;  // 7 
			 8: HEX1 = ~7'b1111111;  // 8 
			 9: HEX1 = ~7'b1101111;  // 9
			10: HEX1 = ~7'b1110111;  // A
			11: HEX1 = ~7'b1111100;  // b
			12: HEX1 = ~7'b1011000;  // c
			13: HEX1 = ~7'b1011110;  // d
			14: HEX1 = ~7'b1111001;  // E
			15: HEX1 = ~7'b1110001;  // F 
			default: HEX1 = 7'bX;
		endcase

	end
	
endmodule  // double_seg7

/*
 * Tests the functionality of the double_seg7 module.
*/
module double_seg7_testbench();

	logic [6:0] HEX0, HEX1;
	logic [7:0] num;
	
	double_seg7 dut (.HEX0, .HEX1, .num);
	
	initial begin
	
		integer i;
		
		// Check HEX displays for integers 0x0-0xff
		for (i = 0; i <= 8'hFF; i++) begin
			#10 num = i;
		end
		#50;
	end

endmodule  // double_seg7_testbench

/*********************************** 

binary_search.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Instantiates the controller and datapath modules and defines connections.
 
 * Inputs:
 *		num [8 bit] - An unsigned integer value to search for in the system's RAM.
 *		start [1 bit] - Signal to begin the binary searching process. While start is 0 and the search is not in progress,
 *						the input value num is loaded into the system. When start is 1, the search begins. Once the search
 *						is complete, the next value of num will be loaded once start is lowered to 0.
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the system to its initial state before the search process has started.
 
 * Outputs:
 * 	index [5 bit] - The index of the given num in the system's RAM. This index value is valid if and only if found is raised.
 *					If found and not_found are 0, the search is not complete.
 *	found [1 bit] - 1 if the search is complete and num was found in the system's RAM. 0 otherwise.
 * 	not_found [1 bit] - 1 if the search is complete and num was not found in the system's RAM. 0 otherwise.
*/
module binary_search (
    output logic [4:0] index
    ,output logic found, not_found
    ,input logic [7:0] num
    ,input logic start, clk, reset
    );
    
	// Controller Module
	// In: a_eq_t, s_zero, start, clk, reset
	// Out: load_A, try_S
    logic load_A, try_S, a_eq_t, s_zero;
    bs_ctrl controller (
         .load_A(load_A)
        ,.try_S(try_S)
        ,.start(start)
        ,.a_eq_t(a_eq_t)
        ,.s_zero(s_zero)
        ,.clk(clk)
        ,.reset(reset)
    );

	// Datapath module
	// In: A_in (user input), load_A, try_S (from controller), clk
	// Out: index (answer), found, not_found (done & success?)
    bs_data datapath (
         .index(index)
		,.found(found)
		,.not_found(not_found)
        ,.a_eq_t(a_eq_t)
        ,.s_zero(s_zero)
        ,.A_in(num)
        ,.load_A(load_A)
        ,.try_S(try_S)
        ,.clk(clk)
    );

endmodule  // binary_search

/*
 * The testbench module to test the functionality of the binary_search module.
*/
`timescale 1 ps / 1 ps
module binary_search_testbench();

	logic [4:0] index;
	logic found, not_found;
	logic [7:0] num;
	logic start, clk, reset;
	
	binary_search dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) reset <= 1'b1; start <= 1'b0; num <= 11;
		@(posedge clk) reset <= 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) start <= 1'b1;
		
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		
		@(posedge clk) start <= 1'b0; num <= 55;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) start <= 1'b1;
		
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  // binary_search_testbench

/*********************************** 

bs_ctrl.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Controller module for the binary search system.
 
 * Inputs:
 *		start [1 bit] - Signal to begin the binary searching process. While start is 0 and the search is not in progress,
 *						the input value num is loaded into the system. When start is 1, the search begins. Once the search
 *						is complete, the next value of num will be loaded once start is lowered to 0.
 *      a_eq_t [1 bit] - 1 if the search is complete and the number was found in RAM, 0 o.w.
 *      s_zero [1 bit] - 1 if the search is complete and the number was not found in RAM, 0 o.w.
 *		clk [1 bit] - The clock to use for this module.
 *		reset [1 bit] - Resets the system to its initial state before the search process has started.
 
 * Outputs:
 *      load_A [1 bit] - 1 if A should be sampled from the user during this cycle, 0 o.w.
 *      try_S [1 bit] - 1 if the next bit index of the RAM address should be tested during this cycle, 0 o.w.
*/
module bs_ctrl (
    output logic load_A, try_S
    ,input logic start, a_eq_t, s_zero, clk, reset
    );

    typedef enum logic [1:0] { s_start, s_load, s_search, s_done } state;

    state ps, ns;

    logic start_reg;

    always_comb begin
        // Handle state transitions
        case (ps)

            s_start: begin
                if (start_reg) begin
                    ns = s_load;
                end else begin
                    ns = s_start;
                end
            end

            s_load: begin
                ns = s_search;
            end

            s_search: begin
                if (a_eq_t | s_zero) begin
                    ns = s_done;
                end else begin
                    ns = s_load;
                end
            end

            s_done: begin
                if (~start_reg) begin
                    ns = s_start;
                end else begin
                    ns = s_done;
                end
            end

        endcase

        // Control signals to datapath
		load_A = (ps == s_start);

        try_S = (ps == s_search);
    end

    always_ff @(posedge clk) begin
        // Register state and start input
        if (reset) begin
            ps <= s_start;
        end else begin
            ps <= ns;
        end

        start_reg <= start;
    end

endmodule  // bs_ctrl

/*
 * Module to test the functionality of the bs_ctrl module
 */
module bs_ctrl_testbench();

	 logic load_A, try_S;
    logic start, a_eq_t, s_zero, clk, reset;
	 
	 bs_ctrl dut (.*);
	 
	 parameter CLOCK_PERIOD = 100;
	 initial begin
	     clk <= 0;
		  forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	 end
	 
	 initial begin
	     integer i;
		  
          // Hold in start state
		  start <= 1'b0; a_eq_t <= 1'b0; s_zero <= 1'b0; reset <= 1'b1;
		  @(posedge clk) reset <= 1'b0;
          @(posedge clk);
          @(posedge clk);
          @(posedge clk);
          // Begin the search process
		  @(posedge clk) start <= 1'b1;
		 
		  for (i = 0; i < 10; i++) begin
		      @(posedge clk);
		  end
          // Search success
		  a_eq_t <= 1'b1;
		  // Hold in done state
		  for (i = 0; i < 5; i++) begin
		      @(posedge clk);
		  end
		  // Go back to start
		  start <= 1'b0; a_eq_t <= 1'b0; s_zero <= 1'b0;
		  for (i = 0; i < 5; i++) begin
		      @(posedge clk);
		  end
		  // Search
		  @(posedge clk) start <= 1'b1;
		 
		  for (i = 0; i < 10; i++) begin
		      @(posedge clk);
		  end
          // Search failure
		  s_zero <= 1'b1;
		  for (i = 0; i < 5; i++) begin
		      @(posedge clk);
		  end
		  
		  $stop;
	 end

endmodule  // bs_ctrl_testbench

/*********************************** 

bs_data.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Datapath module for the binary search system.
 
 * Inputs:
 *		A_in [8 bit] - The number to search for in the RAM. Latched when load_A is true
 *		load_A [1 bit] - 1 if A_in should be sampled, 0 o.w.
 *		try_S [1 bit] - 1 if the next bit in the index should be tested, 0 o.w.
 *		clk [1 bit] - The clock to use for this module.
 
 * Outputs:
 *      index [5 bit] - The index of the sampled A_in value in the RAM. Valid if and only if found is 1.
 *      a_eq_t [1 bit] - Feedback if the sampled A_in value is equal to the currently read value from RAM. 1 if eq, 0 o.w.
 *		s_zero [1 bit] - Feedback if all bits have been tested in the index. 1 if true, 0 o.w.
 *		found [1 bit] - 1 if the search is complete and the sampled A_in was found in RAM, 0 o.w.
 *		not_found [1 bit] - 1 if the search is complete and the sampled A_in was not found in RAM, 0 o.w.
*/
module bs_data (
    output logic [4:0] index
    ,output logic a_eq_t, s_zero, found, not_found
    ,input logic [7:0] A_in
    ,input logic load_A, try_S, clk
    );
	 
    logic [4:0] I, S;
    logic [7:0] T, A;

	// RAM block
	// In: address/I(ndex), clk
	// Out: data/wren - unused; q - data
	ram32x8 ram (
	     .address(I)
		,.clock(clk)
		,.data(8'b0)
		,.wren(1'b0)
		,.q(T)
	);
	 
	assign a_eq_t = (A == T);
	assign s_zero = (S == '0);

    always_ff @(posedge clk) begin
	 
		if (load_A) begin
		    S <= 5'b10000;
			I <= 5'b10000;
			A <= A_in;
		end
		  
		if (try_S) begin
		    S <= S >> 1;
			if (T > A) begin
				I <= (I ^ S) | (S >> 1);
			end else if (T < A) begin
				I <= I | (S >> 1);
			end
		end

		index <= I;
		found <= (A == T);
		not_found <= (A != T) & (S == 0);
    end

endmodule  // bs_data

/*
 * Testbench to test the functionality of the bs_data module
 */
`timescale 1 ps / 1 ps
module bs_data_testbench();

	logic [4:0] index;
	logic found, not_found, a_eq_t, s_zero;
	logic [7:0] A_in;
	logic load_A, try_S, clk;
	
	bs_data dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		// Load value
		A_in <= 13; load_A <= 1'b1; try_S <= 1'b0;
		
		// Search
		for (i = 0; i < 10; i++) begin
		    @(posedge clk); load_A <= 1'b0; try_S <= 1'b0;
			@(posedge clk); load_A <= 1'b0; try_S <= 1'b1;
		end
		
		// Load
		@(posedge clk) A_in <= 33; load_A <= 1'b1; try_S <= 1'b0;
		// Search
		for (i = 0; i < 10; i++) begin
		    @(posedge clk); load_A <= 1'b0; try_S <= 1'b0;
			@(posedge clk); load_A <= 1'b0; try_S <= 1'b1;
		end
		
		$stop;
	
	end

endmodule  // bs_data_testbench

/*********************************** 

DE1_SoC_task2.sv

***********************************/

/*
 * Connor Aksama
 * 02/12/2023
 * CSE 371
 * Lab 4
*/

/**
 * Top-level module for Lab 4 Task 2. Instantiates binary search module and connects I/O to peripherals.
 
 * Inputs:
 * 	SW [10 bit] - The 10 onboard switches, respectively.
 *  KEY [4 bit] - The 4 onboard keys, respectively.
 *  CLOCK_50 [1 bit] - The system clock to use for this module.
 
 * Outputs:
 * 	HEX0 [7 bit] - Data to show on the HEX0 display, formatted in standard 7 segment display format.
 * 	HEX1 [7 bit] - Data to show on the HEX1 display, formatted in standard 7 segment display format.
 * 	LEDR [10 bit] - Signal to output to 10 onboard LEDs, respectively.
*/
module DE1_SoC_task2 (
    output logic [6:0] HEX0, HEX1
    ,output logic [9:0] LEDR
    ,input logic [9:0] SW
    ,input logic [3:0] KEY
    ,input logic CLOCK_50
    );
	 
	 assign LEDR[7:0] = 8'b0;

	// Seven-Segment display
	// In: num
	// Out: HEX0, HEX1
	logic [7:0] index;
	double_seg7 addr (
          .HEX0(HEX0)
         ,.HEX1(HEX1)
         ,.num(index)
    );

	// Binary search module
	// In: num (switch input), start (switch), clk, reset (key)
	// Out: index (final answer), found (success), not_found (failure)
    binary_search bs (
         .index(index)
        ,.found(LEDR[9])
        ,.not_found(LEDR[8])
        ,.num(SW[7:0])
        ,.start(SW[9])
        ,.clk(CLOCK_50)
        ,.reset(~KEY[0])
    );

endmodule  // DE1_SoC_task2

/*
 * Testbench to test the functionality of the DE1_SoC_task2 module
 */
`timescale 1 ps / 1 ps
module DE1_SoC_task2_testbench();

    logic [6:0] HEX0, HEX1;
    logic [9:0] LEDR;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic CLOCK_50, clk;
	 
	 assign CLOCK_50 = clk;
	 
	 DE1_SoC_task2 dut (.*);
	 
	 parameter CLOCK_PERIOD = 100;
	 initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	 end
	 
	 initial begin
		integer i;
		
		// Load num
		@(posedge clk) KEY[0] <= 1'b0; SW[9] <= 1'b0; SW[7:0] <= 8'b00001011;
		@(posedge clk) KEY[0] <= 1'b1;
		@(posedge clk);
		@(posedge clk);
		// Start
		@(posedge clk) SW[9] <= 1'b1;
		// Search
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		
		// Load
		@(posedge clk) SW[9] <= 1'b0; SW[7:0] <= 8'b00110111;
		@(posedge clk);
		@(posedge clk);
		// Start
		@(posedge clk) SW[9] <= 1'b1;
		// Search
		for (i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  // DE1_SoC_task2_testbench
