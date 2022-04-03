`define STEP #10

module tb_bcp();
    
    // signals
    logic clk;
    logic rst_n;

    // CLQ <->
    // input clause
    node_t node;
    ptr_t  next_node_ptr;

    // Ucarb <-> BCP engine
    lit_t newLit;
    logic newLitValid;
    ptr_t newLitHeadPtr;
    logic newLitAccept;
    
    // CArb <-> BCP engine
    // Wait till carb has fully written everything to CLQ
    logic halt;

    // Global State Table <-> BCP engine
    cla_t       bcp2gst_curr_cla;
    logic       bcp2gst_curr_cla_valid;
    bcp_state_t bcp2gst_curr_state;
    lit_state_t [`CLA_LENGTH-1:0] gst2bcp_lit_state;

    // implication (unit clause)
    logic imply_valid;
    lit_t imply_lit;

    logic conflict;

    bcp_pe DUT (
    .clk(clk),
    .rst_n(rst_n),

    // CLQ <->
    // input clause
    .node(node),
    .next_node_ptr(next_node_ptr),

    // Ucarb <-> BCP engine
    .newLit(newLit),
    .newLitValid(newLitValid),
    .newLitHeadPtr(newLitHeadPtr),
    .newLitAccept(newLitAccept),
    
    // CArb <-> BCP engine
    // halt
    .halt(halt),

    // Global State Table <-> BCP engine
    .bcp2gst_curr_cla(bcp2gst_curr_cla),
    .bcp2gst_curr_cla_valid(bcp2gst_curr_cla_valid),
    .bcp2gst_curr_state(bcp2gst_curr_state),
    .gst2bcp_lit_state(gst2bcp_lit_state),

    // implication (unit clause)
    .imply_valid(imply_valid),
    .imply_lit(imply_lit),

    .conflict(conflict) // if all literal are assigned, set if the clause cannot satisfy
);

    // function printstate();
    //     $write("--------------\n");
    //     $write("ENG_P_FULL: %b\n", ENG_P_FULL);
    //     $write("UCQ_out_empty: %b\n", UCQ_out_empty);
    //     $write("CLQ_empty: %b\n", CLQ_empty);

    //     $write("\nlitDec: %d\n", litDec);
    //     $write("clause:");
    //     for(int i = `CLA_LENGTH-1; i >= 0; i--) begin
    //         $write("%d", clause[i]);
    //     end
    //     $write("\nimply: %b\nimply_idx: %d\ndone: %b\nconflict: %b\n", imply, imply_idx, done, conflict);
    //     $write("pr_clause: ");
    //     for(int i = `CLA_LENGTH-1; i >= 0; i--) begin
    //         $write(" %d", pr_clause[i]);
    //     end

    //     $write("\n\nUCQ_out_pop: %b", UCQ_out_pop);
    //     $write("\ncla_queue_pop: %b", CLQ_pop);
    //     $write("\nENG_P_push: %b", ENG_P_push);

    //     // Inner state, comment when synthesis
    //     $write("\nbcp_pe.uc: %d", DUT.uc);
    //     $write("\nbcp_pe.stall: %b", DUT.stall);
    //     $write("\nbcp_pe.nonzero: %b\n", DUT.nonzero);
    //     $write("\n--------------\n");
    // endfunction

    task send_clause(lit_t a, lit_t b, lit_t c);
        node.cla = {a, b, c};
    endtask

    task send_ptrs(ptr_t a, ptr_t b, ptr_t c);
        node.ptr = {a, b, c};
    endtask

    task send_litState(lit_state_t a, lit_state_t b, lit_state_t c);
        gst2bcp_lit_state = {a, b, c};
    endtask

    always begin
        `STEP;
        clk = ~clk;
    end

    task stall_test();
        $write("---------- Stall Test ----------\n");
        $write("---------- Stall Test End ----------\n");
    endtask
    
    task test_run();
        rst_n = 1;
        halt = 1;
        @(negedge clk); // halt
        rst_n = 0;
        newLit = -1;
        newLitValid = 1;
        newLitHeadPtr = 1;
        
        @(negedge clk); // START, latch in literal & ptr
        halt = 0;

        @(negedge clk);
        send_clause(-1, 2, 3);
        send_litState(FALSE, UNDEFINED, UNDEFINED);
        send_ptrs(3, 0, 0);

        @(negedge clk); // IMPLY
        send_clause(1, 2, 3);
        send_litState(FALSE, FALSE, UNDEFINED);
        send_ptrs(4, 0, 0);

        @(negedge clk); // CONFLICT
        send_clause(-1, 2, 3);
        send_litState(TRUE, FALSE, FALSE);
        send_ptrs(5, 0, 0);

        @(negedge clk); // SAT, NOTHING, should DONE in the next cycle
        send_clause(-1, 2, 3);
        send_litState(TRUE, FALSE, TRUE);
        send_ptrs(0, 0, 0);

                

    endtask
    initial begin
        clk = 0;
        test_run();
        
        @(negedge clk);
        @(negedge clk);
        
        $finish;
        $display("Finish exe!");
    end
endmodule
