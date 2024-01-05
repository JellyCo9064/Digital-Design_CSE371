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
