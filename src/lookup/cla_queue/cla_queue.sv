module cla_queue(
    input clk,
    input rst_n,

    // Write ports
    input list_t list_in,
    input push,

    // State output
    output logic full,

    // Access I/O
    input [depth-1:0] idx,
    output list_t entry_out
);
    parameter depth = 10;
    logic [$clog2(depth):0] tail;
    
    list_t [depth-1:0] buffer;

    assign full  =  tail == depth &&
                    tail[$clog2(depth)];
    
    assign entry_out = buffer[idx];
    
    always_ff @(posedge clk) begin
        if(rst_n) begin
            buffer <= 'b0;
            tail <= 'b0;
        end
        else begin
            if (push && !full) begin
                buffer[tail[$clog2(depth)-1:0]] <= list_in;
                tail <= tail + 1;
            end
        end
    end
endmodule