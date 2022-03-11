`define LIT_INDEX_MAX 1024
`define CLA_LENGTH 3

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
    input  [$clog2(`LIT_INDEX_MAX):0] litDec, // New decision literal
    input  [`CLA_LENGTH-1:0][$clog2(`LIT_INDEX_MAX):0] clause, // input clause
    
    // implication (unit clause)
    output logic imply,
    output logic signed [$clog2(`LIT_INDEX_MAX):0] imply_idx,
    
    output logic signed [`CLA_LENGTH-1:0][$clog2(`LIT_INDEX_MAX):0] pr_clause, // output pruned clause

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
        for (int i=0; i < `CLA_LENGTH ; i=i+1 ) begin
            if (litDec != 'b0) begin
                if (litDec == clause[i] && litDec != 'b0) begin
                    pr_clause[i] = 'b0;
                    done = 'b1;
                end
                else if (-litDec == clause[i]) begin
                    pr_clause[i] = 'b0;
                end
                else pr_clause = clause[i];

                if (pr_clause[i] != 'b0)
                    nonzero[i] = 'b1;
                else
                    nonzero[i] = 'b0;
            end
        end

        if (pr_clause == 'b0)
            conflict = 'b1;
        else
            conflict = 'b0;

        for (int i=0; i < `CLA_LENGTH; i=i+1) begin
            if(nonzero == (1 << i)) begin
                imply = 'b1;
                imply_idx = pr_clause[i];
            end
        end
    end
endmodule