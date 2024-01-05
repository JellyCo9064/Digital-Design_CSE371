/*
 * Connor Aksama
 * 02/23/2023
 * CSE 371
 * Lab 5
*/

/**
 * Top-level module for Lab 5
 
 * Inputs:
 *		CLOCK_50 [1 bit] - clock to use for this system
 *		CLOCK2_50 [1 bit] - clock to use for clock generator
 *		KEY [1 bit] - Onboard KEY0 input signal
 *		SW [10 bit] - Onboard SW input signals
 *		AUD_DACLRCK [1 bit] - Audio CODEC interface signal
 *		AUD_ADCLRCK [1 bit] - Audio CODEC interface signal
 *		AUD_BCLK [1 bit] - Audio CODEC interface signal
 *		AUD_ADCDAT [1 bit] - Audio CODEC interface signal
 * Inouts:
 *		FPGA_I2C_SDAT [1 bit] - Audio CODEC interface signal
 * Outputs:
 * 		FPGA_12C_SCLK [1 bit] - Audio CODEC interface signal
 *		AUD_XCK [1 bit] - Audio CODEC interface signal
 *		AUD_DACDAT [1 bit] - Audio CODEC interface signal
*/
module part1 (CLOCK_50, CLOCK2_50, KEY, SW, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [9:0] SW;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	reg [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	/////////////////////////////////
	// Your code goes here 
	/////////////////////////////////
	
	wire [23:0] tone_data;
	
	// Tone sample generator
	// tone_data - current tone sample
	// write - signal to get next sample from ROM
	// CLOCK_50 - clk to use for generator
	// reset - reset the generator to the starting sample
	tone_generator gen (
		 tone_data
		,write
		,CLOCK_50
		,reset
	);
	
	// Mux the write data to the CODEC based on SW9
	always @(tone_data, readdata_left, readdata_right, SW[9]) begin
		if (SW[9]) begin
			writedata_left = tone_data;
			writedata_right = tone_data;
		end else begin
			writedata_left = readdata_left;
			writedata_right = readdata_right;
		end
	end
	
	assign read = read_ready;
	assign write = write_ready & (read_ready | SW[9]);
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


