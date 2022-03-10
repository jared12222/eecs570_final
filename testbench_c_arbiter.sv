`define CYCLE	10
`define	output_cnt 			4
`define clause_width 		4
`define element_cnt 		1024
`define element_bit_cnt 	$clog2(element_cnt) + 1
module  testbench_c_arbiter ();

	logic												clock;
	logic												reset;
	logic	[`clause_width * `element_bit_cnt -1:0] 	clause_in;
	logic	[`clause_width - 1:0] 						full_in;

	logic	[`output_cnt - 1:0] 						grant_out;
	logic 	[`clause_width * `element_bit_cnt -1:0] 	clause_out;


	C_arbiter c_arbiter(
		.clock(clock),
		.reset(reset),
		.clause_in(clause_in),
		.full_in(full_in),
	
		.grant_out(grant_out),
		.clause_out(clause_out)
	);

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
		clause_in 	= 44'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
		full_in 	= 4'b1111;
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 2");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 3");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 4");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 5");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 6");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 7");
		full_in = 4'b1001;
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 8");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 9");
		$display("grant: %b", grant_out);
		@(negedge clock);
		$display("cycle 10");
		$display("grant: %b", grant_out);
		#10
		$finish;



	end

endmodule
