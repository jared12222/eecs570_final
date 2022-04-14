//`define ONE_ENGINE

module L_buffer_singleload (
	input                                   clock,
	input                                   reset,
	//load preprocess data
	input   node_t                          clause_in,
	input	dummy_entry_t                   ptr_in,
	input                                   load_clause_in, load_ptr_in, 
	`ifndef ONE_ENGINE
	input                                   load_change_engine_in,	//signal to load another engine
	`endif
	// uc from software decision(?

	output  node_t   				        clause_out,
	output 	logic[`NUM_ENGINE-1:0] 			clause_valid_out,
	output  dummy_ptr_t                     ptr_out, 
	output 	logic[`NUM_ENGINE-1:0] 			ptr_valid_out
);

	`ifndef ONE_ENGINE
		logic	[$clog2(`NUM_ENGINE)-1:0]    engine_indicator, next_engine_indicator;
		logic	[$clog2(`NUM_ENGINE)-1:0]    ptr_engine_indicator, next_ptr_engine_indicator;
	`endif

	node_t                           	 clause_in_blocked;
	dummy_entry_t                        ptr_in_blocked;
	logic                                load_clause_in_blocked, load_ptr_in_blocked, load_change_engine_in_blocked;

	logic    [$clog2(`LIT_IDX_MAX)+1:0]    counter, next_counter;
	dummy_ptr_t                          ptr_buffer, next_ptr_buffer;

	always_comb begin
		`ifndef ONE_ENGINE
			next_engine_indicator     = engine_indicator;
			next_ptr_engine_indicator = ptr_engine_indicator;
		`endif
		clause_out            = 0;
		clause_valid_out      = 0;
		ptr_out               = 0;
		ptr_valid_out         = 0;
		next_counter          = counter;
		next_ptr_buffer       = ptr_buffer;
		if (load_change_engine_in_blocked) begin
			`ifndef ONE_ENGINE
				next_engine_indicator = engine_indicator + 1;
			`endif
		end
		if (load_clause_in_blocked) begin
			clause_out                              = clause_in_blocked;
			`ifndef ONE_ENGINE
				clause_valid_out[next_engine_indicator] = 1;
			`else 
				clause_valid_out = 1;
			`endif
		end
		if (load_ptr_in_blocked) begin
			next_ptr_buffer[counter] = ptr_in_blocked;
			next_counter             = counter + 1;
			if (counter == 2*`LIT_IDX_MAX) begin
				`ifndef ONE_ENGINE
					ptr_valid_out[ptr_engine_indicator] = 1;
				`else 
					ptr_valid_out = 1;
				`endif
				for (int i = 0; i < 2*`LIT_IDX_MAX + 1; i++) begin
					ptr_out[i] = ptr_buffer[i];
				end
				next_counter = 0;
				`ifndef ONE_ENGINE
					next_ptr_engine_indicator = ptr_engine_indicator + 1;
				`endif
			end
		end
	end

	always_ff @(posedge clock)	begin
		if (reset) begin
			`ifndef ONE_ENGINE
				engine_indicator 					<= 0;
				ptr_engine_indicator                <= 0;
			`endif
			clause_in_blocked 					<= 0;
			ptr_in_blocked  					<= 0;
			load_clause_in_blocked 				<= 0; 
			load_ptr_in_blocked 				<= 0;
			load_change_engine_in_blocked  		<= 0;
			counter                             <= 0;
			for (int i = 0; i < 2*`LIT_IDX_MAX-1; i++) begin
				ptr_buffer[i] <= 0;
			end
		end
		else begin
			`ifndef ONE_ENGINE
				engine_indicator      <= next_engine_indicator;
				ptr_engine_indicator  <= next_ptr_engine_indicator;
			`endif
			clause_in_blocked 					<= clause_in;
			ptr_in_blocked  					<= ptr_in;
			load_clause_in_blocked 				<= load_clause_in; 
			load_ptr_in_blocked 				<= load_ptr_in;
			`ifndef ONE_ENGINE
			load_change_engine_in_blocked  		<= load_change_engine_in;
			`endif
			counter                             <= next_counter;
			ptr_buffer                          <= next_ptr_buffer;
		end
	end

endmodule
