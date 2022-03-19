// Clock speed
real PERIOD = 10.0;

module tb_ucq();

logic clk;
logic rst;
logic push;
logic pop;
logic [$clog2(`UC_LENGTH):0] uca2ucq;
logic empty;
logic full;
logic [$clog2(`UC_LENGTH):0] ucq2eng;

`ifndef DEBUG
logic [QUEUE_SIZE-1:0][$clog2(`UC_LENGTH)-1:0] entry_r;
logic [QUEUE_SIZE-1:0][$clog2(`UC_LENGTH)-1:0] entry_w;

logic [$clog2(QUEUE_SIZE):0] head_r;
logic [$clog2(QUEUE_SIZE):0] head_w;
logic [$clog2(QUEUE_SIZE):0] tail_r;
logic [$clog2(QUEUE_SIZE):0] tail_w;
`endif

uc_queue uc_queue (
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .uca2ucq(uca2ucq),
    .empty(empty),
    .full(full),
    .ucq2eng(ucq2eng)

    `ifdef DEBUG
    ,.entry_r(entry_r)
    ,.entry_w(entry_w)
    ,.head_r(head_r)
    ,.head_w(head_w)
    ,.tail_r(tail_r)
    ,.tail_w(tail_w)
    `endif
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

task push_data(input int d);
    push    = 1;
    uca2ucq = d;
    @(negedge clk);
    push = 0;
    uca2ucq = 0;
endtask

task pop_data();
    pop = 1;
    @(negedge clk);
    pop = 0;
endtask

initial begin
    clk     = 0;
    push    = 0;
    pop     = 0;
    uca2ucq = 0;
    reset_sys();

    @(negedge clk);
    push_data(2);
    
    @(negedge clk);
    push_data(4);

    @(negedge clk);
    push_data(6);

    @(negedge clk);
    push_data(8);

    @(negedge clk);
    push_data(10);

    @(negedge clk);
    pop_data();

    repeat(5) begin
        @(negedge clk);
    end

    $finish;
end

endmodule