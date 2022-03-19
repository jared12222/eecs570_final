//description: input a clause and output a clause every cycle; take full signal from queues as signal for arbitration

`define	output_cnt 				4                      		//how many queues connected
`define clause_width 			2 							//how many variables can be contain in the clause representation 
`define element_cnt 			4 						//how many variables do the system support
`define element_bit_cnt 		($clog2(`element_cnt) + 1)
`define	buffer_pointer_bit_cnt	($clog2(`output_cnt) + 1)


module C_arbiter_v2(
	input 																clock,
	input 																reset,
	input	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_in,
	input	[`output_cnt - 1:0] 										full_in,

	output 	logic 	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_out,
	output 	logic 	[$clog2(`output_cnt):0] 									clause_accept_out
);

	logic	[2*`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0]	buffer, next_buffer;
	logic 	[`buffer_pointer_bit_cnt:0] 								head, tail, next_head, next_tail; 


	always_comb begin
		clause_accept_out = 0;
		next_tail = tail;
		next_head = head;
		next_buffer = buffer;
		for (int i = 0; i < `output_cnt; i++) begin
			if (next_tail[`buffer_pointer_bit_cnt-1:0] == head[`buffer_pointer_bit_cnt-1:0] && next_tail[`buffer_pointer_bit_cnt] != head[`buffer_pointer_bit_cnt]) begin
				break;
			end
			next_buffer[next_tail[`buffer_pointer_bit_cnt-1:0]] = clause_in[i];
			next_tail = next_tail + 1;
			clause_accept_out = clause_accept_out + 1;
		end
		for (int i = 0; i < `output_cnt; i++) begin
			if (next_head[`buffer_pointer_bit_cnt-1:0] == tail[`buffer_pointer_bit_cnt-1:0] && next_head[`buffer_pointer_bit_cnt] == head[`buffer_pointer_bit_cnt]) begin
				break;
			end
			if (!full_in[i]) begin
				clause_out[i] = buffer[next_head[`buffer_pointer_bit_cnt-1:0]];
				next_head = next_head + 1;
			end
		end
	end

	always_ff @(posedge clock)	begin
		if (reset) begin
			head 		<= 0;
			tail 		<= 0;
			buffer 		<= 48'b0;
		end
		else begin
			head 		<= next_head;  
			tail 		<= next_tail; 
			buffer 		<= next_buffer; 
		end
	end

endmodule
