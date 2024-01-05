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
