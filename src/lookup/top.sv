module top(
    input logic clk,
    input logic rst_n,

    input logic halt,

    input  node_t      node_in,
    input  logic       node_in_valid,
    input  ptr_t       dummy_ptr,
    input  logic       dummy_ptr_valid,
    input  logic       change_eng,

    input  lit_t       mem2uca,
    input  logic       mem2uca_done,
    input  logic       mem2uca_valid,

    // UCA I/O
    output logic conflict,
    input  logic mstack_pop,
    output logic mstack_empty,
    output lit_t mstack_lit
);

// UCQ_in
logic [`NUM_ENGINE-1:0] ucarb2UCQ_in_pop;
lit_t [`NUM_ENGINE-1:0] UCQ_in2uarb_uc;
logic [`NUM_ENGINE-1:0] UCQ_in_empty;

// UCQ_out
lit_t                   ucarb2UCQ_out_uc;
logic                   ucarb2UCQ_out_push;
logic [`NUM_ENGINE-1:0] UCQ_out_full;

// Clause Arbiter
lit_t carb2ucarb_uc;
logic carb2ucarb_uc_valid;

// Proc
logic                     proc_halt;
logic   [`NUM_ENGINE-1:0] proc_conflict;
node_t  [`NUM_ENGINE-1:0] proc_node_in;
logic   [`NUM_ENGINE-1:0] proc_node_in_valid;
dummy_ptr_t               proc_dummy_ptrs;
logic   [`NUM_ENGINE-1:0] proc_dummy_ptr_valid;
logic                     ucarb_conflict;
assign conflict  = |proc_conflict | ucarb_conflict;
assign proc_halt = halt;

genvar i;
generate
    for (i=0; i<`NUM_ENGINE; i++) begin : eng_array
        proc eng (
            .clk(clk),
            .rst_n(rst_n),
            .proc_halt(proc_halt),
            
            // Carb <-> CLQ
            .carb2clq_node_in(proc_node_in[i]),
            .carb2clq_push(proc_node_in_valid[i]),
            .carb2bcp_dummies(proc_dummy_ptrs),
            .carb2bcp_dummies_valid(proc_dummy_ptr_valid[i]),

            // Mstack <-> UCQ_out
            .ucarb2UCQ_out_push(ucarb2UCQ_out_push),
            .ucarb2UCQ_out_uc(ucarb2UCQ_out_uc),
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
    .rst_n(rst_n),
    
    // Ucarb <-> mstack
    .uca2mstack_push(ucarb2UCQ_out_push),
    .uca2mstack_lit(ucarb2UCQ_out_uc),
    .mstack2uca_empty(mstack2uca_empty),
    .mstack2uca_full(mstack2uca_full),

    // UCQ_out <-> mstack
    // .ucq2mstack_full(UCQ_out_full),
    .mstack_pop(mstack_pop),
    .mstack2ucq_lit(mstack_lit)
);


uc_arbiter_wrapper ucarb(
    .clk(clk),
    .rst(rst_n),
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .eng2uca_min(UCQ_in2uarb_uc),
    .eng2uca_valid(~UCQ_in_empty),
    .eng2uca_empty(UCQ_in_empty),
    .eng2uca_full({UCQ_out_full, mstack2uca_full}),
    .input_mode(1'b1),
    .uca2eng_lit(ucarb2UCQ_out_uc),
    .uca2eng_push(ucarb2UCQ_out_push),
    .uca2eng_pop(ucarb2UCQ_in_pop),
    .conflict(ucarb_conflict)
);

L_buffer_singleload lbuf(
    .clock(clk),
	.reset(rst_n),
	.clause_in(node_in),
	.ptr_in(dummy_ptr),
	.load_clause_in(node_in_valid),
    .load_ptr_in(dummy_ptr_valid), 
	
    `ifndef ONE_ENGINE
	.load_change_engine_in(change_eng),	//signal to load another engine
	`endif

	.clause_out(proc_node_in),
	.clause_valid_out(proc_node_in_valid),
	.ptr_out(proc_dummy_ptrs), 
	.ptr_valid_out(proc_dummy_ptr_valid)
);

endmodule