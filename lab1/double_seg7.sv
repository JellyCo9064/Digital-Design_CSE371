/*
 * Connor Aksama
 * 01/13/2023
 * CSE 371
 * Lab 1
*/

/**
 * Defines data for 2-digit decimal HEX display given a 7-bit unsigned integer from [0-99].
 * Output data for input numbers with 3 digits is undefined.
 
 * Inputs:
 *		num [7 bit] - An unsigned integer value [0-99] to display
 
 * Outputs:
 * 	HEX0 [7 bit] - A HEX display for the ones digit of the input num, formatted in standard seven segment display format
 * 	HEX1 [7 bit] - A HEX display for the tens digit of the input num, formatted in standard seven segment display format
 *							HEX1 is blank if num < 10.
*/
module double_seg7(
	output logic [6:0] HEX0, HEX1
	,input logic [6:0] num
	);

	// Drive HEX output signals given num
	always_comb begin
		// Light HEX0 using ones place of num
		case (num % 10)
		   //     Light: 6543210
			0: HEX0 = ~7'b0111111;  // 0 
			1: HEX0 = ~7'b0000110;  // 1 
			2: HEX0 = ~7'b1011011;  // 2 
			3: HEX0 = ~7'b1001111;  // 3 
			4: HEX0 = ~7'b1100110;  // 4 
			5: HEX0 = ~7'b1101101;  // 5 
			6: HEX0 = ~7'b1111101;  // 6 
			7: HEX0 = ~7'b0000111;  // 7 
			8: HEX0 = ~7'b1111111;  // 8 
			9: HEX0 = ~7'b1101111;  // 9 
			default: HEX0 = 7'bX;
		endcase
		
		// Light HEX1 using tens place of num
		case (num / 10)
		   //     Light: 6543210
			0: HEX1 = ~7'b0000000;  // 0 
			1: HEX1 = ~7'b0000110;  // 1 
			2: HEX1 = ~7'b1011011;  // 2 
			3: HEX1 = ~7'b1001111;  // 3 
			4: HEX1 = ~7'b1100110;  // 4 
			5: HEX1 = ~7'b1101101;  // 5 
			6: HEX1 = ~7'b1111101;  // 6 
			7: HEX1 = ~7'b0000111;  // 7 
			8: HEX1 = ~7'b1111111;  // 8 
			9: HEX1 = ~7'b1101111;  // 9 
			default: HEX1 = 7'bX;
		endcase

	end
	
endmodule  // double_seg7

/*
 * Tests the functionality of the double_seg7 module.
*/
module double_seg7_testbench();

	logic [6:0] HEX0, HEX1;
	logic [6:0] num;
	
	double_seg7 dut (.HEX0, .HEX1, .num);
	
	initial begin
	
		integer i;
		
		// Check HEX displays for integers 0-99
		for (i = 0; i <= 99; i++) begin
			#10 num = i;
		end
		#50;
	end

endmodule  // double_seg7_testbench
