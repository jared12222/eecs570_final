module top(
    input logic clk,
    input logic rst_n,

    input logic halt,

    // CA I/O
    // input        mem2carb_start,
    // input        mem2carb_finish,
    // input  cla_t mem2carb_clause,
    // input        mem2carb_uc_valid,
    // input  lit_t mem2carb_uc,
    // output logic carb_empty,

    //
    input  node_t      carb2clq_node_in,
    input  logic       carb2clq_push,
    input  dummy_ptr_t carb2bcp_dummies,
    input  logic       carb2bcp_dummies_valid,

    // UCA I/O
    output logic conflict
);

// UCQ_in
logic [`NUM_ENGINE-1:0] ucarb2UCQ_in_pop;
lit_t [`NUM_ENGINE-1:0] UCQ_in2uarb_uc;
logic [`NUM_ENGINE-1:0] UCQ_in_empty;

// UCQ_out
lit_t                   mstack2ucq_lit;
logic                   ucarb2UCQ_out_push;
logic [`NUM_ENGINE-1:0] UCQ_out_full;

// Clause Arbiter
lit_t carb2ucarb_uc;
logic carb2ucarb_uc_valid;

// Model stack

// Proc
logic                   proc_halt;
logic [`NUM_ENGINE-1:0] proc_conflict;

assign conflict  = |proc_conflict;
assign proc_halt = halt;

// Fixed mismatches
// Distribution_unit dist_unit(
// 	.clock(clk),
// 	.reset(rst_n),
    
// 	.full_in({`NUM_ENGINE{1'b0}}),
// 	.load_sig_in(mem2carb_start),
// 	.start_in(mem2carb_finish),
// 	.clause_in(mem2carb_clause),
// 	.chosen_uc_in(mem2carb_uc),
// 	.chosen_uc_valid_in(mem2carb_uc_valid),

// 	.clause_out(carb2sw_cla),
// 	.grant_out(carb2sw_valid),
// 	.empty_out(carb_empty),
// 	.chosen_uc_out(carb2ucarb_uc),
// 	.chosen_uc_valid_out(carb2ucarb_uc_valid)
// );

genvar i;
generate
    for (i=0; i<`NUM_ENGINE; i++) begin : eng_array
        proc eng (
            .clk(clk),
            .rst_n(rst_n),
            .proc_halt(proc_halt),
            
            // Carb <-> CLQ
            .carb2clq_node_in(carb2clq_node_in),
            .carb2clq_push(carb2clq_push),
            .carb2bcp_dummies(carb2bcp_dummies),
            .carb2bcp_dummies_valid(carb2bcp_dummies_valid),

            // Mstack <-> UCQ_out
            .ucarb2UCQ_out_push(ucarb2UCQ_out_push),
            .ucarb2UCQ_out_uc(mstack2ucq_lit),
            .UCQ_out_full(UCQ_out_full[i]),

            // UCarb <-> UCQ_in
            .ucarb2UCQ_in_pop(ucarb2UCQ_in_pop[i]),
            .UCQ_in2uarb_uc(UCQ_in2uarb_uc[i]),
            .UCQ_in_empty(UCQ_in_empty[i]),
            
            .conflict(proc_conflict[i])
            
        );
    end
endgenerate

uc_arbiter_mstack mstack (
    .clk(clk),
    .rst(rst),
    
    // Ucarb <-> mstack
    .uca2mstack_push(uca2mstack_push),
    .uca2mstack_lit(uca2mstack_lit),
    .mstack2uca_empty(mstack2uca_empty),
    .mstack2uca_full(mstack2uca_full),

    // UCQ_out <-> mstack
    .ucq2mstack_full(UCQ_out_full),
    .mstack2ucq_lit(mstack2ucq_lit)
);


uc_arbiter_wrapper ucarb(
    .clk(clk),
    .rst(rst_n),
    .mem2uca_valid(carb2ucarb_uc_valid),
    .mem2uca_done(carb2ucarb_uc_valid),
    .mem2uca(carb2ucarb_uc),
    .eng2uca_min(UCQ_in2uarb_uc),
    .eng2uca_valid(~UCQ_in_empty),
    .eng2uca_empty(UCQ_in_empty),
    .eng2uca_full({UCQ_out_full, mstack2uca_full}),
    .input_mode(1'b1),
    .uca2eng_lit(ucarb2UCQ_out_uc),
    .uca2eng_push(ucarb2UCQ_out_push),
    .uca2eng_pop(ucarb2UCQ_in_pop),
    .conflict(conflict)
);

endmodule