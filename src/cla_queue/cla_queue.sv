module cla_queue(
    input clk,
    input rst_n,
    input cla_t cla_in,
    input push,
    input pop,
    output logic full,
    output logic empty,
    output cla_t cla_out
);
    parameter depth = 10;
    logic [$clog2(depth):0] head, tail;
    
    cla_t [depth-1:0] buffer;

    assign full  =  head[$clog2(depth)-1:0] == tail[$clog2(depth)-1:0] &&
                    head[$clog2(depth)] ^ tail[$clog2(depth)];
    assign empty = head == tail;
    assign cla_out = buffer[head[$clog2(depth)-1:0]];
    
    always_ff @(posedge clk) begin
        if(rst_n) begin
            buffer <= 'b0;
            head <= 'b0;
            tail <= 'b0;
        end
        else begin
            if (push && (!full || full && pop)) begin
                buffer[tail[$clog2(depth)-1:0]] <= cla_in;
                tail <= tail + 1;
            end
            if (pop && !empty) begin
                head <= head + 1;
            end
        end
    end
endmodule