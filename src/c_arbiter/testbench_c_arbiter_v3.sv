`define CYCLE	10
`define	output_cnt 				4                      		//how many queues connected
`define clause_width 			3 							//how many variables can be contain in the clause representation 
`define element_cnt 			16 						//how many variables do the system support
`define element_bit_cnt 		($clog2(`element_cnt) + 1)	//5
`define	input_clause_cnt_bit	($clog2(`output_cnt) + 1)	//3 	

module  testbench_c_arbiter_v2 ();


	logic																clock;
	logic																reset;
	logic	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_in;
	logic	[`input_clause_cnt_bit-1:0]									clause_cnt_in;
	logic	[`output_cnt - 1:0] 										full_in;

	logic 	[`output_cnt-1:0][`clause_width * `element_bit_cnt -1:0] 	clause_out;
	logic 	[`input_clause_cnt_bit-1:0] 								clause_accept_out;
	logic 	[`output_cnt-1:0] 											grant_out;


	C_arbiter_v3 c_arbiter_v3(
	.clock(clock),
	.reset(reset),
	.clause_in(clause_in),
	.clause_cnt_in(clause_cnt_in),
	.full_in(full_in),

	.clause_out(clause_out),
	.clause_accept_out(clause_accept_out),
	.grant_out(grant_out)
);


	task show_result();
		#1
		$display("clause_out:%b", clause_out);
		$display("grant_out:%b", grant_out);
		$display("clause_accept_out:%d", clause_accept_out);
	endtask 
	
	always begin
		# `CYCLE
		clock = ~clock;
	end

	initial begin
		$dumpvars;
		clock 	=0;
		reset 	=1;
		#`CYCLE
		@(negedge clock);
		reset = 0;
		@(negedge clock);
		$display("cycle 1");
		clause_in 		= 60'b000000000000011_000000000000010_000000000000001_000000000000000;
		clause_cnt_in 	= 4;
		full_in 		= 4'b1001;
		show_result();
		@(negedge clock);
		$display("cycle 2");
		clause_in 		= 60'b000000000000111_000000000000110_000000000000101_000000000000100;
		clause_cnt_in 	= 4;
		full_in 		= 4'b0000;
		show_result();
		@(negedge clock);
		$display("cycle 3");
		clause_in 		= 60'b000000000000000_000000000000000_000000000001001_000000000001000;
		clause_cnt_in 	= 2;
		show_result();
		@(negedge clock);
		$display("cycle 4");
		clause_in 		= 60'b000000000000000_000000000000000_000000000001011_000000000001010;
		clause_cnt_in 	= 2;
		show_result();
		@(negedge clock);
		$display("cycle 5");
		clause_in 		= 60'b000000000000000_000000000000000_000000000000000_000000000001100;
		clause_cnt_in 	= 1;
		show_result();
		@(negedge clock);
		$display("cycle 6");
		clause_in 		= 60'b000000000000000_000000000000000_000000000000000_000000000001101;
		clause_cnt_in 	= 1;
		full_in 		= 4'b0010;
		show_result();
		@(negedge clock);
		$display("cycle 7");
		clause_in 		= 60'b000000000000000_000000000000000_000000000000000_000000000001110;
		clause_cnt_in 	= 1;
		full_in 		= 4'b0010;
		show_result();
		@(negedge clock);
		$display("cycle 8");
		clause_in 		= 60'b000000000000000_000000000000000_000000000000000_000000000001111;
		clause_cnt_in 	= 1;
		full_in 		= 4'b0010;
		show_result();
		@(negedge clock);
		$display("cycle 9");
		clause_in 		= 60'b000000000010011_000000000010010_0000000000100001_000000000010000;
		clause_cnt_in 	= 4;
		full_in 		= 4'b0111;
		show_result();
		#10
		$finish;
	end


endmodule