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
    input  lit_t litDec, // New decision literal
    input  cla_t clause, // input clause
    
    // implication (unit clause)
    output logic imply,
    output lit_t imply_idx,
    
    output cla_t pr_clause, // output pruned clause

    output logic done, // the clause is satisfied
    output logic conflict // if all literal are assigned, set if the clause cannot satisfy
);
    logic [`CLA_LENGTH-1:0] nonzero;

    always_comb begin
        // Initialization
        done = 'b0;
        imply = 'b0;
        imply_idx = 'bx;
        // Determine if clause satisfy : Comparing literals indexes
        for (int i=0; i < `CLA_LENGTH ; i++ ) begin
            if (litDec != 'b0) begin
                if (litDec == clause[i]) begin
                    pr_clause[i] = 0;
                    done = 'b1;
                end
                else if (-litDec == clause[i]) begin
                    pr_clause[i] = 0;
                end
                else pr_clause[i] = clause[i];

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
endmodule