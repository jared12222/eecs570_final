`define LIT_IDX_MAX 1024
`define CLA_LENGTH 3
`define NUM_ENGINE 4

`define VARIABLE_LENGTH	 		($clog2(`LIT_IDX_MAX) + 1)	//11	


module C_arbiter_v4(
	input 																clock,
	input 																reset,
	input	[`NUM_ENGINE-1:0][`CLA_LENGTH * `VARIABLE_LENGTH -1:0] 		clause_distributed,
	input	[$clog2(`NUM_ENGINE):0]										clause_cnt_in,
	input	[`NUM_ENGINE - 1:0] 										full_in, start_in,

	output 	logic 	[`NUM_ENGINE-1:0][`CLA_LENGTH * `VARIABLE_LENGTH -1:0] 		clause_out,
	output 	logic 	[$clog2(`NUM_ENGINE):0] 									clause_accept_out,
	output 	logic 	[`NUM_ENGINE-1:0] 											grant_out
);

	logic 	[$clog2(`NUM_ENGINE):0]	clause_cnt;
	logic	[$clog2(`NUM_ENGINE)-1:0]	distribute_engine_idx, distribute_engine_idx_record;

	logic 	[`NUM_ENGINE - 1:0] 										full_in_blocked;
 
	always_comb begin
		clause_cnt 				= clause_cnt_in;
		clause_accept_out 		= 0;
		distribute_engine_idx 	= distribute_engine_idx_record;
		for (int i = 0; i < `NUM_ENGINE; i++) begin
			clause_out[i] = 0;
			grant_out[i]  = 0;
		end

		if (start_in) begin
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				if (!clause_cnt) begin
					break;
				end
				else if (!full_in_blocked [distribute_engine_idx]) begin
					grant_out[distribute_engine_idx] 			= 1;
					clause_out[distribute_engine_idx] 			= clause_distributed[clause_accept_out];
					clause_accept_out 							= clause_accept_out + 1;
					clause_cnt 									= clause_cnt - 1;
				end
				distribute_engine_idx 						= distribute_engine_idx + 1;
			end
		end

		
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			distribute_engine_idx_record 	<= 0;
			full_in_blocked 				<= 0;
		end
		else begin
			distribute_engine_idx_record 	<= distribute_engine_idx;
			full_in_blocked 				<= full_in;
		end
	end
endmodule