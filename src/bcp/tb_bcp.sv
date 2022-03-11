`define STEP #10
`define LIT_INDEX_MAX 1024
`define CLA_LENGTH 3

module tb_bcp();
    
    // signals
    logic [$clog2(`LIT_INDEX_MAX):0] litDec; // New decision literal
    logic signed [`CLA_LENGTH-1:0][$clog2(`LIT_INDEX_MAX):0] clause; // input clause
        
    logic imply;
    logic signed [$clog2(`LIT_INDEX_MAX):0] imply_idx;
        
    logic signed [`CLA_LENGTH-1:0][$clog2(`LIT_INDEX_MAX):0] pr_clause; // output pruned clause
    
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
        // Implication
        for(int i = 0; i < `CLA_LENGTH-1; i=i+1) begin
            clause = 'b0;
            do begin
                clause[i] = $random%`LIT_INDEX_MAX;
            end while(clause[i] != 'b0);

            for(int j = i+1; j < `CLA_LENGTH; j=j+1) begin
                
                do begin
                    clause[j] = $random%`LIT_INDEX_MAX;
                end while(clause[j] != 'b0);
                
                litDec = clause[i];
                /*assert(
                    imply === 'b1 &&
                    imply_idx === clause[i] &&
                    done === 'b0 &&
                    conflict === 'b0
                );*/
                `STEP; 
                litDec = clause[j];
                /*assert(
                    imply === 'b1 &&
                    imply_idx === clause[j] &&
                    done === 'b0 &&
                    conflict === 'b0
                );*/
                `STEP;
            end
        end
        
        // Conflict            
        for(int i = 0; i < `CLA_LENGTH; i=i+1) begin
            clause = 'b0;
            
            do begin
                clause[i] = $random%`LIT_INDEX_MAX;
            end while(clause[i] != 'b0);
            litDec = clause[i];

            /*assert(
                imply === 'b0 &&
                done === 'b0 &&
                conflict === 'b1
            );*/
            `STEP;
        end
        
        // SAT
        do begin
            clause = $random;
        end while (clause != 'b0);
        for(int i = 0; i < `CLA_LENGTH; i=i+1) begin
            litDec = clause[i];
            if (clause[i] != 'b0) begin
                /*assert(
                    imply === 'b0 &&
                    done === 'b1 &&
                    conflict === 'b0
                );*/
                `STEP;
            end
            else begin
		/*
                assert(
                    imply === 'b0 &&
                    done === 'b0 &&
                    conflict === 'b0
                );*/
                `STEP;
            end
        end
        $finish;
    end
endmodule
