// Clock speed
real PERIOD = 10.0;

module tb_uca();

    // Module port injections
    logic clk;
    logic rst;
    logic mem2uca_valid;
    logic mem2uca_done;
    logic signed [$clog2(`LIT_IDX_MAX):0] mem2uca;
    logic signed [`NUM_ENGINE-1:0][$clog2(`LIT_IDX_MAX):0] eng2uca_min;
    logic [`NUM_ENGINE-1:0] eng2uca_valid;
    logic [`NUM_ENGINE-1:0] eng2uca_empty;
    logic [`NUM_ENGINE-1:0] eng2uca_full;
    logic signed [$clog2(`LIT_IDX_MAX):0] uca2eng;
    logic input_mode;
    logic uca2eng_pop;
    logic conflict;

    // Testbench variables
    int addr;

uc_arbiter_wrapper dut(
    .clk(clk),
    .rst(rst),
    .mem2uca_valid(mem2uca_valid),
    .mem2uca_done(mem2uca_done),
    .mem2uca(mem2uca),
    .eng2uca_min(eng2uca_min),
    .eng2uca_valid(eng2uca_valid),
    .eng2uca_empty(eng2uca_empty),
    .eng2uca_full(eng2uca_full),
    .uca2eng(uca2eng),
    .input_mode(input_mode),
    .uca2eng_pop(uca2eng_pop),
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

task eng_load_head();
    @(negedge clk);
    for(int i=1; i<`NUM_ENGINE+1; i++) begin
        if (i%2 == 'b0) begin
            eng2uca_min  [i-1] = (i+1);
            eng2uca_valid[i-1] = 'b1;
            eng2uca_empty[i-1] = 'b0;
        end
        else begin
            eng2uca_min  [i-1] = 'b0;
            eng2uca_valid[i-1] = 'b0;
            eng2uca_empty[i-1] = 'b0;            
        end
    end
endtask

task eng_clear_head();
    @(negedge clk);
    for(int i=0; i<`NUM_ENGINE; i++) begin
            eng2uca_min  [i] = 'b0;
            eng2uca_valid[i] = 'b0;
            eng2uca_empty[i] = 'b0;
    end
endtask

task eng_full_stall_uca();
    addr = $urandom();
    eng2uca_full[addr%`NUM_ENGINE] = 'b1;
endtask

task free_uca();
    eng2uca_full = 0;
endtask

// task eng_send();
//     // Assuming this entire for loop is combinational
//     @(negedge clk);
//     @(negedge clk);
//     for(int i=0; i<`NUM_ENGINE; i++) begin
//         $display("Current Mask: %d", engmask);
//         $display("Current Iter: %d", i);
//         if (engmask[i]) begin
//             eng2uca_empty = sender[i] == 'b0 ? 'b1 : 'b0;
//             $display("sender value: %d", sender[i]);
//             eng2uca       = sender[i];
//             break;
//         end
//     end
// endtask

// task eng_read();
//     @(negedge clk);
//     eng2uca_rd = 'b1;
// endtask

initial begin
    clk = 0;
    
    // Memory to uca
    mem2uca_valid = 0;
    mem2uca_done  = 0;
    mem2uca       = 0;

    // Engine to uca
    eng2uca_valid = 0;
    eng2uca_empty = 0;
    eng2uca_min   = 0;
    eng2uca_full  = 0;

    input_mode    = 1;

    reset_sys();

    // Send Unit clauses from memory
    mem_send(5);

    eng_load_head();
    repeat(4) begin
        @(negedge clk);
    end
    eng_clear_head();

    eng_full_stall_uca();
    repeat(5) begin
        @(negedge clk);
    end
    free_uca();

    // repeat(10) begin
    //     eng_read();
    // end

    repeat(20) begin
        @(negedge clk);
    end

    $finish;
end

endmodule