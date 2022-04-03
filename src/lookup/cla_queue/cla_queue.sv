module cla_queue #(
    parameter DEPTH = 16
)(
    input clk,
    input rst_n,

    // Write ports
    input node_t node_in,
    input push,

    // State output
    output logic full,

    // Carb <-> CLQ
    input  dummy_ptr_t carb2bcp_dummies,
    input  logic       carb2bcp_dummies_valid,

    // Access I/O
    input ptr_t idx,
    output node_t     node_out
);
    logic [$clog2(DEPTH):0] tail;
    
    node_t      [DEPTH-1:0] buffer;
    dummy_ptr_t             head_nodes;

    assign full  =  tail == DEPTH &&
                    tail[$clog2(DEPTH)];
    
    assign node_out = buffer[idx];
    
    always_ff @(posedge clk) begin
        if(rst_n) begin
            buffer <= 'b0;
            tail   <= 'b0;
            for (int i=0; i<2*`LIT_IDX_MAX; i++)begin
                head_nodes = 'b0;
            end
        end
        else begin
            if (push && !full) begin
                buffer[tail[$clog2(DEPTH)-1:0]] <= node_in;
                tail <= tail + 1;
            end
            if (carb2bcp_dummies_valid) begin
                head_nodes <= carb2bcp_dummies;
            end
            else begin
                head_nodes <= head_nodes;
            end
        end
    end
endmodule