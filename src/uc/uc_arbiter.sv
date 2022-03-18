`define UC_LENGTH 1024
`define UCA_SIZE 8
`define NUM_ENGINE 4
`define MAX_UC 64

module uc_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic mem2uca_valid,
    input  logic mem2uca_done,
    input  logic [$clog2(UC_LENGTH)-1:0] mem2uca,
    input  logic eng2uca_valid,
    input  logic eng2uca_empty,
    input  logic [$clog2(UC_LENGTH)-1:0] eng2uca,
    output logic [$clog2(UC_LENGTH)-1:0] uca2ucq,
    output logic [NUM_ENGINE-1:0]        engmask,
    output logic                         conflict
);

uc_queue uc_queue (
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .uca2ucq(data),
    .empty(empty),
    .full(full),
    .ucq2eng(uca2ucq)
);

// TODO
// Add a MUX outside of this module to select input
// Signal outside world that inner buffer is full

logic [$clog2(UCA_SIZE)-1:0][$clog2(UC_LENGTH):0] buffer_r;
logic [$clog2(UCA_SIZE)-1:0][$clog2(UC_LENGTH):0] buffer_w;

logic [NUM_ENGINE-1:0] engmask_r;
logic [NUM_ENGINE-1:0] engmask_w;

logic uc_arb_t curr_state;
logic uc_arb_t next_state;

logic empty;
logic full;
logic push;
logic pop;
logic [$clog2(`UC_LENGTH):0] data;

logic [$clog2(`UC_LENGTH)-1:0][1:0] conflict_table_r;
logic [$clog2(`UC_LENGTH)-1:0][1:0] conflict_table_w;
logic [$clog2(`UC_LENGTH)-1:0]      conflict_detect;
logic [$clog2(`UC_LENGTH)-1:0]      uc_idx;
logic [$clog2(`UC_LENGTH)]          uc_polarity;

assign engmask = engmask_r;

typedef enum logic [1:0] {
	IDLE  = 2'b00,
	READY = 2'b01,
	NEXT  = 2'b10,
    DONE  = 2'b11
} uc_arb_t;

always_comb begin
    for(i=0; i<$clog2(`UCA_SIZE); i++) begin
        buffer_w[i] = buffer_r[i];
    end
    for(i=0; i<$clog2(`UC_LENGTH); i++) begin
        conflict_table_w[i] = conflict_table_r[i];
    end
    engmask_w  = engmask_r;
    next_state = curr_state;
    data       = 'b0;
    push       = 'b0;
    pop        = 'b0;
    conflict   = 'b0;

    case (curr_state)
        IDLE: begin
            engmask_w  = 'b0;
            next_state = mem2uca_done ? READY : IDLE;
        end
        READY: begin
            // Update mask
            engmask_w = engmask_r == 'b0 ? 'b1 : engmask_r << 1;

            // Check for conflicts before registering data
            if |conflict_detect == 1 begin
                next_state = DONE;
            end
            else begin
                next_state = NEXT;
            end
        end
        NEXT: begin
            if eng2uca_empty == 'b1 begin
                next_state = READY;
            end
            else begin
                push = 'b1;
                data = eng2uca;
                {uc_polarity, uc_idx} = eng2uca;
                conflict_table_w[uc_idx][uc_polarity] = 'b1;
                next_state = READY;
            end
        end
        DONE: begin
            conflict = 'b1;
        end
    endcase

    // Pop data from inner buffer to output if not empty
    // Might not be able to pop and must stall if engine RCV FIFO is full
    if empty != 'b0 begin
        pop = 'b1;
    end
end


always_ff @(posedge clk or negedge rst) begin
    if (rst) begin
        for(i=0; i<$clog2(UCA_SIZE); i++) begin
            buffer_r[i] <= 'b0;
        end
        for(i=0; i<$clog2(`UC_LENGTH); i++) begin
            conflict_table_r[i] <= 'b0;
            conflict_detect[i]  <= 'b0;
        end
        engmask_r  <= 'b0;
        curr_state <= IDLE;
    end
    else begin
        for(i=0; i<$clog2(UCA_SIZE); i++) begin
            buffer_r[i] <= buffer_w[i];
        end
        for(i=0; i<$clog2(`UC_LENGTH); i++) begin
            conflict_table_r[i] <= conflict_table_w[i];
            conflict_detect[i]  <= &conflict_table_w[i];
        end
        engmask_r  <= engmask_w;
        curr_state <= next_state;
    end
end

endmodule