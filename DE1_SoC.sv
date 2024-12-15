`timescale 1ns / 1ps

/*
	DE1_SoC serves as the top-level module to test binary_search with a 32x8 IP-Catalog ROM.
	
	This module ports FPGA inputs SW and KEY to binary_search inputs A and reset, 
	where A specifies the value to search for, and reset initiates the FSM.
	binary_search outputs L, found, not_found are ported to FPGA outputs HEX1/HEX0, LEDR9, LEDR8, respectively. 
	Finally, we port binary_search output address to the ROM to specify synchronous q-data data_out.
	
	Input KEY[0] is 'sanitized' by input_sanitizer, where a multi-clock-length signal is converted to a single pulse. 
	The HEX displays depict the contents of L according to the combinational module hex_to_7.
*/

module DE1_SoC (
					input CLOCK_50,
					input logic [0:0] KEY,
					input logic [7:0] SW,
					output logic [9:8] LEDR,
					output logic [6:0] HEX1, HEX0
					);
	
	// Temporary signals
	logic reset, found, not_found;
	logic [7:0] data_out;
	logic [4:0] address, L;
	
	// Sanitizing the reset signal asserted by KEY[0]
	input_sanitizer sanitized_reset (.clk(CLOCK_50), .reset(1'b0), .in(~KEY[0]), .out(reset));
	
	// Instance of the binary_search algorithm.
	binary_search search (.clk(CLOCK_50), .reset, .A(SW[7:0]), .data_out, .address, .L, .found, .not_found);
	
	// Instance of ROM (contains the data to search through)
	rom32x8 array (.clock(CLOCK_50), .address, .q(data_out));
	
	// FPGA outputs.
	assign LEDR[9] = found;
	assign LEDR[8] = not_found;
	
	// Convert L to a HEX-readable form.
	logic [6:0] hex_upper, hex_lower;
	hex_to_7 address_upper (.in({3'b0, L[4]}), .out(hex_upper));
	hex_to_7 address_lower (.in(L[3:0]), .out(hex_lower));
	
	// Depict L over HEX1/0 if the value was found. Else, depict '-'.
	always_comb begin
		if (found) begin
			HEX1 = hex_upper;
			HEX0 = hex_lower;
		end
		else begin
			HEX1 = 7'b0111111; // '-'
			HEX0 = 7'b0111111; // '-'
		end
	end // always
endmodule

