`define STEP #10

module tb_bcp();
    
    // signals
    logic clk;
    logic rst_n;
    

    lit_t litDec; // New decision literal
    cla_t clause; // input clause
    
    logic ENG_P_FULL;
    logic UCQ_out_empty;
    logic CLQ_empty;
        
    logic imply;
    lit_t imply_idx;
        
    cla_t pr_clause; // output pruned clause
    
    logic done; // the clause is satisfied
    logic conflict; // if all literal are assigned, set if the clause cannot satisfy

    logic UCQ_out_pop;
    logic CLQ_pop;

    bcp_pe DUT(
        .clk(clk),
        .rst_n(rst_n),
        .litDec(litDec),
        .clause(clause),
        .ENG_P_FULL(ENG_P_FULL),
        .UCQ_out_empty(UCQ_out_empty),
        .CLQ_empty(CLQ_empty),
        
        .imply(imply),
        .imply_idx(imply_idx),
        .pr_clause(pr_clause),
        .done(done),
        .conflict(conflict),

        .UCQ_out_pop(UCQ_out_pop),
        .CLQ_pop(CLQ_pop),
        .ENG_P_push(ENG_P_push)
    );

    function printstate();
        $write("--------------\n");
        $write("ENG_P_FULL: %b\n", ENG_P_FULL);
        $write("UCQ_out_empty: %b\n", UCQ_out_empty);
        $write("CLQ_empty: %b\n", CLQ_empty);

        $write("\nlitDec: %d\n", litDec);
        $write("clause:");
        for(int i = `CLA_LENGTH-1; i >= 0; i--) begin
            $write("%d", clause[i]);
        end
        $write("\nimply: %b\nimply_idx: %d\ndone: %b\nconflict: %b\n", imply, imply_idx, done, conflict);
        $write("pr_clause: ");
        for(int i = `CLA_LENGTH-1; i >= 0; i--) begin
            $write(" %d", pr_clause[i]);
        end

        $write("\n\nUCQ_out_pop: %b", UCQ_out_pop);
        $write("\ncla_queue_pop: %b", CLQ_pop);
        $write("\nENG_P_push: %b", ENG_P_push);

        // Inner state, comment when synthesis
        $write("\nbcp_pe.uc: %d", DUT.uc);
        $write("\nbcp_pe.stall: %b", DUT.stall);
        $write("\nbcp_pe.nonzero: %b\n", DUT.nonzero);
        $write("\n--------------\n");
    endfunction

    always begin
        `STEP;
        clk = ~clk;
    end

    task stall_test();
        $write("---------- Stall Test ----------\n");
        ENG_P_FULL = 1;
        UCQ_out_empty = 0;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;
        ENG_P_FULL = 0;
        UCQ_out_empty = 1;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;
        ENG_P_FULL = 0;
        UCQ_out_empty = 0;
        CLQ_empty = 1;

        @(negedge clk);
        printstate(); #1;

        ENG_P_FULL = 1;
        UCQ_out_empty = 1;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;
        ENG_P_FULL = 0;
        UCQ_out_empty = 1;
        CLQ_empty = 1;
        @(negedge clk);
        printstate(); #1;
        ENG_P_FULL = 1;
        UCQ_out_empty = 0;
        CLQ_empty = 1;
        @(negedge clk);
        printstate(); #1;
        ENG_P_FULL = 1;
        UCQ_out_empty = 1;
        CLQ_empty = 1;
        @(negedge clk);
        printstate(); #1;
        $write("---------- Stall Test End ----------\n");
    endtask
    
    task test_run();
        litDec = 1;
        UCQ_out_empty = 0;
        clause = 0;
        ENG_P_FULL = 0;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;

        UCQ_out_empty = 1;
        clause = 1;
        ENG_P_FULL = 1;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;

        litDec = 2;
        UCQ_out_empty = 0;
        clause = 2;
        ENG_P_FULL = 1;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;

        litDec = 2;
        UCQ_out_empty = 0;
        clause = 2;
        ENG_P_FULL = 0;
        CLQ_empty = 1;
        @(negedge clk);
        printstate(); #1;

        litDec = 2;
        UCQ_out_empty = 0;
        clause[0] = 1;
        clause[1] = 1;
        clause[2] = 1;
        ENG_P_FULL = 0;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;

        litDec = 2;
        UCQ_out_empty = 0;
        clause[0] = 1;
        clause[1] = 4;
        clause[2] = 5;
        ENG_P_FULL = 0;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;

        litDec = 2;
        UCQ_out_empty = 0;
        clause[0] = -1;
        clause[1] = 2;
        clause[2] = 3;
        ENG_P_FULL = 0;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;

        litDec = 2;
        UCQ_out_empty = 0;
        clause[0] = 0;
        clause[1] = 0;
        clause[2] = 0;
        ENG_P_FULL = 0;
        CLQ_empty = 0;
        @(negedge clk);
        printstate(); #1;


    endtask
    initial begin
        clk = 0;
        rst_n = 1;
        clause = 0;
        @(negedge clk);
        rst_n = 0;

        stall_test();
        test_run();

        $finish;
        $display("Finish exe!");
    end
endmodule
