/*
 * Connor Aksama
 * 01/18/2023
 * CSE 371
 * Lab 2
*/

/**
 * Defines data for 2-digit hexadecimal HEX display given a 8-bit unsigned integer
 
 * Inputs:
 *		num [8 bit] - An unsigned integer value [0x0-0x7F] to display
 
 * Outputs:
 * 	HEX0 [7 bit] - A HEX display for the least significant digit of the input num, formatted in standard seven segment display format
 * 	HEX1 [7 bit] - A HEX display for the most significant digit of the input num, formatted in standard seven segment display format
*/
module double_seg7(
	output logic [6:0] HEX0, HEX1
	,input logic [7:0] num
	);

	// Drive HEX output signals given num
	always_comb begin
		// Light HEX0 using LSD of num
		case (num[3:0])
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
			10: HEX0 = ~7'b1110111;  // A
			11: HEX0 = ~7'b1111100;  // b
			12: HEX0 = ~7'b1011000;  // c
			13: HEX0 = ~7'b1011110;  // d
			14: HEX0 = ~7'b1111001;  // E
			15: HEX0 = ~7'b1110001;  // F
			default: HEX0 = 7'bX;
		endcase
		
		// Light HEX1 using MSD of num
		case (num >> 4)
			//     Light: 6543210
			 0: HEX1 = ~7'b0111111;  // 0 
			 1: HEX1 = ~7'b0000110;  // 1 
			 2: HEX1 = ~7'b1011011;  // 2 
			 3: HEX1 = ~7'b1001111;  // 3 
			 4: HEX1 = ~7'b1100110;  // 4 
			 5: HEX1 = ~7'b1101101;  // 5 
			 6: HEX1 = ~7'b1111101;  // 6 
			 7: HEX1 = ~7'b0000111;  // 7 
			 8: HEX1 = ~7'b1111111;  // 8 
			 9: HEX1 = ~7'b1101111;  // 9
			10: HEX1 = ~7'b1110111;  // A
			11: HEX1 = ~7'b1111100;  // b
			12: HEX1 = ~7'b1011000;  // c
			13: HEX1 = ~7'b1011110;  // d
			14: HEX1 = ~7'b1111001;  // E
			15: HEX1 = ~7'b1110001;  // F 
			default: HEX1 = 7'bX;
		endcase

	end
	
endmodule  // double_seg7

/*
 * Tests the functionality of the double_seg7 module.
*/
module double_seg7_testbench();

	logic [6:0] HEX0, HEX1;
	logic [7:0] num;
	
	double_seg7 dut (.HEX0, .HEX1, .num);
	
	initial begin
	
		integer i;
		
		// Check HEX displays for integers 0x0-0xff
		for (i = 0; i <= 2'hFF; i++) begin
			#10 num = i;
		end
		#50;
	end

endmodule  // double_seg7_testbench
