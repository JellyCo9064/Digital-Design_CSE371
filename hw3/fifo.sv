/* FIFO buffer FWFT implementation for specified data and address
 * bus widths based on internal register file and FIFO controller.
 * Inputs: 1-bit rd removes head of buffer and 1-bit wr writes
 * w_data to the tail of the buffer.
 * Outputs: 1-bit empty and full indicate the status of the buffer
 * and r_data holds the value of the head of the buffer (unless empty).
 */
module fifo #(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
            (clk, reset, rd, wr, empty, full, w_data, r_data);

	input  logic clk, reset, rd, wr;
	output logic empty, full;
	input  logic [DATA_WIDTH*2-1:0] w_data;
	output logic [DATA_WIDTH-1:0] r_data;
	
	// signal declarations
	logic [ADDR_WIDTH-1:0] w_addr, r_addr;
	logic w_en;
	
	// enable write only when FIFO is not full
	// or if reading and writing simultaneously
	assign w_en = wr & (~full | rd);
	
	// instantiate FIFO controller and register file
	fifo_ctrl #(ADDR_WIDTH) c_unit (.*);

	reg_file #(DATA_WIDTH, ADDR_WIDTH) r_unit (.*);
	
endmodule  // fifo

module fifo_testbench();

	parameter DATA_WIDTH = 8, ADDR_WIDTH = 4;
	
	logic clk, reset, rd, wr;
	logic empty, full;
	logic [DATA_WIDTH*2-1:0] w_data;
	logic [DATA_WIDTH-1:0] r_data;
	
	fifo #(DATA_WIDTH, ADDR_WIDTH) dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 1'b0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		integer i;
		
		@(posedge clk) reset <= 1; wr <= 0; rd <= 0; w_data <= 16'b11110000_00001111;

		// Write to queue until full, try to write while full
		@(posedge clk) wr <= 1; reset <= 0;
		for (i = 0; i < 10; i++) begin
			@(posedge clk);
		end

		// Read from queue until empty, try to read while empty
		@(posedge clk) wr <= 0; rd <= 1;
		for (i = 20; i >= 0; i--) begin
			@(posedge clk);
		end

		// Write some elements
		@(posedge clk) wr <= 1; rd <= 0;
		for (i = 0; i < 5; i++) begin
			@(posedge clk) w_data <= i;
		end
		
		// Read one element
		@(posedge clk) wr <= 0; rd <= 1;
		@(posedge clk) rd <= 0;
		
		// Try writing until full
		@(posedge clk) wr <= 1; rd <= 0;
		for (i = 0; i < 5; i++) begin
			@(posedge clk) w_data <= i;
		end

		// Reset
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		@(posedge clk);
		@(posedge clk);
		
		// Read and Write at the same time
		@(posedge clk) wr <= 1; rd <= 1;
		for (i = 0; i < 20; i++) begin
			@(posedge clk) w_data <= i;
		end
		
		@(posedge clk) wr <= 0; rd <= 0;
		for (i = 0; i < 5; i++) begin
			@(posedge clk);
		end
		$stop;
	end

endmodule  // fifo_testbench