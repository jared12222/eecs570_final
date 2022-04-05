module uc_arbiter_mstack (
    input  logic clk,
    input  logic rst,
    
    // Ucarb <-> mstack
    input  logic uca2mstack_push,
    input  lit_t uca2mstack_lit,
    output logic mstack2uca_empty,
    output logic mstack2uca_full,

    // UCQ_out <-> mstack
    input  logic [`NUM_ENGINE-1:0] ucq2mstack_full,
    output lit_t                   mstack2ucq_lit

);

/*
    This module collects decisions/implications from ucarb
    Different engines consume/pop from UCQ_out at various speeds
    Hence this module serves merely as a debugging convenience
*/

logic mstack_pop;
assign mstack_pop = |ucq2mstack_full ? 'b0 : 'b1;

queue #(
    .DATA_LEN(`LIT_IDX_MAX*2),
    .QUEUE_SIZE(`UCQ_SIZE)
) mstack(
    .clk(clk),
    .rst(rst_n),
    .push(uca2mstack_push),
    .pop(mstack_pop),
    .data(uca2mstack_lit),
    .empty(mstack2uca_empty),
    .full(mstack2uca_full),
    .qout(mstack2ucq_lit)
);

endmodule