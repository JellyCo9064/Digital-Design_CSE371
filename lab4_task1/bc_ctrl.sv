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
