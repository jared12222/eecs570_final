`define DEPTH 16
`define PERIOD 10

module tb_fifo();
    
    logic clk;
    logic rst_n;
    cla_t cla_in;
    logic push;
    logic pop;
    logic full;
    logic empty;
    cla_t cla_out;
    
    cla_queue #(.depth(`DEPTH)) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .cla_in(cla_in),
        .push(push),
        .pop(pop),

        .full(full),
        .empty(empty),
        .cla_out(cla_out)
    );

    task reset();
        rst_n = 1;
        push = 0;
        pop = 0;
    endtask

    task only_push(input cla_t in);
        rst_n = 0;
        cla_in = in;
        push = 1;
        pop <= 0;
    endtask
    
    task only_pop();
        rst_n = 0;
        push = 0;
        pop = 1;
    endtask

    task push_pop(input cla_t in);
        rst_n = 0;
        cla_in = in;
        push = 1;
        pop = 1;
    endtask

    task printstate();
        $write("--------------\n");
        $write("(Full, Empty): %b %b\n", full, empty);
        $write("Head: %b %d\n", DUT.head[$clog2(`DEPTH)], DUT.head[$clog2(`DEPTH)-1:0]);
        $write("Tail: %b %d\n", DUT.tail[$clog2(`DEPTH)], DUT.tail[$clog2(`DEPTH)-1:0]);
        $write("Out: %d\n", cla_out);
        $write("\n--------------\n");
    endtask

    always begin
        #(`PERIOD/2);
        clk = ~clk;
    end

    integer i;

    initial begin
        clk = 0;
        i = 0;
        reset();
        @(negedge clk);
        printstate();

        // Push to full
        for(int j = 0; j < `DEPTH; j++) begin
            only_push(i++);
            @(negedge clk);
            printstate();
        end

        // Try to push while full, two elements will disappear from output stream
        for(int j = 0; j < 2; j++) begin
            only_push(i++);
            @(negedge clk);
            printstate();
        end

        // Try to push & pop
        for(int j = 0; j < 2; j++) begin
            push_pop(i++);
            @(negedge clk);
            printstate();
        end

        // Pop until empty
        for(int j = 0; j < `DEPTH; j++) begin
            only_pop();
            @(negedge clk);
            printstate();
        end

        // Try pop when empty
        for(int j = 0; j < 2; j++) begin
            only_pop();
            @(negedge clk);
            printstate();
        end
        
        $finish;
    end
endmodule