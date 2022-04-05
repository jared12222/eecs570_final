`define LIT_IDX_MAX 1024
`define NUM_CLAUSE	8
`define CLA_LENGTH 3
`define NUM_ENGINE 1
`define CLQ_DEPTH 64

typedef logic signed [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;
typedef logic [$clog2(`CLQ_DEPTH)-1:0] ptr_t;

module L_buffer_multipleload (
	input                                                       clock,
	input                                                       reset,
	//load preprocess data
	input   cla_t    [`NUM_ENGINE-1:0]                          clause_in,
	input	ptr_t    [`NUM_ENGINE-1:0]	                        ptr_in,
	input                                                       load_clause_in, load_ptr_in,
	// uc from software decision(?
	input   lit_t                                               uc_in,
	input                                                       load_uc_in,

	output  cla_t    [`NUM_ENGINE-1:0]				            clause_out,
	output 	                 				                    clause_valid_out,
	output  ptr_t    [`NUM_ENGINE-1:0]		                    ptr_out, 
	//output  lit_t                           uc_out,
	output 	                    				                ptr_valid_out,
	output                                                      uc_valid_out 		
);

	cla_t   [`NUM_ENGINE-1:0]                                   clause_in_blocked;
	ptr_t   [`NUM_ENGINE-1:0]                                   ptr_in_blocked;
	logic                                                       load_clause_in_blocked, load_ptr_in_blocked;
	lit_t               		                                uc_in_blocked;
	logic                                                       load_uc_in_blocked;

	always_comb begin
		for (int i = 0; i < `NUM_ENGINE; i++) begin
			clause_out[i]       = 0;
			ptr_out[i]          = 0;
		end
		clause_valid_out      = 0;
		ptr_valid_out         = 0;
		uc_valid_out          = 0;
		
		if (load_clause_in_blocked) begin
			clause_valid_out = 1;
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				clause_out[i] = clause_in_blocked[i];
			end
		end
		if (load_ptr_in_blocked) begin
			ptr_valid_out = 1;
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				ptr_out[i] = ptr_in_blocked[i];
			end
		end
		if (load_uc_in_blocked) begin
			uc_valid_out  = 1;
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				clause_out[i][0] = uc_in_blocked[i];
			end
		end
	end

	always_ff @(posedge clock)	begin
		if (reset)
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				clause_in_blocked[i]        <= 0;
				ptr_in_blocked[i]           <= 0;
			end
				uc_in_blocked               <= 0;
				load_clause_in_blocked      <= 0;
				load_ptr_in_blocked         <= 0;
				load_uc_in_blocked          <= 0;
		else
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				clause_in_blocked[i]        <= clause_in[i];
				ptr_in_blocked[i]           <= ptr_in[i];
			end
				uc_in_blocked               <= uc_in;
				load_clause_in_blocked      <= load_clause_in;
				load_ptr_in_blocked         <= load_ptr_in;
				load_uc_in_blocked          <= load_uc_in;
	end

endmodule