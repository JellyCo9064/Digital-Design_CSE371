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