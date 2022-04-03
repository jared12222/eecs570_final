`define VARIABLE_LENGTH	($clog2(`LIT_IDX_MAX) + 1)

module Distribution_unit(
	input 							   clock,
	input 							   reset,
	input 	[`NUM_ENGINE - 1:0] 	   full_in,	     //clause queue's full signal; act as !(request signal); pipeline register might need to be removed	
	input							   load_sig_in,  //set to 1 to load data into the buffer
	input							   start_in,	 //set to 1 to signal that test data loading is complete, start distributing the data
	input 	cla_t	                   clause_in,	 //clause input, from testbench or from UC_arbiter
	input   lit_t                      chosen_uc_in,
	input                              chosen_uc_valid_in,

	output 	cla_t 	[`NUM_ENGINE-1:0]  clause_out,		//data for class queues
	output 	logic 	[`NUM_ENGINE-1:0]  grant_out,		//signal that clause_out is valid
	output 	logic					   empty_out,		//the buffer is empty; well..., maybe we don't need this signal
	output  lit_t                      chosen_uc_out,
	output  logic                      chosen_uc_valid_out
	);

	cla_t [`NUM_ENGINE-1:0]       clause;
	logic [$clog2(`NUM_ENGINE):0] clause_distributed_cnt, clause_feedback_cnt;
	logic 						  start;


	C_arbiter_v4 c_arbiter_v4(
		.clock(clock),
		.reset(reset),
		.clause_distributed(clause),
		.clause_cnt_in(clause_distributed_cnt),
		.full_in(full_in),
		.start_in(start_in),
	
		.clause_out(clause_out),
		.clause_accept_out(clause_feedback_cnt),
		.grant_out(grant_out)
		);

	Latency_buffer latency_buffer(
		.clock(clock),
		.reset(reset),
		.load_sig_in(load_sig_in),
		.start_in(start_in),
		.clause_in(clause_in),
		.clause_received_in(clause_feedback_cnt),
		.chosen_uc_in(chosen_uc_in),
		.chosen_uc_valid_in(chosen_uc_valid_in),
	
		.clause_released_out(clause_distributed_cnt),
		.clause_out(clause),
		.chosen_uc_out(chosen_uc_out),
		.chosen_uc_valid_out(chosen_uc_valid_out),
		.empty_out(empty_out),
		.start_out(start)
	
		);






endmodule