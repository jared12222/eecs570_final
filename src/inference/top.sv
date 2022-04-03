module top(
    input clk,
    input rst_n,

    // SW
    // input cla_t carb2sw_cla,
    // input carb2sw_valid,

    // CA I/O
    input        mem2carb_start,
    input        mem2carb_finish,
    input  cla_t mem2carb_clause,
    input        mem2carb_uc_valid,
    input  lit_t mem2carb_uc,
    output logic carb_empty,

    // UCA I/O
    output logic conflict
);

// UCQ_in
logic [`NUM_ENGINE-1:0] ucarb2UCQ_in_pop;
lit_t [`NUM_ENGINE-1:0] UCQ_in2uarb_uc;
logic [`NUM_ENGINE-1:0] UCQ_in_empty;

// UCQ_out
lit_t                   ucarb2UCQ_out_uc;
logic                   ucarb2UCQ_out_push;
logic [`NUM_ENGINE-1:0] UCQ_out_full;

// SW
cla_t [`NUM_ENGINE-1:0] carb2sw_cla;
logic [`NUM_ENGINE-1:0] carb2sw_valid;

// Clause Arbiter
lit_t carb2ucarb_uc;
logic carb2ucarb_uc_valid;

// Fixed mismatches
Distribution_unit dist_unit(
	.clock(clk),
	.reset(rst_n),
    
	.full_in({`NUM_ENGINE{1'b0}}),
	.load_sig_in(mem2carb_start),
	.start_in(mem2carb_finish),
	.clause_in(mem2carb_clause),
	.chosen_uc_in(mem2carb_uc),
	.chosen_uc_valid_in(mem2carb_uc_valid),

	.clause_out(carb2sw_cla),
	.grant_out(carb2sw_valid),
	.empty_out(carb_empty),
	.chosen_uc_out(carb2ucarb_uc),
	.chosen_uc_valid_out(carb2ucarb_uc_valid)
);

genvar i;
generate
    for (i=0; i<`NUM_ENGINE; i++) begin : eng_array
        proc eng (
            .clk(clk),
            .rst_n(rst_n),

            //UCQ_in <-> UC arbiter
            .ucarb2UCQ_in_pop(ucarb2UCQ_in_pop[i]),
            .UCQ_in2uarb_uc(UCQ_in2uarb_uc[i]),
            .UCQ_in_empty(UCQ_in_empty[i]),

            //UCQ_out <-> UC arbiter
            .ucarb2UCQ_out_uc(ucarb2UCQ_out_uc),
            .ucarb2UCQ_out_push(ucarb2UCQ_out_push),
            .UCQ_out_full(UCQ_out_full[i]),

            // sw
            .carb2sw_cla(carb2sw_cla[i]),
            .carb2sw_valid(carb2sw_valid[i])
        );
    end
endgenerate

uc_arbiter_wrapper ucarb(
    .clk(clk),
    .rst(rst_n),
    .mem2uca_valid(carb2ucarb_uc_valid),
    .mem2uca_done(carb2ucarb_uc_valid),
    .mem2uca(carb2ucarb_uc),
    .eng2uca_min(UCQ_in2uarb_uc),
    .eng2uca_valid(~UCQ_in_empty),
    .eng2uca_empty(UCQ_in_empty),
    .eng2uca_full(UCQ_out_full),
    .input_mode(1'b1),
    .uca2eng(ucarb2UCQ_out_uc),
    .uca2eng_push(ucarb2UCQ_out_push),
    .uca2eng_pop(ucarb2UCQ_in_pop),
    .conflict(conflict)
);

endmodule