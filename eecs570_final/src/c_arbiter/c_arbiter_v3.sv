`define	output_cnt 				4                      		//how many queues connected
`define clause_width 			3 							//how many variables can be contain in the clause representation 
`define element_cnt 			16 						//how many variables do the system support
`define element_bit_cnt 		($clog2(`element_cnt) + 1)	//5
`define	input_clause_cnt_bit	($clog2(`output_cnt) + 1)	//3 		


module C_arbiter_v3(
	input 																clock,
	input 																reset,
	input	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_in,
	input	[`input_clause_cnt_bit-1:0]									clause_cnt_in,
	input	[`output_cnt - 1:0] 										full_in,

	output 	logic 	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_out,
	output 	logic 	[`input_clause_cnt_bit-1:0] 								clause_accept_out,
	output 	logic 	[`output_cnt-1:0] 											grant_out
);

	logic 	[`input_clause_cnt_bit-1:0]	clause_cnt;
	logic	[$clog2(`output_cnt)-1:0]	distribute_engine_idx, distribute_engine_idx_record;
 
	always_comb begin
		clause_cnt 				= clause_cnt_in;
		clause_accept_out 		= 0;
		distribute_engine_idx 	= distribute_engine_idx_record;
		for (int i = 0; i < `output_cnt; i++) begin
			clause_out[i] = 0;
			grant_out[i]  = 0;
		end

		for (int i = 0; i < `output_cnt; i++) begin
			if (!clause_cnt) begin
				break;
			end
			else if (!full_in[distribute_engine_idx]) begin
				grant_out[distribute_engine_idx] 			= 1;
				clause_out[distribute_engine_idx] 			= clause_in[clause_accept_out];
				clause_accept_out 							= clause_accept_out + 1;
				clause_cnt 									= clause_cnt - 1;
			end
			distribute_engine_idx 						= distribute_engine_idx + 1;

		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			distribute_engine_idx_record 	<= 0;
		end
		else begin
			distribute_engine_idx_record 	<= distribute_engine_idx;
		end
	end
endmodule