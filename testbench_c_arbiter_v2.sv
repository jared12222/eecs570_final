`define CYCLE	10
`define	output_cnt 				4                      		//how many queues connected
`define clause_width 			2 							//how many variables can be contain in the clause representation 
`define element_cnt 			4 						//how many variables do the system support
`define element_bit_cnt 		($clog2(`element_cnt) + 1)
`define	buffer_pointer_bit_cnt	($clog2(`output_cnt) + 1)

module  testbench_c_arbiter_v2 ();


	logic 																clock;
	logic 																reset;
	logic	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_in;
	logic	[`output_cnt - 1:0] 										full_in;

	logic 	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_out;
	logic 	[$clog2(`output_cnt):0] 									clause_accept_out;



	C_arbiter_v2 c_arbiter_v2(
		.clock(clock),
		.reset(reset),
		.clause_in(clause_in),
		.full_in(full_in),
	
		.clause_out(clause_out),
		.clause_accept_out(clause_accept_out)
	);

	always begin
		# `CYCLE
		clock = ~clock;
	end

	initial begin
		$dumpvars;
		clock 	=0;
		reset 	=1;
		clause_in 	= 24'b000011_000010_000001_000000;
		full_in 	= 4'b 1001;
		#`CYCLE
		@(negedge clock);
		reset = 0;
		@(negedge clock);
		$display("cycle 1");
		clause_in 	= 24'b000011_000010_000001_000000;
		full_in 	= 4'b 1001;
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 2");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 3");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 4");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 5");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 6");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 7");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 8");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 9");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);
		@(negedge clock);
		$display("cycle 10");
		$display("clause_out:%b", clause_out);
		$display("clause_accept_out:%d", clause_accept_out);

		#10
		$finish;
	end


endmodule
