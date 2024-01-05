/*
 * Connor Aksama
 * 01/30/2023
 * CSE 371
 * Lab 3
*/

/**
 * Outputs the endpoints of the current line to draw on the display and a signal indicating whether
 * the scren should be cleared.
 
 * Inputs:
 * 	clk [1 bit] - the clock to use for this module
*	reset [1 bit] - the reset signal for this module; resets to the first frame when raised
 
 * Outputs:
 * 	x0 [10 bit] - The x coordinate of the first point of the line to draw
 *  y0 [9 bit] - The y coordinate of the first point of the line to draw 
 *	x1 [10 bit] - The x coordinate of the second point of the line to draw 
 *	y1 [9 bit] - The y coordinate of the second point of the line to draw 
 *	clear [1 bit] - Signal to indicate when the screen should be cleared
*/
module animator#(
	parameter frame_time = 833333
	)(
	output logic [9:0] x0, x1
	,output logic [8:0] y0, y1
	,output logic clear
	,input logic clk, reset
	);
	
	logic next_frame, next_frame_q;
	logic [31:0] frame_num;
	
	// Counter to time the duration of each frame
	// timer_out -> number of cycles current frame is active
	// inc on every cycle; no dec; use same clock, reset on frame switch/reset
	logic [31:0] timer_out;
	counter_32b timer (.count(timer_out), .inc(1'b1), .dec(1'b0), .clk, .reset(reset | next_frame));
	
	// Counter to keep track of the current frame number
	// frame_num -> current frame number
	// inc on every frame switch; no dec; use same clock, reset on end of sequence/reset
	logic frame_reset;
	counter_32b frame_counter (.count(frame_num), .inc(next_frame_q), .dec(1'b0), .clk, .reset(reset | frame_reset));
	
	// Determine if timer expired, switch to next frame logic
	always_comb begin
	
		// Check for next frame
		next_frame = (timer_out >= frame_time - 1) && !next_frame_q;

		// Clear screen every other frame
		clear = ~frame_num[0];
		
		// End of sequence reached
		frame_reset = (frame_num >= 100);

		// Frames
		case (frame_num[31:1])

			0:begin x0=420;y0=240;x1=220;y1=240;end  1:begin x0=419;y0=243;x1=221;y1=237;end  2:begin x0=419;y0=246;x1=221;y1=234;end  3:begin x0=419;y0=249;x1=221;y1=231;end  
			4:begin x0=419;y0=252;x1=221;y1=228;end  5:begin x0=418;y0=255;x1=222;y1=225;end  6:begin x0=418;y0=258;x1=222;y1=222;end  7:begin x0=417;y0=261;x1=223;y1=219;end  
			8:begin x0=416;y0=264;x1=224;y1=216;end  9:begin x0=416;y0=267;x1=224;y1=213;end  10:begin x0=415;y0=270;x1=225;y1=210;end  11:begin x0=414;y0=273;x1=226;y1=207;end  
			12:begin x0=412;y0=276;x1=228;y1=204;end  13:begin x0=411;y0=279;x1=229;y1=201;end  14:begin x0=410;y0=282;x1=230;y1=198;end  15:begin x0=409;y0=285;x1=231;y1=195;end  
			16:begin x0=407;y0=288;x1=233;y1=192;end  17:begin x0=406;y0=290;x1=234;y1=190;end  18:begin x0=404;y0=293;x1=236;y1=187;end  19:begin x0=402;y0=296;x1=238;y1=184;end  
			20:begin x0=400;y0=298;x1=240;y1=182;end  21:begin x0=399;y0=301;x1=241;y1=179;end  22:begin x0=397;y0=303;x1=243;y1=177;end  23:begin x0=395;y0=306;x1=245;y1=174;end  
			24:begin x0=392;y0=308;x1=248;y1=172;end  25:begin x0=390;y0=310;x1=250;y1=170;end  26:begin x0=388;y0=312;x1=252;y1=168;end  27:begin x0=386;y0=315;x1=254;y1=165;end  
			28:begin x0=383;y0=317;x1=257;y1=163;end  29:begin x0=381;y0=319;x1=259;y1=161;end  30:begin x0=378;y0=320;x1=262;y1=160;end  31:begin x0=376;y0=322;x1=264;y1=158;end  
			32:begin x0=373;y0=324;x1=267;y1=156;end  33:begin x0=370;y0=326;x1=270;y1=154;end  34:begin x0=368;y0=327;x1=272;y1=153;end  35:begin x0=365;y0=329;x1=275;y1=151;end  
			36:begin x0=362;y0=330;x1=278;y1=150;end  37:begin x0=359;y0=331;x1=281;y1=149;end  38:begin x0=356;y0=332;x1=284;y1=148;end  39:begin x0=353;y0=334;x1=287;y1=146;end  
			40:begin x0=350;y0=335;x1=290;y1=145;end  41:begin x0=347;y0=336;x1=293;y1=144;end  42:begin x0=344;y0=336;x1=296;y1=144;end  43:begin x0=341;y0=337;x1=299;y1=143;end  
			44:begin x0=338;y0=338;x1=302;y1=142;end  45:begin x0=335;y0=338;x1=305;y1=142;end  46:begin x0=332;y0=339;x1=308;y1=141;end  47:begin x0=329;y0=339;x1=311;y1=141;end  
			48:begin x0=326;y0=339;x1=314;y1=141;end  49:begin x0=323;y0=339;x1=317;y1=141;end  50:begin x0=320;y0=340;x1=320;y1=140;end  51:begin x0=317;y0=339;x1=323;y1=141;end  
			52:begin x0=314;y0=339;x1=326;y1=141;end  53:begin x0=311;y0=339;x1=329;y1=141;end  54:begin x0=308;y0=339;x1=332;y1=141;end  55:begin x0=305;y0=338;x1=335;y1=142;end  
			56:begin x0=302;y0=338;x1=338;y1=142;end  57:begin x0=299;y0=337;x1=341;y1=143;end  58:begin x0=296;y0=336;x1=344;y1=144;end  59:begin x0=293;y0=336;x1=347;y1=144;end  
			60:begin x0=290;y0=335;x1=350;y1=145;end  61:begin x0=287;y0=334;x1=353;y1=146;end  62:begin x0=284;y0=332;x1=356;y1=148;end  63:begin x0=281;y0=331;x1=359;y1=149;end  
			64:begin x0=278;y0=330;x1=362;y1=150;end  65:begin x0=275;y0=329;x1=365;y1=151;end  66:begin x0=272;y0=327;x1=368;y1=153;end  67:begin x0=270;y0=326;x1=370;y1=154;end  
			68:begin x0=267;y0=324;x1=373;y1=156;end  69:begin x0=264;y0=322;x1=376;y1=158;end  70:begin x0=262;y0=320;x1=378;y1=160;end  71:begin x0=259;y0=319;x1=381;y1=161;end  
			72:begin x0=257;y0=317;x1=383;y1=163;end  73:begin x0=254;y0=315;x1=386;y1=165;end  74:begin x0=252;y0=312;x1=388;y1=168;end  75:begin x0=250;y0=310;x1=390;y1=170;end  
			76:begin x0=248;y0=308;x1=392;y1=172;end  77:begin x0=245;y0=306;x1=395;y1=174;end  78:begin x0=243;y0=303;x1=397;y1=177;end  79:begin x0=241;y0=301;x1=399;y1=179;end  
			80:begin x0=240;y0=298;x1=400;y1=182;end  81:begin x0=238;y0=296;x1=402;y1=184;end  82:begin x0=236;y0=293;x1=404;y1=187;end  83:begin x0=234;y0=290;x1=406;y1=190;end  
			84:begin x0=233;y0=288;x1=407;y1=192;end  85:begin x0=231;y0=285;x1=409;y1=195;end  86:begin x0=230;y0=282;x1=410;y1=198;end  87:begin x0=229;y0=279;x1=411;y1=201;end  
			88:begin x0=228;y0=276;x1=412;y1=204;end  89:begin x0=226;y0=273;x1=414;y1=207;end  90:begin x0=225;y0=270;x1=415;y1=210;end  91:begin x0=224;y0=267;x1=416;y1=213;end  
			92:begin x0=224;y0=264;x1=416;y1=216;end  93:begin x0=223;y0=261;x1=417;y1=219;end  94:begin x0=222;y0=258;x1=418;y1=222;end  95:begin x0=222;y0=255;x1=418;y1=225;end  
			96:begin x0=221;y0=252;x1=419;y1=228;end  97:begin x0=221;y0=249;x1=419;y1=231;end  98:begin x0=221;y0=246;x1=419;y1=234;end  99:begin x0=221;y0=243;x1=419;y1=237;end
			default: begin x0=0;y0=0;x1=0;y1=0; end

		endcase
	
	end
	
	// Register the next frame signal to frame counter
	always_ff @(posedge clk) begin
		if (reset) begin
			next_frame_q <= 0;
		end else begin
			next_frame_q <= next_frame;
		end
	end
	
endmodule  // animator

// Module to test the functionality of the animator module
module animator_testbench();

	logic [9:0] x0, x1;
	logic [8:0] y0, y1;
	logic clear;
	logic clk, reset;
	
	animator #(2) dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end

	initial begin
		integer i;
		
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		
		// Run through each of the frames in the animation
		for (i = 0; i < 500; i++) @(posedge clk);
		
		$stop;
	end
	

endmodule  // animator_testbench
