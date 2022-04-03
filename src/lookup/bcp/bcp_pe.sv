// Index of literal is represented in 2's complement and width of index is log2(LIT_IDX_MAX)+1, zero reserved for pruning
/* Truth table
            | done | conflict | imply
    SAT     | T    | X        | X    
    UNSAT   | F    | T        | X
    IMPLY   | F    | F        | T
    OTHER   | F    | F        | F

    literals
    match w/ negation => set to 0
    match   => SAT (dont care)
*/
module bcp_pe (
    input  clk,
    input  rst_n,

    // CLQ <->
    // input clause
    input node_t node,
    output ptr_t next_node_ptr,

    // Ucarb <-> BCP engine
    input  lit_t newLit,
    input        newLitValid,
    input  ptr_t newLitHeadPtr,
    output logic newLitAccept,
    
    // CArb <-> BCP engine
    // Wait till carb has fully written everything to CLQ
    input halt,

    // Global State Table <-> BCP engine
    output cla_t       bcp2gst_curr_cla,
    output logic       bcp2gst_curr_cla_valid,
    output bcp_state_t bcp2gst_curr_state,
    input  lit_state_t [`CLA_LENGTH-1:0] gst2bcp_lit_state,

    // implication (unit clause)
    output logic imply_valid,
    output lit_t imply_lit,

    output logic conflict // if all literal are assigned, set if the clause cannot satisfy
);
    logic [`CLA_LENGTH-1:0] nonzero;
    logic stall;

    assign stall = halt;

    /*
        Updated intermediate logic
    */

    bcp_state_t curr_state;
    bcp_state_t next_state;

    lit_t curr_lit;
    lit_t next_lit;

    // Pointers for each clause
    ptr_t curr_ptr;
    ptr_t next_ptr; 

    // BCP computation
    logic [`CLA_LENGTH-1:0] someTrue;
    logic [$clog2(`CLA_LENGTH)-1:0] someUNDEF;
    /*
        End of Updated intermediate logic
    */

    assign next_node_ptr = next_ptr;

    always_comb begin
        // Initialization
        imply_valid = 'b0;
        imply_lit = 'b0;
        conflict = 0;
        newLitAccept = 0;
        next_lit = newLit;
        bcp2gst_curr_cla = node.cla;
        bcp2gst_curr_state = curr_state;
        bcp2gst_curr_cla_valid = 0;

        next_state = curr_state;
        next_ptr   = curr_ptr;

        if(!halt) begin
            case (curr_state)
                BCP_IDLE: begin
                    newLitAccept = 1;
                    if (newLitValid) begin
                        next_ptr = newLitHeadPtr;
                        next_state = BCP_PROC;
                    end
                end
                BCP_PROC: begin
                    bcp2gst_curr_cla_valid = 1;
                    // Update next pointer
                    // Capture the literal of interest via a for loop
                    for (int i=0; i<`CLA_LENGTH; i++) begin
                        if (node.cla[i] == curr_lit) begin
                            if (node.ptr[i] != 'b0)
                                next_ptr = node.ptr[i];
                            else
                                next_state = BCP_DONE;
                        end
                    end
                    // Make implications according to status of each literals
                    // Determine if clause satisfy : Comparing literals indexes
                    for (int i=0; i < `CLA_LENGTH ; i++ ) begin
                        someTrue[i]  =  gst2bcp_lit_state[i] == TRUE  && node.cla[i] > 0 ||
                                        gst2bcp_lit_state[i] == FALSE && node.cla[i] < 0;
                        someUNDEF[i] =  gst2bcp_lit_state[i] == UNDEFINED;
                        if (someUNDEF[i]) imply_lit = node.cla[i];
                    end

                    if (! |someTrue) begin // No Literal is True
                        if (! |someUNDEF) // No UNDEFINED
                            conflict = 1;
                        else begin // At least one is UNDEF
                            for (int i = 0; i < `CLA_LENGTH; i++) begin
                                if(someUNDEF == (1<<i)) begin // Check if only one is UNDEF
                                    imply_valid = 1;
                                end
                            end
                        end
                    end
                end
                BCP_DONE: begin
                    newLitAccept = 1;
                    if (newLitValid) begin
                        next_ptr = newLitHeadPtr;
                        next_state = BCP_PROC;
                    end
                end

            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            curr_state <= BCP_IDLE;
            curr_ptr   <= 'b0;
            curr_lit   <= 'b0;
        end
        else begin
            curr_state <= next_state;
            curr_ptr   <= next_ptr;
            curr_lit   <= next_lit;
        end
    end
endmodule