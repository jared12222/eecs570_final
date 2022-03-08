`define STEP #10
module tb_bcp();
    
    // signals
    logic [$clog2(`LIT_INDEX_MAX):0] litDec; // New decision literal
    signed logic [`CLA_LENGTH-1:0][$clog2(`LIT_INDEX_MAX):0] clause; // input clause
        
    logic imply;
    signed logic [$clog2(`LIT_INDEX_MAX):0] imply_idx;
        
    signed logic [`CLA_LENGTH-1:0][$clog2(`LIT_INDEX_MAX):0] pr_clause; // output pruned clause
    
    logic done; // the clause is satisfied
    logic conflict; // if all literal are assigned, set if the clause cannot satisfy


    bcp_pe DUT(
        .litDec(litDec),
        .clause(clause),
        
        .imply(imply),
        .imply_idx(imply_idx),
        .pr_clause(pr_clause),
        .done(done),
        .conflict(conflict)
    );

    initial begin
        // SAT test case
    end
endmodule