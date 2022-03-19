`define UC_LENGTH 1024
`define NUM_ENGINE 4
`define MAX_UC 64

module uc_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic mem2uca_valid,
    input  logic mem2uca_done,
    input  logic signed [$clog2(`UC_LENGTH)-1:0] mem2uca,
    input  logic eng2uca_valid,
    input  logic eng2uca_empty,
    input  logic signed [$clog2(`UC_LENGTH)-1:0] eng2uca,
    input  logic eng2uca_rd,
    output logic signed [$clog2(`UC_LENGTH)-1:0] uca2eng,
    output logic [`NUM_ENGINE-1:0]        engmask,
    output logic                          conflict
);

// TODO
// Add a MUX outside of this module to select input
// Signal outside world that inner buffer is full

typedef enum logic [1:0] {
	IDLE  = 2'b00,
	READY = 2'b01,
	PROC  = 2'b10,
    DONE  = 2'b11
} uc_arb_t;

logic [`NUM_ENGINE-1:0] engmask_r;
logic [`NUM_ENGINE-1:0] engmask_w;


uc_arb_t curr_state;
uc_arb_t next_state;

logic empty;
logic full;
logic push;
logic pop;
logic [$clog2(`UC_LENGTH)-1:0] data;

// Index should be [`UC_LENGTH-1:0]
// But truncated on purpose for the sake of easier debugging
logic [`UC_LENGTH-1:0][1:0]    conflict_table_r;
logic [`UC_LENGTH-1:0][1:0]    conflict_table_w;
logic [$clog2(`UC_LENGTH)-1:0] conflict_detect;
logic [$clog2(`UC_LENGTH)-2:0] uc_idx;
logic                          uc_polarity;

assign engmask = engmask_r;
assign uc_polarity = data[$clog2(`UC_LENGTH)-1];
assign uc_idx = uc_polarity? 
    ~data[$clog2(`UC_LENGTH)-2:0] + 1 : 
    data[$clog2(`UC_LENGTH)-2:0];

uc_queue uc_queue (
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .uca2ucq(data),
    .empty(empty),
    .full(full),
    .ucq2eng(uca2eng)
);

always_comb begin
    for(int i=0; i<$clog2(`UC_LENGTH); i++) begin
        conflict_table_w[i] = conflict_table_r[i];
    end
    engmask_w  = engmask_r;
    next_state = curr_state;
    data       = eng2uca;
    push       = 'b0;
    pop        = 'b0;
    conflict   = 'b0;

    case (curr_state)
        IDLE: begin
            engmask_w  = 'b0;
            push       = mem2uca_valid ? 'b1 : 'b0;
            data       = mem2uca;
            next_state = mem2uca_done ? READY : IDLE;
        end
        READY: begin
            // Update mask
            engmask_w = engmask_r == 'b0 ? 'b1 : engmask_r << 1;

            // Check for conflicts before registering data
            if(|conflict_detect == 'b1) begin
                next_state = DONE;
            end
            else begin
                next_state = PROC;
            end
        end
        PROC: begin
            if(eng2uca_empty == 'b1 | engmask_r == 'b0) begin
                next_state = READY;
            end
            else begin
                data = eng2uca;
                push = 'b1;
                conflict_table_w[uc_idx][uc_polarity] = 'b1;
                /*
                0: Not registered
                1: Positice UC
                2: Negative UC
                3: Conflict!
                */
                next_state = READY;
            end
        end
        DONE: begin
            conflict = 'b1;
        end
    endcase

    // Pop data from inner buffer to output if not empty
    // Might not be able to pop and must stall if engine RCV FIFO is full
    if(eng2uca_rd == 'b1) begin
        if(empty == 'b0) begin
            pop = 'b1;
        end
    end
end


always_ff @(posedge clk or negedge rst) begin
    if (rst) begin
        for(int i=0; i<$clog2(`UC_LENGTH); i++) begin
            conflict_table_r[i] <= 'b0;
            conflict_detect[i]  <= 'b0;
        end
        engmask_r  <= 'b0;
        curr_state <= IDLE;
    end
    else begin
        for(int i=0; i<$clog2(`UC_LENGTH); i++) begin
            conflict_table_r[i] <= conflict_table_w[i];
            conflict_detect[i]  <= &conflict_table_w[i];
        end
        engmask_r  <= engmask_w;
        curr_state <= next_state;
    end
end

endmodule