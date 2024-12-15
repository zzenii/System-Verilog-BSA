/*
	binary_search_control is the control unit behind the BSA implementation, which cycles between ASMD states
	and coordinates datapath operations through the assertion of control signals. See ASMD chart.
*/

module binary_search_control (
									// External Inputs
									input logic clk, reset, // Algorithm is initiated by the reset signal. 
									// Status signals
									input logic equal, greater_than, continue_search,
									// Control signals
									output logic value_found, value_not_found,
									output logic update_left, update_right, update_arr_data, update_addr
									);
	
	// State registers
	enum {s_idle, s_loop, s_update, s_check, s_done} ps, ns;

	// Next-state logic
	always_comb begin
		case (ps)
			s_idle: ns = s_loop;
			s_loop: ns = s_update;
			s_update: if (equal) ns = s_done;
						else ns = s_check;
			s_check: if (continue_search) ns = s_loop;
						else ns = s_done;
			s_done: ns = s_done;
		endcase
	end // always
	
	// Asserting control signals according to ASMD chart, coordinating relevant datapath operations.
	assign value_found = (ps == s_update) && equal;
	assign value_not_found = (ps == s_check) && !continue_search;
	assign update_left = (ps == s_update) && !equal && greater_than;
	assign update_right = (ps == s_update) && !equal && !greater_than;
	assign update_addr = (ps == s_update);
	assign update_arr_data = (ps == s_loop);
	
	// State transition on clock edge
	always_ff @(posedge clk) begin
		if (reset)
			ps <= s_idle;
		else
			ps <= ns;
	end //always
	
endmodule
