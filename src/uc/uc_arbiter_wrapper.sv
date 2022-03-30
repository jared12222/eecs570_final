module uc_arbiter_wrapper (
    input  logic clk,
    input  logic rst,
    input  logic mem2uca_valid,
    input  logic mem2uca_done,
    input  logic signed [$clog2(`LIT_IDX_MAX):0] mem2uca,
    input  logic signed [`NUM_ENGINE-1:0][$clog2(`LIT_IDX_MAX):0] eng2uca_min,
    input  logic [`NUM_ENGINE-1:0] eng2uca_valid,
    input  logic [`NUM_ENGINE-1:0] eng2uca_empty,
    input  logic [`NUM_ENGINE-1:0] eng2uca_full,
    input  logic input_mode,
    output logic signed [$clog2(`LIT_IDX_MAX):0] uca2eng,
    output logic uca2eng_pop,
    output logic conflict
);

/*
uca: Unit Clause arbiter
mem: Memory -- Sends a unit clause from the interconnect
input_mode: Mode of receiving implied unit clauses from engine
    (0) Mask mode -- Read every engine queue sequentially
    (1) PQ mode   -- Get input to write to buffer from wrapper PQ
*/

logic [`NUM_ENGINE-1:0] engmask;
logic [$clog2(`LIT_IDX_MAX):0] eng2uca_mout_d;
logic eng2uca_mout_valid;
logic eng2uca_mout_empty;

logic [$clog2(`NUM_ENGINE)-1:0] ref_count_w;
logic [$clog2(`NUM_ENGINE)-1:0] ref_count_r;
logic [$clog2(`NUM_ENGINE):0]   idx;

uc_arbiter uca(
    .clk(clk),
    .rst(rst),
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .eng2uca_valid(eng2uca_mout_valid),
    .eng2uca_empty(eng2uca_mout_empty),
    .eng2uca(eng2uca_mout_d),
    .eng2uca_full(eng2uca_full),
    .input_mode(input_mode),
    .uca2eng(uca2eng),
    .engmask(engmask),
    .conflict(conflict)
);

always_comb begin
    uca2eng_pop        = 'b0;
    eng2uca_mout_empty = eng2uca_empty[$clog2(engmask)];
    eng2uca_mout_valid = 'b0;
    eng2uca_mout_d     = 'b0;
    ref_count_w        = ref_count_r;
    idx                = 'b0;

    if (input_mode) begin
        // Round-robin priority selection
        for (int i=0; i<`NUM_ENGINE*2; i++) begin
            if (i >= ref_count_r) begin
                idx = i;
                if (eng2uca_valid[idx[$clog2(`NUM_ENGINE)-1:0]]) begin
                    
                    // Send data to uc arbiter
                    uca2eng_pop        = 'b1;
                    eng2uca_mout_d     = eng2uca_min  [idx[$clog2(`NUM_ENGINE)-1:0]];
                    eng2uca_mout_valid = eng2uca_valid[idx[$clog2(`NUM_ENGINE)-1:0]];
                    
                    // Reference counter increment logic
                    if (i == ref_count_r) begin
                        ref_count_w = ref_count_r + 'b1;
                    end
                    else begin
                        ref_count_w = idx[$clog2(`NUM_ENGINE)-1:0] + 'b1;
                    end
                    
                    break;
                end
            end
        end
    end
    else begin
        if(!eng2uca_mout_empty) begin
            uca2eng_pop        = 'b1;
            eng2uca_mout_d     = eng2uca_min[$clog2(engmask)];
            eng2uca_mout_valid = eng2uca_valid[$clog2(engmask)];
        end
        else begin
            eng2uca_mout_d = 'b0;
            eng2uca_mout_valid = 'b0;
        end
    end
end

always_ff @(posedge clk or negedge rst) begin
    if (rst) begin
        ref_count_r <= 'b0;
    end
    else begin
        ref_count_r <= ref_count_w;
    end
end

endmodule