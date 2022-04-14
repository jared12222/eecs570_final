module uc_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic input_mode,
    
    input  logic mem2uca_valid,
    input  logic mem2uca_done,
    input  lit_t mem2uca,
    
    // Wrapper to UC arbiter mux-in inputs
    input  logic eng2uca_valid,
    input  logic eng2uca_empty,
    input  lit_t eng2uca_lit,
    // All UCQ in entries are not valid
    input  logic eng2uca_processed,
    // All engines have finished processing its CLQ
    input  logic [`NUM_ENGINE-1:0] eng2uca_stall,
    // MStack full + all UCQ_out full
    input  logic [`NUM_ENGINE:0]   eng2uca_full,
    output lit_t                   uca2eng_lit,
    output logic                   uca2eng_push,
    
    output logic [`NUM_ENGINE-1:0] engmask,
    output logic                   conflict,
    // If UC Arbiter stops at IDLE, it consitutes as one of the
    // prereqs for stalling the engine
    output logic                   stall
);

/*
uca: Unit Clause arbiter
mem: Memory -- Sends a unit clause from the interconnect
input_mode: Mode of receiving implied unit clauses from engine
    (0) Mask mode -- Read every engine queue sequentially
    (1) PQ mode   -- Get input to write to buffer from wrapper PQ
*/

logic [`NUM_ENGINE-1:0] engmask_r;
logic [`NUM_ENGINE-1:0] engmask_w;

uc_arb_t curr_state;
uc_arb_t next_state;

logic empty;
logic full;
logic push;
logic pop;
logic [$clog2(`LIT_IDX_MAX):0] data;

// Index should be [`LIT_IDX_MAX-1:0]
// But truncated on purpose for the sake of easier debugging
logic [`LIT_IDX_MAX-1:0][1:0]    conflict_table_r;
logic [`LIT_IDX_MAX-1:0][1:0]    conflict_table_w;
logic [$clog2(`LIT_IDX_MAX):0]   conflict_detect;

logic [$clog2(`LIT_IDX_MAX)-2:0] uc_idx;
logic                            uc_polarity;

assign engmask = engmask_r;
assign uc_polarity = data[$clog2(`LIT_IDX_MAX)];
assign uc_idx = uc_polarity? 
    ~data[$clog2(`LIT_IDX_MAX)-1:0] + 1 : 
    data[$clog2(`LIT_IDX_MAX)-1:0];

assign stall = (curr_state == UCARB_IDLE && mem2uca_valid == 1'b0);

uc_queue uc_queue (
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .uca2ucq(data),
    .empty(empty),
    .full(full),
    .ucq2eng(uca2eng_lit)
);

always_comb begin
    pop = 'b0;
    uca2eng_push = 'b0;

    if(&eng2uca_full == 'b0) begin
        if(empty == 'b0) begin
            pop = 'b1;
            uca2eng_push = 'b1;
        end        
    end
end

always_comb begin
    conflict_table_w = conflict_table_r;
    engmask_w  = engmask_r;
    next_state = curr_state;
    data       = eng2uca_lit;
    push       = 'b0;
    conflict   = 'b0;

    case (curr_state)
        UCARB_IDLE: begin
            engmask_w  = 'b0;
            push       = mem2uca_valid ? 'b1 : 'b0;
            data       = mem2uca;
            next_state = mem2uca_done ? UCARB_READY : UCARB_IDLE;
        end
        UCARB_READY: begin
            if (input_mode) begin
                if (eng2uca_valid) begin
                    data = eng2uca_lit;
                    push = 'b1;
                    conflict_table_w[uc_idx][uc_polarity] = 'b1;
                end
                // Check for conflicts before registering data
                if(|conflict_detect == 'b1) begin
                    next_state = UCARB_DONE;
                end
                else if (&eng2uca_stall && !eng2uca_processed) begin
                    next_state = UCARB_IDLE;
                end
                else begin
                    next_state = UCARB_READY;             
                end
            end
            else begin
                // Update mask
                engmask_w = engmask_r == 'b0 ? 'b1 : engmask_r << 1;

                // Check for conflicts before registering data
                if(|conflict_detect == 'b1) begin
                    next_state = UCARB_DONE;
                end
                else begin
                    next_state = UCARB_PROC;
                end
            end
        end
        UCARB_PROC: begin
            if(eng2uca_empty == 'b1 | engmask_r == 'b0) begin
                next_state = UCARB_READY;
            end
            else begin
                data = eng2uca_lit;
                push = 'b1;
                conflict_table_w[uc_idx][uc_polarity] = 'b1;
                /*
                0: Not registered
                1: Positice UC
                2: Negative UC
                3: Conflict!
                */
                next_state = UCARB_READY;
            end
        end
        UCARB_DONE: begin
            conflict = 'b1;
        end
    endcase
end


always_ff @(posedge clk) begin
    if (rst) begin
        conflict_table_r <= 'b0;
        conflict_detect  <= 'b0;
        engmask_r  <= 'b0;
        curr_state <= UCARB_IDLE;
    end
    else begin
        // for(int i=0; i<$clog2(`LIT_IDX_MAX); i++) begin
        //     conflict_table_r[i] <= conflict_table_w[i];
        //     conflict_detect[i]  <= &conflict_table_w[i];
        // end
        for (int i=0; i<$clog2(`LIT_IDX_MAX); i++) begin
            conflict_table_r[i] <= conflict_table_w[i];
            conflict_detect[i]  <= &conflict_table_w[i];
        end   
        engmask_r  <= engmask_w;
        curr_state <= next_state;
    end
end

endmodule