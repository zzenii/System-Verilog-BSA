/*
	binary_search is the SystemVerilog implementation of the Binary Search Algorithm (BSA).
	Given a 2**addr_width x data_width ROM containing sorted information, the module
	searches for a value (depicted by input A) in the ROM. If found, the value's address in the ROM
	is sent over output L, and 1-bit found is asserted. Else, 1-bit not_found is asserted.
	This module accomodates variable data and address widths based on the paired RAM/ROM.
*/

module binary_search #(
							parameter data_width = 8,
							parameter addr_width = 5
							)(
							input logic clk, reset,
							input logic [data_width-1:0] A, data_out, // data_out is the read data from the RAM/ROM. 
							output logic [addr_width-1:0] L, address,
							output logic found, not_found
							);
	
	logic update_addr, update_arr_data, update_left, update_right, value_found, value_not_found; // control signals
	logic equal, greater_than, continue_search; // status signals
	
	// Instance of the control module, that accepts status signals and external non-data inputs, and outputs control signals.
	binary_search_control controller (.*);
	
	// Instance of the datapath module, that accepts control signals and data-related inputs, and outputs status signals.
	binary_search_datapath datapath (.*);
	
endmodule
	
	
