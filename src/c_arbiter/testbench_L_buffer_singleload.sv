`define CYCLE	10
`define LIT_IDX_MAX 1024
`define NUM_CLAUSE	8
`define CLA_LENGTH 3
`define NUM_ENGINE 4
`define CLQ_DEPTH 64

//typedef logic signed [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef logic [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;
typedef logic [$clog2(`CLQ_DEPTH)-1:0] ptr_t;



module testbench_L_buffer_singleload ();

	logic                                 clock;
	logic                              	  reset;
	cla_t                         		  clause_in;
	ptr_t                           	  ptr_in;
	logic                                 load_clause_in, load_ptr_in, load_change_engine_in;
	lit_t                                 uc_in;
	logic                                 load_uc_in;

	cla_t   				              clause_out;
	logic[`NUM_ENGINE-1:0] 				  clause_valid_out;
	ptr_t	                         	  ptr_out;
	logic								  ptr_valid_out, uc_valid_out; 	

	L_buffer_singleload l_buffer_singleload(
	.clock(clock),
	.reset(reset),
	.clause_in(clause_in),
	.ptr_in(ptr_in),
	.load_clause_in(load_clause_in), 
	.load_ptr_in(load_ptr_in), 
	.load_change_engine_in(load_change_engine_in),
	.uc_in(uc_in),
	.load_uc_in(load_uc_in),
	.clause_out(clause_out),
	.clause_valid_out(clause_valid_out),
	.ptr_out(ptr_out), 
	.ptr_valid_out(ptr_valid_out), 
	.uc_valid_out(uc_valid_out) 		
	);

	cla_t[59:0] clause_inputs;
	ptr_t[59:0] pointer_inputs;
	lit_t[4:0] uc_inputs;

	integer file_clause, file_pointer, file_uc;

	//initial $readmemb("clause.txt", clause_inputs);
	//initial $readmemb("pointer.txt", pointer_inputs);
	//initial $readmemb("uc.txt", uc_inputs);


	task initialize();
		clause_in 				= 0;
		ptr_in 					= 0;
		load_clause_in 			= 0; 
		load_ptr_in 			= 0;
		load_change_engine_in 	= 0;
		uc_in 					= 0;
		load_uc_in 				= 0;
	endtask

	task display_uc_outputs(input integer i);
		#1
		$display("input_count:  %d", i);
		$display("uc_out:       %d", clause_out[0]);
		$display("uc_valid_out: %b", uc_valid_out);
	endtask

	task display_preprocess_outputs(input integer i, j);
		#1
		$display("input_count: %d", i*5 + j);
		$display("clause_out[2]: %d, clause_out[1]: %d, clause_out[0]: %d", clause_out[2], clause_out[1], clause_out[0]);
		$display("ptr_out : %d", ptr_out);
		$display("clause_valid_out: %b", clause_valid_out);
		$display("ptr_valid_out:    %b", ptr_valid_out);
	endtask

	task load_file();
		file_clause = $fopen("clause.txt","r");
		file_pointer = $fopen("pointer.txt","r");
		file_uc = $fopen("uc.txt","r");
		for (int i = 0; i < 60; i++) begin
			$fscanf(file_clause, "%d", clause_inputs[i]);
			$fscanf(file_pointer, "%d", pointer_inputs[i]);
			if (i<5) begin
				$fscanf(file_uc, "%d", uc_inputs[i]);
			end
		end
		$fclose(file_clause);
		$fclose(file_pointer);
		$fclose(file_uc);
	endtask

	always begin
		# (`CYCLE/2)
		clock = ~clock;
	end

	initial begin
		$dumpvars;
		load_file();
		clock 	=0;
		reset 	=1;
		initialize();
		#`CYCLE
		@(negedge clock);
		reset = 0;
		@(negedge clock);
		$display("start loading preprocess inputs");
		for (int i = 0; i < 4; i++) begin
			for (int j = 0; j < 5; j++) begin
				load_clause_in = 1;
				load_ptr_in    = 1;
				ptr_in    = pointer_inputs[i*5 + j];
				for (int k = 0; k < 3; k++) begin
					clause_in[k] = clause_inputs[i*15 + j*3 + k];
				end
				display_preprocess_outputs(i, j);
				@(negedge clock);
				load_change_engine_in = 0;
			end
			load_change_engine_in = 1;
		end
		initialize();
		#50
		$display("passing UCs zzzzzzzzzz");
		for (int i = 0; i < 5; i++) begin
			load_uc_in = 1;
			uc_in      = uc_inputs[i];
			display_uc_outputs(i);
			@(negedge clock);
			load_uc_in = 0;
		end
		#100
		$finish;
	end
endmodule