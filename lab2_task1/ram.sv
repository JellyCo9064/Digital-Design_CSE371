/*
 * Connor Aksama
 * 01/18/2023
 * CSE 371
 * Lab 2
*/

/**
 * 32x4 RAM Module
 
 * Inputs:
 * 	addr    [5 bit] - Address to manipulate in the given module.
 *  data_in [4 bit] - Data to store at the specified address in the module.
 *  write   [1 bit] - Signal to enable writing the given data_in to the specified addr. If raised, the value at addr is updated to data_in; o.w. the value is unchanged.
 *  clk     [1 bit] - The clock to use for this module.
 
 * Outputs:
 * 	data_out [4 bit] - The data stored at the location specified by addr.
*/
module ram(
    output logic [3:0] data_out
    ,input logic [4:0] addr
    ,input logic [3:0] data_in
    ,input logic write, clk
    );

    // Flip-flop outputs
    logic [4:0] addr_reg;
    logic [3:0] data_in_reg;
    logic write_reg;

    // Memory cells
    logic [3:0] memory_array [31:0];

    // Use the registered address, output data at location
    assign data_out = memory_array[addr_reg];

    always_ff @(posedge clk) begin
        
        // Synchronize inputs
        addr_reg <= addr;
        data_in_reg <= data_in;
        write_reg <= write;

        // Write to addr if write enabled
        if (write_reg) memory_array[addr_reg] <= data_in_reg;

    end

endmodule  // ram

// Module to test the functionality of the ram module
module ram_testbench();

    logic [3:0] data_out;
    logic [4:0] addr;
    logic [3:0] data_in;
    logic write, clk;

    ram dut (.data_out, .addr, .data_in, .write, .clk);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk;
    end

    initial begin
        integer i;

        // Write to every address
        @(posedge clk) write <= 1; addr <= 0; data_in <= 0;
        for (i = 0; i < 32; i++) begin
            @(posedge clk) addr <= i; data_in <= i;
				@(posedge clk);
				@(posedge clk);
        end

        // Read from every address
        @(posedge clk) write <= 0;
        for (i = 31; i >= 0; i--) begin
            @(posedge clk) addr <= i;
				@(posedge clk);
        end
			$stop;
    end

endmodule  // ram_testbench
