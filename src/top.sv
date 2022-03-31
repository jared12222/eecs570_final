module top(
    input clk,
    input rst_n,

    // SW
    input cla_t carb2sw_cla,
    input carb2sw_valid,

    // UCA I/O
    input  logic mem2uca_valid,
    input  logic mem2uca_done,
    input  logic signed [$clog2(`LIT_IDX_MAX):0] mem2uca,
    output logic conflict
);

// UCQ_in
logic ucarb2UCQ_in_pop;
lit_t UCQ_in2uarb_uc;
logic UCQ_in_empty;


// UCQ_out
lit_t ucarb2UCQ_out_uc;
logic ucarb2UCQ_out_push;
logic UCQ_out_full;


proc eng (
    .clk(clk),
    .rst_n(rst_n),
    
    //UCQ_in to UC arbiter
    .ucarb2UCQ_in_pop(ucarb2UCQ_in_pop),
    .UCQ_in2uarb_uc(UCQ_in2uarb_uc),
    .UCQ_in_empty(UCQ_in_empty),
    
    //UCQ_out <-> UC arbiter
    .ucarb2UCQ_out_uc(ucarb2UCQ_out_uc),
    .ucarb2UCQ_out_push(ucarb2UCQ_out_push),
    .UCQ_out_full(UCQ_out_full),
    
    // sw
    .carb2sw_cla(carb2sw_cla),
    .carb2sw_valid(carb2sw_valid)
);

uc_arbiter_wrapper ucarb(
    .clk(clk),
    .rst(rst_n),
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .eng2uca_min(UCQ_in2uarb_uc),
    .eng2uca_valid(!UCQ_in_empty),
    .eng2uca_empty(UCQ_in_empty),
    .eng2uca_full(UCQ_out_full),
    .input_mode(1'b1),
    .uca2eng(ucarb2UCQ_out_uc),
    .uca2eng_valid(ucarb2UCQ_out_push),
    .uca2eng_pop(ucarb2UCQ_in_pop),
    .conflict(conflict)
);


endmodule