`define UC_LENGTH 1024
`define NUM_ENGINE 4
`define MAX_UC 64

module uc_arbiter_wrapper (
    input  logic clk,
    input  logic rst,
    input  logic mem2uca_valid,
    input  logic mem2uca_done,
    input  logic signed [$clog2(`UC_LENGTH)-1:0] mem2uca,
    input  logic signed [`NUM_ENGINE-1:0][$clog2(`UC_LENGTH)-1:0] eng2uca_min,
    input  logic [`NUM_ENGINE-1:0]eng2uca_valid,
    input  logic [`NUM_ENGINE-1:0]eng2uca_empty,
    input  logic eng2uca_rd,
    output logic signed [$clog2(`UC_LENGTH)-1:0] uca2eng,
    output logic conflict
);

logic [`NUM_ENGINE-1:0] engmask;
logic [$clog2(`UC_LENGTH)-1:0] eng2uca_mout_d;
logic eng2uca_mout_valid;
logic eng2uca_mout_empty;

uc_arbiter uca(
    .clk(clk),
    .rst(rst),
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .eng2uca_valid(eng2uca_mout_valid),
    .eng2uca_empty(eng2uca_mout_empty),
    .eng2uca(eng2uca_mout_d),
    .eng2uca_rd(eng2uca_rd),
    .uca2eng(uca2eng),
    .engmask(engmask),
    .conflict(conflict)
);

always_comb begin
    eng2uca_mout_d     = eng2uca_min[$clog2(engmask)];
    eng2uca_mout_valid = eng2uca_valid[$clog2(engmask)];
    eng2uca_mout_empty = eng2uca_empty[$clog2(engmask)];
end

endmodule