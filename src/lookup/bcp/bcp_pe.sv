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

    // CLQ <-> BCP engine
    input  ptr_t  clq2bcp_init_ptr,
    input  logic  clq2bcp_init_ptr_valid,
    input  node_t node,
    output ptr_t  node_ptr,

    // Ucarb (UCQ_OUT) <-> BCP engine
    input  lit_t ucarb2bcp_newLit,
    input        ucarb2bcp_newLitValid,
    output logic bcp2ucarb_newLitAccept,
    
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

    output logic conflict, // if all literal are assigned, set if the clause cannot satisfy
    output logic stall
);
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
    logic [`CLA_LENGTH-1:0]         someTrue;
    logic [`CLA_LENGTH-1:0]         someUNDEF;
    /*
        End of Updated intermediate logic
    */

    assign stall = (curr_state == BCP_IDLE && !ucarb2bcp_newLitValid);
    assign node_ptr = curr_ptr;

    always_comb begin
        // Initialization
        imply_valid = 'b0;
        imply_lit = 'b0;
        conflict = 0;
        bcp2ucarb_newLitAccept = 0;
        next_lit = ucarb2bcp_newLit;
        
        bcp2gst_curr_state = curr_state;
        bcp2gst_curr_cla_valid = 0;

        next_state = curr_state;
        next_ptr   = curr_ptr;
        
        for(int i = 0; i < `CLA_LENGTH; i++) begin
            bcp2gst_curr_cla[i] = node.cla[i] > 0 ?
                node.cla[i] :
                ~node.cla[i] + 1;
        end

        if(!halt) begin
            case (curr_state)
                BCP_IDLE: begin
                    // Pops literal from UCQ_OUT
                    bcp2ucarb_newLitAccept = 1;
                    // Lookup initial pointer position
                    if (ucarb2bcp_newLitValid && 
                        clq2bcp_init_ptr_valid
                    ) begin
                        next_ptr = clq2bcp_init_ptr;
                        next_state = BCP_PROC;
                    end
                end
                BCP_PROC: begin
                    bcp2gst_curr_cla_valid = 1;
                    // Capture the literal of interest via a for loop
                    for (int i=0; i<`CLA_LENGTH; i++) begin
                        if (node.cla[i] == curr_lit) begin
                            if (node.ptr[i] != 'b0)
                                next_ptr = node.ptr[i];
                            else
                                next_state = BCP_IDLE;
                        end
                    end
                    // Make implications according to status of each literals
                    // Determine if clause satisfy : Comparing literals indexes
                    for (int i=0; i < `CLA_LENGTH ; i++ ) begin
                        someTrue[i]  =  node.cla[i] > 0 ? gst2bcp_lit_state[i] == TRUE : gst2bcp_lit_state[i] == FALSE;
                        someUNDEF[i] =  gst2bcp_lit_state[i] == UNDEFINED;
                        if (someUNDEF[i]) imply_lit = node.cla[i];
                    end

                    if ((|someTrue) == 0) begin // No Literal is True
                        if ((|someUNDEF) == 0) // No UNDEFINED
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
