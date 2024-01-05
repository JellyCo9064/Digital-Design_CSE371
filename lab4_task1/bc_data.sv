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
