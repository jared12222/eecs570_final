module tb_sw_engine_ucarb();
real PERIOD = 10.0;

logic       clk;
logic       rst_n;

//to latency buffer
logic mem2carb_start;
logic mem2carb_finish;

cla_t mem2carb_clause;
lit_t chosen_uc;
logic chosen_uc_valid;

logic conflict;
logic carb_empty;

top DUT (
    .clk(clk),
    .rst_n(rst_n),

    // Send to latency buffer
    // .carb2sw_cla(carb2sw_cla),
    // .carb2sw_valid(carb2sw_valid),

    // send to latency buffer
    .mem2carb_start(mem2carb_start),
    .mem2carb_finish(mem2carb_finish),
    .mem2carb_clause(mem2carb_clause),

    .mem2carb_uc_valid(chosen_uc_valid),
    .mem2carb_uc(chosen_uc),

    .carb_empty(carb_empty),

    .conflict(conflict)

);

task initialize();
    clk           = 0;
    rst_n         = 1;
    
    mem2carb_start   = 0;
    mem2carb_finish  = 0;
    mem2carb_clause  = 0;
    
    chosen_uc        = 0;
    chosen_uc_valid  = 0;
endtask

task send2latency_buffer(input cla_t in);
    mem2carb_clause = in;
    mem2carb_start  = 1;
endtask

task send2latencyuca(input lit_t in);
    chosen_uc       = in;
    chosen_uc_valid = 1;
endtask

logic h;
logic t;
task print_ucq_out(int clk);
    $display("------------- UCQ Out State -------------");
    $write("Cycle = %d\n", clk);
    for(int i=0; i<`UCQ_SIZE; ++i) begin
        $write("[%d] = %b", i, DUT.eng.UCQ_out.entry_r[i]);
        h = DUT.eng.UCQ_out.head_r[$clog2(`UCQ_SIZE)-1:0] == i;
        t = DUT.eng.UCQ_out.tail_r[$clog2(`UCQ_SIZE)-1:0] == i;
        case({h,t})
            'b11: $write(" <- h,t\n");
            'b10: $write(" <- h\n");
            'b01: $write(" <- t\n");
            default: $write("\n");
        endcase
    end
    $display("-----------------------------------------");
endtask

task print_ucq_in(int clk);
    $display("------------- UCQ in State -------------");
    $write("Cycle = %d\n", clk);
    for(int i=0; i<`UCQ_SIZE; ++i) begin
        $write("[%d] = %b", i, DUT.eng.UCQ_in.entry_r[i]);
        h = DUT.eng.UCQ_in.head_r[$clog2(`UCQ_SIZE)-1:0] == i;
        t = DUT.eng.UCQ_in.tail_r[$clog2(`UCQ_SIZE)-1:0] == i;
        case({h,t})
            'b11: $write(" <- h,t\n");
            'b10: $write(" <- h\n");
            'b01: $write(" <- t\n");
            default: $write("\n");
        endcase
    end
    $display("-----------------------------------------");
endtask

task print_CLQ(int clk);
    $display("------------- CLQ State -------------");
    $write("Cycle = %d\n", clk);
    for(int i=0; i<`CLQ_DEPTH; ++i) begin
        $write("[%d] = ", i);
        for(int j = `CLA_LENGTH-1; j >=0 ; --j) begin
            $write(" %b", DUT.eng.CLQ.buffer[i][j]);
        end
        h = DUT.eng.CLQ.head[$clog2(`CLQ_DEPTH)-1:0] == i;
        t = DUT.eng.CLQ.tail[$clog2(`CLQ_DEPTH)-1:0] == i;
        case({h,t})
            'b11: $write(" <- h,t\n");
            'b10: $write(" <- h\n");
            'b01: $write(" <- t\n");
            default: $write("\n");
        endcase
    end
    $display("-----------------------------------------");
endtask

task print_latency_buffer(int clk);
    $display("------------- Latency Buffer State -------------");
    $write("Cycle = %d\n", clk);
    for(int i=0; i<`NUM_CLAUSE; ++i) begin
        $write("[%d] = ", i);
        for(int j = `CLA_LENGTH-1; j >=0 ; --j) begin
            $write(" %b", DUT.dist_unit.latency_buffer.buffer[i][j]);
        end
        h = DUT.dist_unit.latency_buffer.head[$clog2(`NUM_CLAUSE):0] == i;
        t = DUT.dist_unit.latency_buffer.tail[$clog2(`NUM_CLAUSE):0] == i;
        case({h,t})
            'b11: $write(" <- h,t\n");
            'b10: $write(" <- h\n");
            'b01: $write(" <- t\n");
            default: $write("\n");
        endcase
    end
    $display("-----------------------------------------");
endtask

int clk_cnt=0;
always begin
    #(PERIOD/2);
    clk = ~clk;
    if(!clk) begin
        print_ucq_out(clk_cnt);
        print_ucq_in(clk_cnt);
        print_CLQ(clk_cnt);
        print_latency_buffer(clk_cnt);
        clk_cnt++;
    end
end

task check_normal_case();
    send2latencyuca('b11111111111);  // initial unit clause = (-1)
    send2latency_buffer('b000000000010000000001000000000111); // clause = (1, 2, 7)
    @(negedge clk);
    send2latency_buffer('b000000000101111111111100000000101); // clause = (2, -1, 5)
    @(negedge clk);
    send2latency_buffer('b000000000000000000001100000000001); // clause = (0, 3, 1)
    @(negedge clk);
    send2latency_buffer('b000000001100000000001100000000001); // clause = (6, 3, 1)
    mem2carb_finish = 1;
    @(negedge clk);
    mem2carb_start = 0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

endtask

task check_conflict();
    send2latencyuca('b11111111111); // initial unit clause = (-1)
    send2latency_buffer('b000000000010000000001000000000111); // clause = (1, 2, 7)
    @(negedge clk);
    send2latency_buffer('b000000000101111111111100000000101); // clause = (2, -1, 5)
    @(negedge clk);
    send2latency_buffer('b000000000000000000001100000000001); // clause = (0, 3, 1)
    @(negedge clk);
    send2latency_buffer('b000000000001111111110100000000001); // clause = (0, -3, 1)
    mem2carb_finish = 1;
    @(negedge clk);
    mem2carb_start = 0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

endtask

initial begin
    $display("------------- 1st case, Check normal start -------------");
    initialize();

    @(negedge clk);
    rst_n = 0;

    check_normal_case();
    //Expect output
    //In CLQ_FIFO
    // (0, 0, 0) (0, 2, 7)

    //In UCQ_in_FIFO
    // none
    $display("------------- 1st case, Check normal end -------------");
    $display("------------- 2nd case, Check conflict start -------------");
    initialize();
    @(negedge clk);
    rst_n = 0;
    check_conflict();
    $display("------------- 2nd case, Check conflict end  -------------");
    //Expect output
    //In CLQ_FIFO
    // (0, 0, 0) (0, 2, 7)

    //In UCQ_in_FIFO
    // (3)

    $finish;
end

endmodule