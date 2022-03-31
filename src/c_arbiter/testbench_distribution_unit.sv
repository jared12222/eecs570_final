`define CYCLE	10

`define LIT_IDX_MAX 1024
`define CLA_LENGTH 3
`define NUM_ENGINE 4

`define UC_LENGTH	1024
`define VARIABLE_LENGTH	($clog2(`LIT_IDX_MAX) + 1)

module testbench_distribution_unit ();

	logic											clock;
	logic											reset;
	logic	[`NUM_ENGINE - 1:0] 					full_in;			 					
	logic											load_sig_in;
	logic											start_in;
	logic	[`VARIABLE_LENGTH * `CLA_LENGTH-1:0]	clause_in;
	logic 	[`NUM_ENGINE-1:0][`CLA_LENGTH * `VARIABLE_LENGTH -1:0] 		clause_out;
	logic 	[`NUM_ENGINE-1:0] 											grant_out;
	logic																empty_out;
	logic   [`VARIABLE_LENGTH-1:0]                                      chosen_uc_in;
	logic                                                               chosen_uc_valid_in;
	logic   [`VARIABLE_LENGTH-1:0]                                      chosen_uc_out;
	logic                                                               chosen_uc_valid_out;

	Distribution_unit distribution_unit(
		.clock(clock),
		.reset(reset),
		.full_in(full_in),			 					
		.load_sig_in(load_sig_in),
		.start_in(start_in),
		.clause_in(clause_in),
		.clause_out(clause_out),
		.grant_out(grant_out),
		.empty_out(empty_out),
		.chosen_uc_in(chosen_uc_in),
		.chosen_uc_valid_in(chosen_uc_valid_in),
		.chosen_uc_out(chosen_uc_out),
		.chosen_uc_valid_out(chosen_uc_valid_out)
	);


	task show_result();
		#1
		$display("clause_out: %d_%d_%d_%d", clause_out[3], clause_out[2], clause_out[1], clause_out[0]);
		$display("grant_out: %b", grant_out);
		$display("empty_out: %b", empty_out);
		$display("uc_out: %b", chosen_uc_out);
		$display("uc_valid_out: %b", chosen_uc_valid_out);
	endtask

	always begin
		# (`CYCLE/2)
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
		$display("load");
		load_sig_in = 1;
		full_in 	= 4'b0000;
		start_in 	= 0;
		chosen_uc_valid_in = 1;
		chosen_uc_in = 11'b101_1011_1011;
		for (int i = 0; i < 24; i++) begin
			clause_in = i;
			#(`CYCLE);
		end
		$display("load complete");
		@(negedge clock);
		load_sig_in = 0;
		start_in 	= 1;
		@(negedge clock);
		$display("start processing");
		$display("cycle 1");
		show_result();
		@(negedge clock);
		$display("cycle 2");
		show_result();
		@(negedge clock);
		$display("cycle 3");
		show_result();
		@(negedge clock);
		$display("cycle 4");
		full_in = 4'b0101;
		show_result();
		@(negedge clock);
		$display("cycle 5");
		show_result();
		@(negedge clock);
		$display("cycle 6");
		show_result();
		@(negedge clock);
		$display("cycle 7");
		show_result();
		@(negedge clock);
		$display("cycle 8");
		show_result();
		load_sig_in = 1;
		clause_in = 24;
		@(negedge clock);
		$display("cycle 9");
		show_result();
		load_sig_in = 0;
		@(negedge clock);
		$display("cycle 10");
		show_result();
		@(negedge clock);
		$display("cycle 11");
		show_result();
		@(negedge clock);
		$display("cycle 12");
		show_result();
		load_sig_in = 1;
		clause_in = 25;
		@(negedge clock);
		$display("cycle 13");
		show_result();
		clause_in = 26;
		@(negedge clock);
		$display("cycle 14");
		show_result();
		load_sig_in = 0;
		@(negedge clock);
		$display("cycle 15");
		show_result();

		#`CYCLE
		$finish;
	end
endmodule