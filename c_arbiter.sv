//description: input a clause and output a clause every cycle; take full signal from queues as signal for arbitration

`define	output_cnt 			4                      		//how many queues connected
`define clause_width 		4 							//how many variables can be contain in the clause representation 
`define element_cnt 		1024 						//how many variables do the system support
`define element_bit_cnt 	($clog2(`element_cnt) + 1)


module C_arbiter(
	input 												clock,
	input 												reset,
	input	[`clause_width * `element_bit_cnt -1:0] 	clause_in,
	input	[`output_cnt - 1:0] 						full_in,

	output 	logic	[`output_cnt - 1:0] 						grant_out,
	output 	logic 	[`clause_width * `element_bit_cnt -1:0] 	clause_out
);

	logic	[`clause_width - 1:0] 							request;
	//logic 	[`clause_width - 1:0][`element_bit_cnt -1:0] 	distributed_clause;
	logic 	[`clause_width - 1:0] 							base, next_base;
	//logic	[`output_cnt - 1:0] 							grant_record;
	logic	[2 * `output_cnt - 1:0]							double_request;
	logic	[2 * `output_cnt - 1:0]							double_grant;



	always_comb	begin
		request 		= ~full_in;
		double_request 	= {request, request};
		double_grant 	= double_request & ~(double_request - base);
		grant_out 		= double_grant[`output_cnt - 1:0] |  double_grant[2 * `output_cnt - 1:`output_cnt];
		clause_out 		= clause_in;
		next_base = base;			//deal with condition of no request
		if (|request) begin 
			next_base = {grant_out[`output_cnt - 2:0], grant_out[`output_cnt - 1]};		//round robin
		end

	end

	always_ff @(posedge clock) begin
		if (reset) begin
			base <= 1; 
		end
		else begin
			base <= next_base;		
		end
	end

endmodule
