`define CYCLE	10
`define LIT_IDX_MAX 4
`define CLA_LENGTH 3
`define NUM_ENGINE 2
`define CLQ_DEPTH 64

typedef logic signed [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef logic [$clog2(`CLQ_DEPTH)-1:0] ptr_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;
typedef ptr_t [2*`LIT_IDX_MAX-1:0] dummy_ptr_t;

typedef struct packed {
    cla_t cla;
    ptr_t [`CLA_LENGTH-1:0] ptr;
} node_t;

module testbench_L_buffer_singleload ();

	logic                           clock;
	logic                           reset;
	node_t                          clause_in;
	ptr_t                           ptr_in;
	logic                           load_clause_in, load_ptr_in; 
	`ifndef ONE_ENGINE
	logic                           load_change_engine_in;	//signal to load another engine
	`endif
	// uc from software decision(?

	node_t   				        clause_out;
	logic[`NUM_ENGINE-1:0] 			clause_valid_out;
	dummy_ptr_t                     ptr_out; 
	logic[`NUM_ENGINE-1:0] 			ptr_valid_out;

	L_buffer_singleload l_buffer_singleload(
	.clock(clock),
	.reset(reset),
	//load preprocess data
	.clause_in(clause_in),
	.ptr_in(ptr_in),
	.load_clause_in(load_clause_in), 
	.load_ptr_in(load_ptr_in), 
	`ifndef ONE_ENGINE
	.load_change_engine_in(load_change_engine_in),	//signal to load another engine
	`endif
	.clause_out(clause_out),
	.clause_valid_out(clause_valid_out),
	.ptr_out(ptr_out), 
	.ptr_valid_out(ptr_valid_out)
	);


	task initialize();
		clause_in 				= 0;
		ptr_in 					= 0;
		load_clause_in 			= 0; 
		load_ptr_in 			= 0;
		load_change_engine_in 	= 0;
	endtask


	task display_preprocess_outputs(input integer i, j);
		#1
		$display("input_count: %d", i*5 + j);
		$display("clause_out[2]: %d, clause_out[1]: %d, clause_out[0]: %d", clause_out.cla[2], clause_out.cla[1], clause_out.cla[0]);
		$display("clause_ptr_out[2]: %d, clause_ptr_out[1]: %d, clause_ptr_out[0]: %d", clause_out.ptr[2], clause_out.ptr[1], clause_out.ptr[0]);
		$display("ptr_out : %d", ptr_out);
		$display("clause_valid_out: %b", clause_valid_out);
		$display("ptr_valid_out:    %b", ptr_valid_out);
	endtask

	always begin
		# (`CYCLE/2)
		clock = ~clock;
	end

	initial begin
		$dumpvars;
		clock 	=0;
		reset 	=1;
		initialize();
		#`CYCLE
		@(negedge clock);
		reset = 0;
		@(negedge clock);
		$display("start loading preprocess inputs");
		for (int i = 0; i < `NUM_ENGINE; i++) begin
			for (int j = 0; j < 3; j++) begin
				load_clause_in = 1;
				for (int k = 0; k < `CLA_LENGTH; k++) begin
					clause_in.cla[k] = i*9+ j*3 +k;
					clause_in.ptr[k] = i*9+ j*3 +k;
				end
				@(negedge clock);
				load_change_engine_in = 0; 
			end
			load_change_engine_in = 1; 
		end
		initialize();
		$display("ptrs_in");
		@(negedge clock);
		for (int i = 0; i < `NUM_ENGINE; i++) begin
			for (int j = 0; j < 2*`LIT_IDX_MAX; j++) begin
				load_ptr_in = 1;
				ptr_in = i*8 + j+1;
				@(negedge clock);
			end
		end
		initialize();
		#50
		$display("zzzzzzzzzz");
		#100
		$finish;
	end
endmodule