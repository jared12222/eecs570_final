real PERIOD = 10.0;

module tb();

logic       clk;
logic       rst_n;
logic       halt;
node_t      node_in;
logic       node_in_valid;
logic       change_eng;
ptr_t       dummy_ptr;
logic       dummy_ptr_valid;
logic       conflict;

lit_t       mem2uca;
logic       mem2uca_done;
logic       mem2uca_valid;

logic mstack_pop;
logic mstack_empty;
lit_t mstack_lit;

integer clk_cnt;

top DUT(
    .clk(clk),
    .rst_n(rst_n),
    .halt(halt),
    .node_in(node_in),
    .node_in_valid(node_in_valid),
    .change_eng(change_eng),
    .dummy_ptr(dummy_ptr),
    .dummy_ptr_valid(dummy_ptr_valid),

    .mem2uca(mem2uca),
    .mem2uca_done(mem2uca_done),
    .mem2uca_valid(mem2uca_valid),
    .conflict(conflict),

    
    .mstack_pop(mstack_pop),
    .mstack_empty(mstack_empty),
    .mstack_lit(mstack_lit)
);

node_t nodes_queue[`NUM_ENGINE][$];

task rst_task();
    // Signal Initialization
    clk     = 0;
    rst_n   = 1;
    halt    = 1;
    node_in = 0;
    node_in_valid = 0;
    change_eng = 0;
    dummy_ptr = 0;
    dummy_ptr_valid = 0;
    mem2uca_done  = 0;
    mem2uca_valid = 0;
    mstack_pop = 0;

    @(negedge clk);
    rst_n = 0;
endtask

always begin
    clk = ~clk;
    #(PERIOD/2);
    if (clk) begin
        clk_cnt = clk_cnt + 1;
    end
end

initial begin
    clk = 0;
    clk_cnt = 0;
    rst_n = 1;
    $finish;
end

endmodule