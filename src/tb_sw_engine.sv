module tb_sw_engine();
real PERIOD = 10.0;

logic       clk;
logic       rst_n;

//UCQ_in to UC arbiter
logic  ucarb2UCQ_in_pop;
lit_t UCQ_in2uarb_uc;
logic UCQ_in_empty;

//UCQ_out <-> UC arbiter
lit_t ucarb2UCQ_out_uc;
logic ucarb2UCQ_out_push;
logic UCQ_out_full;


//to switch
cla_t carb2sw_cla;
logic carb2sw_valid;

top DUT (
    .clk(clk),
    .rst_n(rst_n),
    
    //UCQ_in to UC arbiter
    .ucarb2UCQ_in_pop(ucarb2UCQ_in_pop),
    .UCQ_in2uarb_uc(UCQ_in2uarb_uc),
    .UCQ_in_empty(UCQ_in_empty),
    
    //UCQ_out <-> UC arbiter
    .ucarb2UCQ_out_uc(ucarb2UCQ_out_uc),
    .ucarb2UCQ_out_push(ucarb2UCQ_out_push),
    .UCQ_out_full(UCQ_out_full),
    
    // sw
    .carb2sw_cla(carb2sw_cla),
    .carb2sw_valid(carb2sw_valid)

);

task initialize();
    clk                = 0;
    rst_n              = 1;
    
    ucarb2UCQ_in_pop   = 0;
    ucarb2UCQ_out_uc   = 0;

    ucarb2UCQ_out_push = 0;
    carb2sw_cla        = 0;
    carb2sw_valid      = 0;

endtask

task ucarbiter_send_UCQ_out(input lit_t in);
    ucarb2UCQ_out_uc   = in;
    ucarb2UCQ_out_push = 1;
endtask

task ucarbiter_stop_UCQ_out();
    ucarb2UCQ_out_uc   = 'b0;
    ucarb2UCQ_out_push = 0;
endtask

task carb_send_sw(input cla_t in);
    carb2sw_cla    = in;
    carb2sw_valid  = 1;
endtask

task carb_stop_send();
    carb2sw_cla   = 'b0;
    carb2sw_valid = 0;
endtask

logic h;
logic t;
task print_ucq_out(int clk);
    $display("------------- UCQ Out State -------------");
    $write("Cycle = %d\n", clk);
    for(int i=0; i<`UCQ_SIZE; ++i) begin
        $write("[%d] = %b", i, DUT.UCQ_out.entry_r[i]);
        h = DUT.UCQ_out.head_r[$clog2(`UCQ_SIZE)-1:0] == i;
        t = DUT.UCQ_out.tail_r[$clog2(`UCQ_SIZE)-1:0] == i;
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
        $write("[%d] = %b", i, DUT.UCQ_in.entry_r[i]);
        h = DUT.UCQ_in.head_r[$clog2(`UCQ_SIZE)-1:0] == i;
        t = DUT.UCQ_in.tail_r[$clog2(`UCQ_SIZE)-1:0] == i;
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
            $write(" %b", DUT.CLQ.buffer[i][j]);
        end
        h = DUT.CLQ.head[$clog2(`CLQ_DEPTH)-1:0] == i;
        t = DUT.CLQ.tail[$clog2(`CLQ_DEPTH)-1:0] == i;
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
        clk_cnt++;
    end
end

initial begin
    initialize();

    @(negedge clk);
    rst_n = 0;
    ucarbiter_send_UCQ_out('b11111111111); // unit clause = (-1)
    carb_send_sw('b000000000000000000000000000000000);  //initial header from c arbiter
    @(negedge clk);
    ucarbiter_stop_UCQ_out();
    carb_send_sw('b000000000010000000001000000000111); // clause = (1, 2, 7)
    @(negedge clk);
    carb_send_sw('b000000000101111111111100000000101); // clause = (2, -1, 5)
    @(negedge clk);
    carb_send_sw('b000000000000000000001100000000001); // clause = (0, 3, 1)
    @(negedge clk);
    carb_send_sw('b000000001100000000001100000000001); // clause = (6, 3, 1)
    @(negedge clk);
    carb2sw_valid = 0;  // Done with sending to SW
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);


    //Expect output
    //In CLQ_FIFO
    // (0, 0, 0) (0, 2, 7) (0, 3, 0) (6, 3, 0)

    //In UCQ_in_FIFO
    // (3)

    $finish;
end

endmodule