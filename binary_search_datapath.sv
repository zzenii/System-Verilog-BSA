/*
	binary_search_datapath serves as the datapath component of the BSA implementation. 
	This module accepts and outputs all data-related I/O, including
	8-bit A and data_out (in), 5-bit address and L (out), 1-bit found or not_found (out). 
	This module accomodates variable data and address widths based on the paired RAM/ROM.
*/

module binary_search_datapath #(
									parameter data_width = 8,
									parameter addr_width = 5
									)(
									input logic clk, reset,
									// control signals
									input logic value_found, value_not_found,
									input logic update_left, update_right, update_addr, update_arr_data,
									// data inputs
									input logic [data_width-1:0] A, data_out,
									// status signals
									output logic equal, greater_than, continue_search,
									// data outputs
									output logic [addr_width-1:0] L, address,
									output logic found, not_found
									);
	
	// Internal registers
	logic [data_width-1:0] value, arr_data;
	logic signed [addr_width+1:0] left, right;
	
	always_ff @(posedge clk) begin
		// Reset value of internal regs
		if (reset) begin
			value <= A;
			left <= '0;
			right <= 2**addr_width - 1;
			address <= (2**addr_width - 1) >> 1;
			L <= '0;
			found <= 1'b0;
			not_found <= 1'b0;
		end
		else begin
			// RTL operations per control signal.
			if (update_arr_data)
				arr_data <= data_out; // arr_data takes read contents from ROM.
			if (update_addr)
				address <= (left + right) >> 1; // address takes center value after left and right updates.
			if (update_left)
				left <= address + 1;
			if (update_right)
				right <= address - 1;
			if (value_found) begin
				found <= 1'b1;
				L <= address;
			end
			if (value_not_found)
				not_found <= 1'b1;
		end
	end // always
	
	// status signals
	assign equal = (value == arr_data);
	assign greater_than = (value > arr_data);
	assign continue_search = (right >= left);
	
endmodule
	