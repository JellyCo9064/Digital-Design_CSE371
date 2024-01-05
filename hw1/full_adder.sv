/*
 * Full Adder Module for hw1p1
 */
module full_adder (
	output logic S, C
	,input logic a, b, cin
	);
	
	assign S = a ^ b ^ cin; // sum bit
	assign C = a & b | cin & (a ^ b); // carry bit
	
endmodule

module full_adder_testbench();

	logic S, C;
	logic a, b, cin;
	
	full_adder dut (.S, .C, .a, .b, .cin);
	
	initial begin
		integer i;
		
		{a, b, cin} <= 0;
		
		for (i = 0; i < 8; i++) begin
			#50; {a, b, cin} <= i;
		end
		#50; $stop;
		
	end

endmodule
