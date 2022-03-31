module tb_sw_engine_ucarb();
real PERIOD = 10.0;

logic       clk;
logic       rst_n;

//to switch
cla_t carb2sw_cla;
logic carb2sw_valid;

//mem to uca
logic mem2uca_valid;
logic mem2uca_done;
lit_t mem2uca;

logic conflict;

top DUT (
    .clk(clk),
    .rst_n(rst_n),

    // SW
    .carb2sw_cla(carb2sw_cla),
    .carb2sw_valid(carb2sw_valid),

    // UCA I/O
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .conflict(conflict)

);

task initialize();
    clk           = 0;
    rst_n         = 1;
    
    carb2sw_cla   = 0;
    carb2sw_valid = 0;
    
    mem2uca_valid = 0;
    mem2uca_done  = 0;
    mem2uca       = 0;
endtask

task carb_send_sw(input cla_t in);
    carb2sw_cla    = in;
    carb2sw_valid  = 1;
endtask

task carb_stop_send();
    carb2sw_cla   = 'b0;
    carb2sw_valid = 0;
endtask

task mem2uca_send(input lit_t in);
    mem2uca_valid = 1;
    mem2uca_done  = 1;
    mem2uca       = in;
endtask

// task mem2uca_send();
//     mem2uca       = 'b11111111111; // unit clause = (-1)
//     mem2uca_valid = 1;
//     mem2uca_done  = 1;
// endtask

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

task check_normal_case();
    mem2uca_send('b11111111111);  // initial unit clause = (-1)
    carb_send_sw('b000000000000000000000000000000000);  //initial header from c arbiter
    @(negedge clk);
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
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
endtask

task check_conflict();
    mem2uca_send('b11111111111); // initial unit clause = (-1)
    carb_send_sw('b000000000000000000000000000000000);  //initial header from c arbiter
    @(negedge clk);
    carb_send_sw('b000000000010000000001000000000111); // clause = (1, 2, 7)
    @(negedge clk);
    carb_send_sw('b000000000101111111111100000000101); // clause = (2, -1, 5)
    @(negedge clk);
    carb_send_sw('b000000000000000000001100000000001); // clause = (0, 3, 1)
    @(negedge clk);
    carb_send_sw('b000000000001111111110100000000001); // clause = (0, -3, 1)
    @(negedge clk);
    carb2sw_valid = 0;  // Done with sending to SW
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