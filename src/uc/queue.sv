`define UCQ_SIZE 4
`define UC_LENGTH 1024
`define DEBUG

// uca: Unit Clause Arbiter
// ucq: Unit Clause Queue
// eng: Process Engine

module queue #(
    parameter DATA_LEN = 512,
    parameter QUEUE_SIZE = 4
)(
    input  logic clk,
    input  logic rst,
    input  logic push,
    input  logic pop,
    input  logic signed [$clog2(DATA_LEN):0] data,
    output logic empty,
    output logic full,
    output logic signed [$clog2(DATA_LEN):0] head
    `ifdef DEBUG
    ,output logic signed [QUEUE_SIZE-1:0][$clog2(`UC_LENGTH):0] entry_r
    ,output logic signed [QUEUE_SIZE-1:0][$clog2(`UC_LENGTH):0] entry_w
    ,output logic [$clog2(QUEUE_SIZE):0] head_r
    ,output logic [$clog2(QUEUE_SIZE):0] head_w
    ,output logic [$clog2(QUEUE_SIZE):0] tail_r
    ,output logic [$clog2(QUEUE_SIZE):0] tail_w
    `endif
);

`ifndef DEBUG
logic [QUEUE_SIZE-1:0][$clog2(`UC_LENGTH)-1:0] entry_r;
logic [QUEUE_SIZE-1:0][$clog2(`UC_LENGTH)-1:0] entry_w;

logic [$clog2(QUEUE_SIZE):0] head_r;
logic [$clog2(QUEUE_SIZE):0] head_w;
logic [$clog2(QUEUE_SIZE):0] tail_r;
logic [$clog2(QUEUE_SIZE):0] tail_w;
`endif

assign head = head_r;

always_comb begin
    
    // Entry init
    for(int i=0; i<QUEUE_SIZE; i++) begin
        entry_w[i] = entry_r[i];
    end
    
    // Head and Tail init
    tail_w = tail_r;
    head_w = head_r;
    
    // Full and Empty Signals
    if(tail_r[$clog2(QUEUE_SIZE)] != head_r[$clog2(QUEUE_SIZE)]) begin
        if (tail_r[$clog2(QUEUE_SIZE)-1:0] == head_r[$clog2(QUEUE_SIZE)-1:0]) begin
            full = 'b1;
        end
        else begin
            full = 'b0;
        end
    end
    else begin
        full = 'b0;
    end
    empty = tail_r == head_r;

    // Init output
    head_w = head_r;

    // Process input stimuli
    case({push, pop})
        'b10: begin
            if (!full) begin
                entry_w[tail_r] = data;
                tail_w = tail_r+'b1;
            end
        end
        'b01: begin
            if (!empty) begin
                head_w = entry_r[head_r];
                head_w = head_r+'b1;
            end
        end
        'b11: begin
            // Pop
            head_w = entry_r[head_r];
            head_w = head_r+'b1;
            // Push
            entry_w[tail_r] = data;
            tail_w = tail_r+'b1;
        end
        default: begin

        end
    endcase
end

always_ff @(posedge clk) begin
    if (rst) begin
        for(int i=0; i<QUEUE_SIZE; i++) begin
            entry_r[i] <= 0;
        end
        head_r     <= 'b0;
        tail_r     <= 'b0;
        head_r  <= 'b0;
    end
    else begin
        for(int i=0; i<QUEUE_SIZE; i++) begin
            entry_r[i] <= entry_w[i];
        end
        head_r     <= head_w;
        tail_r     <= tail_w;
        head_r  <= head_w;
    end
end

endmodule