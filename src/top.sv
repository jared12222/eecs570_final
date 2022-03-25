module top(
    input clk,
    input rst_n,
    
    //UCQ_in to UC arbiter
    input  ucarb2UCQ_in_pop,
    output lit_t UCQ_in2uarb_uc,
    output logic UCQ_in_empty,
    
    //UCQ_out <-> UC arbiter
    input lit_t ucarb2UCQ_out_uc,
    input ucarb2UCQ_out_push,
    output logic UCQ_out_full,

    // sw
    input cla_t carb2sw_cla,
    input carb2sw_valid

);

// BCP Engine

logic imply;
lit_t imply_idx;

cla_t pr_clause; // output pruned clause
logic done; // the clause is satisfied
logic conflict; // if all literal are assigned, set if the clause cannot satisfy

logic UCQ_out_pop;
logic CLQ_pop;
logic ENG_P_push;


// CLQ
logic CLQ_full;
logic CLQ_empty;
cla_t CLQ2BCP_cla;

// sw(switch)
logic eng2sw_valid;
logic sw2eng_stall;
cla_t sw2clq_cla;
logic sw2clq_valid;

// UCQ_in
logic UCQ_in_full;



lit_t UCQ_out2eng_uc;
cla_t CLQ2eng_cla;
cla_t eng2sw_cla;

bcp_pe bcp_pe (
    .clk(clk),    
    .rst_n(rst_n),
    .litDec(UCQ_out2eng_uc), 
    .clause(CLQ2eng_cla), 
    .ENG_P_FULL(sw2eng_stall),
    .UCQ_in_full(UCQ_in_full),
    .UCQ_out_empty(UCQ_out_empty),
    .CLQ_empty(CLQ_empty),
    
    .imply(eng2UCQ_in_valid),
    .imply_idx(imply_idx),
    
    .pr_clause(eng2sw_cla),
    .done(),
    .conflict(),
    
    .UCQ_out_pop(eng2UCQ_out_pop),
    .CLQ_pop(eng2CLQ_pop),
    .ENG_P_push(eng2sw_valid)
);

cla_queue #(
    .depth(`CLQ_DEPTH)
)
CLQ(
    .clk(clk),
    .rst_n(rst_n),
    .cla_in(sw2clq_cla),
    .push(sw2clq_valid),
    .pop(eng2CLQ_pop),
    .full(CLQ_full),
    .empty(CLQ_empty),
    .cla_out(CLQ2eng_cla)
);

sw sw(
    .carb2sw(carb2sw_cla),
    .carb2sw_valid(carb2sw_valid),
    .eng2sw(eng2sw_cla),
    .eng2sw_valid(eng2sw_valid),

    .sw2clq(sw2clq_cla),
    .sw2clq_valid(sw2clq_valid),
    .sw2eng_stall(sw2eng_stall)
);

queue #(
    .DATA_LEN(`LIT_IDX_MAX*2),
    .QUEUE_SIZE(`UCQ_SIZE)
)
UCQ_in(
    .clk(clk),
    .rst(rst_n),
    .push(eng2UCQ_in_valid),
    .pop(ucarb2UCQ_in_pop),
    .data(imply_idx),
    .empty(UCQ_in_empty),
    .full(UCQ_in_full),
    .qout(UCQ_in2uarb_uc)
);

queue #(
    .DATA_LEN(`LIT_IDX_MAX*2),
    .QUEUE_SIZE(`UCQ_SIZE)
)
UCQ_out(
    .clk(clk),
    .rst(rst_n),
    .push(ucarb2UCQ_out_push),
    .pop(eng2UCQ_out_pop),
    .data(ucarb2UCQ_out_uc),
    .empty(UCQ_out_empty),
    .full(UCQ_out_full),
    .qout(UCQ_out2eng_uc)
);

// uc_arbiter_wrapper uca (
//     clk,
//     rst,
//     mem2uca_valid,
//     mem2uca_done,
//     mem2uca,
//     eng2uca_min,
//     eng2uca_valid,
//     eng2uca_empty,
//     uca2eng_full,
//     uca2eng,
//     uca2eng_pop,
//     conflict
// );

endmodule