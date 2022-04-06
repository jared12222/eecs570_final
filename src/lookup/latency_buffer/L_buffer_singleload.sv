`define LIT_IDX_MAX 1024
`define NUM_CLAUSE	8
`define CLA_LENGTH 3
`define NUM_ENGINE 4
`define CLQ_DEPTH 64


//uncomment the following line if NUM_ENGINE == 1
//`define ONE_ENGINE

module L_buffer_singleload (
	input                                   clock,
	input                                   reset,
	//load preprocess data
	input   node_t                          clause_in,
	input	ptr_t                           ptr_in,
	input                                   load_clause_in, load_ptr_in, 
	`ifndef ONE_ENGINE
	input                                   load_change_engine_in,	//signal to load another engine
	`endif
	// uc from software decision(?
	//input   lit_t                           uc_in,
	//input                                   load_uc_in,

	output  node_t                          clause_out,
	output 	logic[`NUM_ENGINE-1:0]          clause_valid_out,
	output  dummy_ptr_t                     ptr_out, 
	output 	logic[`NUM_ENGINE-1:0]          ptr_valid_out//, uc_valid_out 		
	//uc_out is placed in clause_out[0] since load uc and load clause won't happen at the same time
);

	`ifndef ONE_ENGINE
		logic	[$clog2(`NUM_ENGINE)-1:0]    engine_indicator, next_engine_indicator;
	`endif

	cla_t                                clause_in_blocked;
	ptr_t                                ptr_in_blocked;
	logic                                load_clause_in_blocked, load_ptr_in_blocked, load_change_engine_in_blocked;
	lit_t                                uc_in_blocked;
	logic                                load_uc_in_blocked;

	always_comb begin
		`ifndef ONE_ENGINE
			next_engine_indicator = engine_indicator;
		`endif
		clause_out            = 0;
		clause_valid_out      = 0;
		ptr_out               = 0;
		ptr_valid_out         = 0;
		uc_valid_out          = 0;
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
			ptr_out = ptr_in_blocked;
			`ifndef ONE_ENGINE
				ptr_valid_out[next_engine_indicator] = 1;
			`else 
				ptr_valid_out = 1;
			`endif
		end
		if (load_uc_in_blocked) begin
			clause_out[0] = uc_in_blocked;
			uc_valid_out  = 1;
		end
	end

	always_ff @(posedge clock)	begin
		if (reset) begin
			`ifndef ONE_ENGINE
				engine_indicator             <= 0;
			`endif
			clause_in_blocked                <= 0;
			ptr_in_blocked                   <= 0;
			load_clause_in_blocked           <= 0; 
			load_ptr_in_blocked              <= 0;
			load_change_engine_in_blocked    <= 0;
			uc_in_blocked                    <= 0;
			load_uc_in_blocked               <= 0;
		end
		else begin
			`ifndef ONE_ENGINE
			engine_indicator                 <= next_engine_indicator;
			`endif
			clause_in_blocked                <= clause_in;
			ptr_in_blocked                   <= ptr_in;
			load_clause_in_blocked           <= load_clause_in; 
			load_ptr_in_blocked              <= load_ptr_in;
			load_change_engine_in_blocked    <= load_change_engine_in;
			uc_in_blocked                    <= uc_in;
			load_uc_in_blocked               <= load_uc_in;
		end
	end

endmodule