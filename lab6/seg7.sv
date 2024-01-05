/*
 * Connor Aksama
 * 03/13/2023
 * CSE 371
 * Lab 6
*/

/**
 * Defines data for 1-digit hexadecimal HEX display given a 4-bit unsigned integer
 
 * Inputs:
 *		num [4 bit] - An unsigned integer value [0x0-0xF] to display
 
 * Outputs:
 * 		HEX [7 bit] - A HEX display for the input num, formatted in standard seven segment display format
*/
module seg7(
	output logic [6:0] HEX
	,input logic [3:0] num
	);

	// Drive HEX output signals given num
	always_comb begin
		// Light HEX using num
		case (num)
		    //     Light: 6543210
			 0: HEX = ~7'b0111111;  // 0 
			 1: HEX = ~7'b0000110;  // 1 
			 2: HEX = ~7'b1011011;  // 2 
			 3: HEX = ~7'b1001111;  // 3 
			 4: HEX = ~7'b1100110;  // 4 
			 5: HEX = ~7'b1101101;  // 5 
			 6: HEX = ~7'b1111101;  // 6 
			 7: HEX = ~7'b0000111;  // 7 
			 8: HEX = ~7'b1111111;  // 8 
			 9: HEX = ~7'b1101111;  // 9
			10: HEX = ~7'b1110111;  // A
			11: HEX = ~7'b1111100;  // b
			12: HEX = ~7'b1011000;  // c
			13: HEX = ~7'b1011110;  // d
			14: HEX = ~7'b1111001;  // E
			15: HEX = ~7'b1110001;  // F
			default: HEX = 7'bX;
		endcase
	end
	
endmodule  // seg7

/*
 * Tests the functionality of the seg7 module.
*/
module seg7_testbench();

	logic [6:0] HEX;
	logic [3:0] num;
	
	seg7 dut (.HEX, .num);
	
	initial begin
	
		integer i;
		
		// Check HEX displays for integers 0x0-0xff
		for (i = 0; i <= 15; i++) begin
			#10 num = i;
		end
		#50;
	end

endmodule  // seg7_testbench
