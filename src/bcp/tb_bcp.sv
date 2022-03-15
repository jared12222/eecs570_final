`define STEP #10

module tb_bcp();
    
    // signals
    lit_t litDec; // New decision literal
    cla_t clause; // input clause
        
    logic imply;
    lit_t imply_idx;
        
    cla_t pr_clause; // output pruned clause
    
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

    function printstate();
        $write("--------------\n");
        $write("litDec: %d\n", litDec);
        $write("clause:");
        for(int i = `CLA_LENGTH-1; i >= 0; i--) begin
            $write(" %d", clause[i]);
        end
        $write("\nimply: %b\nimply_idx: %d\ndone: %b\nconflict: %b\n", imply, imply_idx, done, conflict);
        $write("pr_clause: ");
        for(int i = `CLA_LENGTH-1; i >= 0; i--) begin
            $write(" %d", pr_clause[i]);
        end

        // Inner state, comment when synthesis
        $write("\nbcp_pe.nonzero: %b\n", DUT.nonzero);
        $write("\n--------------\n");
    endfunction

    initial begin
    // SAT test case
        // Implication
        for(int i = 0; i < `CLA_LENGTH-1; i=i+1) begin

            for(int j = i+1; j < `CLA_LENGTH; j=j+1) begin
                clause = 'b0;
                clause[i] = $random%`LIT_INDEX_MAX;
                clause[j] = $random%`LIT_INDEX_MAX;
                
                litDec = -clause[i];
                /*assert(
                    imply === 'b1 &&
                    imply_idx === clause[i] &&
                    done === 'b0 &&
                    conflict === 'b0
                );*/
                `STEP;
                printstate();
                litDec = -clause[j];
                /*assert(
                    imply === 'b1 &&
                    imply_idx === clause[j] &&
                    done === 'b0 &&
                    conflict === 'b0
                );*/
                `STEP;
                printstate();
            end
        end
        
        // Conflict            
        for(int i = 0; i < `CLA_LENGTH; i=i+1) begin
            clause = 'b0;
            
            clause[i] = $random%`LIT_INDEX_MAX;
            // do begin
            // end while(clause[i] != 'b0);
            litDec = -clause[i];

            /*assert(
                imply === 'b0 &&
                done === 'b0 &&
                conflict === 'b1
            );*/
            `STEP;
            printstate();
        end
        
        // SAT
        clause = $random;
        // do begin
        // end while (clause != 'b0);
        for(int i = 0; i < `CLA_LENGTH; i=i+1) begin
            litDec = clause[i];
            if (clause[i] != 'b0) begin
                /*assert(
                    imply === 'b0 &&
                    done === 'b1 &&
                    conflict === 'b0
                );*/
                `STEP;
                printstate();
            end
            else begin
		/*
                assert(
                    imply === 'b0 &&
                    done === 'b0 &&
                    conflict === 'b0
                );*/
                `STEP;
                printstate();
            end
        end
        $display("Reach end! Expect finish.");
        $finish;
        $display("Finish exe!");
    end
endmodule
