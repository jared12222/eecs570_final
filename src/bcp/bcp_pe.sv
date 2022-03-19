// Index of literal is represented in 2's complement and width of index is log2(LIT_INDEX_MAX)+1, zero reserved for pruning
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
    input  lit_t litDec, // New decision literal
    input  cla_t clause, // input clause
    input  ENG_P_FULL,
    input  UCQ_out_empty,
    input  CLQ_empty,
    
    // implication (unit clause)
    output logic imply,
    output lit_t imply_idx,
    
    output cla_t pr_clause, // output pruned clause

    output logic done, // the clause is satisfied
    output logic conflict, // if all literal are assigned, set if the clause cannot satisfy
    
    output logic UCQ_out_pop,
    output logic CLQ_pop,
    output logic ENG_P_push
);
    logic [`CLA_LENGTH-1:0] nonzero;
    logic stall;
    lit_t uc;

    assign stall = (clause == 'b0 && UCQ_out_empty) | ENG_P_FULL | CLQ_empty;
    assign UCQ_out_pop = (clause == 'b0 && !stall) ? 1 : 0;
    assign CLQ_pop = !stall;
    assign ENG_P_push = !stall && !done;

    always_comb begin
        // Initialization
        done = 'b0;
        imply = 'b0;
        imply_idx = 'bx;
        // Determine if clause satisfy : Comparing literals indexes
        for (int i=0; i < `CLA_LENGTH ; i++ ) begin
            if (uc != 'b0) begin
                if (uc == clause[i]) begin
                    pr_clause[i] = 0;
                    done = 'b1;
                end
                else if (-uc == clause[i]) begin
                    pr_clause[i] = 0;
                end
                else pr_clause[i] = clause[i];

            end
            else begin

            end
            if (pr_clause[i] != 0)
                nonzero[i] = 1;
            else
                nonzero[i] = 0;
        end

        for (int i = 0 ; i < `CLA_LENGTH ; i++ ) begin
            if(nonzero == (1 << i)) begin
                imply = 1;
                imply_idx = clause[i];
            end
        end
        if (pr_clause == 'b0 && done != 1)
            conflict = 1;
        else
            conflict = 0;
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            uc <= 'b0;
        end
        else begin
            if (UCQ_out_pop) begin
                uc <= litDec;
            end
        end
    end
endmodule