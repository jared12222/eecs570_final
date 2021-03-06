// uca: Unit Clause Arbiter
// ucq: Unit Clause Queue
// eng: Process Engine

module uc_queue (
    input  logic clk,
    input  logic rst,
    input  logic push,
    input  logic pop,
    input  logic [$clog2(`LIT_IDX_MAX):0] uca2ucq,
    output logic empty,
    output logic full,
    output logic [$clog2(`LIT_IDX_MAX):0] ucq2eng

    `ifdef DEBUG
    ,output logic [`UCQ_SIZE-1:0][$clog2(`LIT_IDX_MAX):0] entry_r
    ,output logic [`UCQ_SIZE-1:0][$clog2(`LIT_IDX_MAX):0] entry_w
    ,output logic [$clog2(`UCQ_SIZE):0] head_r
    ,output logic [$clog2(`UCQ_SIZE):0] head_w
    ,output logic [$clog2(`UCQ_SIZE):0] tail_r
    ,output logic [$clog2(`UCQ_SIZE):0] tail_w
    ,output logic [$clog2(`LIT_IDX_MAX):0] qout_r
    ,output logic [$clog2(`LIT_IDX_MAX):0] qout_w    
    `endif
);

queue #(
    .DATA_LEN(`LIT_IDX_MAX*2),
    .QUEUE_SIZE(`UCQ_SIZE)
) queue (
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .data(uca2ucq),
    .empty(empty),
    .full(full),
    .qout(ucq2eng)

    `ifdef DEBUG
    ,.entry_r(entry_r)
    ,.entry_w(entry_w)
    ,.head_r(head_r)
    ,.head_w(head_w)
    ,.tail_r(tail_r)
    ,.tail_w(tail_w)
    ,.qout_r(qout_r)
    ,.qout_w(qout_w)
    `endif
);

endmodule