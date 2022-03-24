`define LIT_IDX_MAX 1024
`define CLA_LENGTH 3
`define NUM_ENGINE 4

`define UC_LENGTH	1024
`define VARIABLE_LENGTH	($clog2(`LIT_IDX_MAX) + 1)

	module Latency_buffer (
		input 											clock,    // Clock
		input 											reset, // Clock Enable
		input											load_sig_in,
		input											start_in,
		input 	[`VARIABLE_LENGTH * `CLA_LENGTH-1:0]	clause_in,
		input 	[$clog2(`NUM_ENGINE):0]					clause_received_in,
	
		output 	logic	[$clog2(`NUM_ENGINE):0]									clause_released_out,		//count
		output 	logic	[`NUM_ENGINE-1:0][`VARIABLE_LENGTH * `CLA_LENGTH-1:0]	clause_out,
		output 	logic															empty_out, start_out
	
	);


	logic 	[`UC_LENGTH+`NUM_ENGINE-1:0][`VARIABLE_LENGTH * `CLA_LENGTH-1:0]	buffer, next_buffer;
	logic	[$clog2(`UC_LENGTH)+1:0] 											head, tail, next_head, next_tail, head_tmpt;

	logic											load_sig_in_blocked, start_in_blocked;
	logic	[`VARIABLE_LENGTH * `CLA_LENGTH-1:0]	clause_in_blocked;

	always_comb begin
		start_out = start_in_blocked;
		next_head = head;
		head_tmpt = head;
		next_tail = tail;
		next_buffer = buffer;
		empty_out = 0;
		clause_released_out = 0;
		for (int i = 0; i < `NUM_ENGINE; i++) begin
			clause_out[i] = 0;
		end

		if (load_sig_in_blocked) begin
			next_buffer[tail] = clause_in_blocked;
			next_tail = tail + 1;
		end

		if (start_in_blocked) begin
			if (head[$clog2(`UC_LENGTH)+1] == tail[$clog2(`UC_LENGTH)+1] && head[$clog2(`UC_LENGTH):0] == tail[$clog2(`UC_LENGTH):0]) begin
				empty_out = 1;
			end
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				if (head_tmpt[$clog2(`UC_LENGTH)+1] == tail[$clog2(`UC_LENGTH)+1] && head_tmpt[$clog2(`UC_LENGTH):0] == tail[$clog2(`UC_LENGTH):0]) begin
					break;
				end
				clause_released_out = clause_released_out + 1;
				clause_out[i] = buffer[head_tmpt];
				head_tmpt = head_tmpt + 1; 
			end
			next_head = head + clause_received_in;
		end
		
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `NUM_ENGINE; i++) begin
				buffer[i] 	= 0;
			end
			head							<= 0;
			tail							<= `NUM_ENGINE;

			load_sig_in_blocked	 			<= 0;
			start_in_blocked				<= 0;
			clause_in_blocked 				<= 0;
		end
		else begin
			buffer 	<= next_buffer;
			head 	<= next_head;
			tail 	<= next_tail;

			load_sig_in_blocked	 			<= load_sig_in;
			start_in_blocked				<= start_in;
			clause_in_blocked 				<= clause_in;
		end
	end
endmodule