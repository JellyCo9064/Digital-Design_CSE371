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
