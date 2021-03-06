// Clock speed
real PERIOD = 10.0;

module tb_uca();

    logic clk;
    logic rst;
    logic mem2uca_valid;
    logic mem2uca_done;
    logic signed [$clog2(`LIT_IDX_MAX):0] mem2uca;
    logic eng2uca_valid;
    logic eng2uca_empty;
    logic [`NUM_ENGINE-1:0] eng2uca_full;
    logic signed [$clog2(`LIT_IDX_MAX):0] eng2uca;
    logic signed [$clog2(`LIT_IDX_MAX):0] uca2eng;
    logic [`NUM_ENGINE-1:0]               engmask;
    logic                                 conflict;
    
    // Simulated mux control
    logic signed [`NUM_ENGINE-1:0][$clog2(`LIT_IDX_MAX):0] sender;

uc_arbiter dut(
    .clk(clk),
    .rst(rst),
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .eng2uca_valid(eng2uca_valid),
    .eng2uca_empty(eng2uca_empty),
    .eng2uca(eng2uca),
    .eng2uca_full(eng2uca_full),
    .uca2eng(uca2eng),
    .engmask(engmask),
    .conflict(conflict)
);

always begin
    #(PERIOD/2);
    clk = ~clk;
end

task reset_sys();
    // Toggle reset
    rst = 1; 
    @(negedge clk);
    rst = 0; 
endtask

task mem_send(int len);
    for(int i=0; i<len; i++) begin
        @(negedge clk);
        mem2uca_valid = 1;
        mem2uca       = (i+1)*10;
    end
    @(negedge clk);
    mem2uca_valid = 0;
    mem2uca_done  = 1;
endtask

task eng_send();
    // Assuming this entire for loop is combinational
    @(negedge clk);
    @(negedge clk);
    for(int i=0; i<`NUM_ENGINE; i++) begin
        $display("Current Mask: %d", engmask);
        $display("Current Iter: %d", i);
        if (engmask[i]) begin
            eng2uca_empty = sender[i] == 'b0 ? 'b1 : 'b0;
            $display("sender value: %d", sender[i]);
            eng2uca       = sender[i];
            break;
        end
    end
endtask

task eng_read();
    @(negedge clk);
    eng2uca_rd = 'b1;
endtask

initial begin
    clk = 0;
    
    // Memory to uca
    mem2uca_valid = 0;
    mem2uca_done  = 0;
    mem2uca       = 0;

    // Engine to uca
    eng2uca_valid = 0;
    eng2uca_empty = 0;
    eng2uca       = 0;
    eng2uca_full  = 0;

    sender[0] = 2;
    sender[1] = 4;
    sender[2] = 3;
    sender[3] = -2;

    reset_sys();

    // Send Unit clauses from memory
    mem_send(5);

    eng_send();
    eng_send();
    eng_send();
    eng_send();

    repeat(10) begin
        eng_read();
    end

    repeat(10) begin
        @(negedge clk);
    end

    $finish;
end

endmodule