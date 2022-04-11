module cla_queue #(
    parameter DEPTH = 16
)(
    input  logic clk,
    input  logic rst_n,

    // Carb <-> CLQ
    input  node_t      carb2clq_node_in,
    input  logic       carb2clq_push,
    input  dummy_ptr_t carb2bcp_dummies,
    input  logic       carb2bcp_dummies_valid,

    // UCarb (UCQ_OUT) <-> CLQ
    input  lit_t       ucarb2clq_uc_rqst,
    input  logic       ucarb2clq_uc_rqst_valid,

    // CLQ <-> BCP engine
    input  ptr_t       bcp2clq_cnf_idx,
    output ptr_t       clq2bcp_init_ptr,
    output logic       clq2bcp_init_ptr_valid,
    output node_t      clq2bcp_node_out
);
    logic [$clog2(DEPTH):0] tail;
    
    logic [$clog2(`LIT_IDX_MAX)-1:0] uc_idx;
    logic [$clog2(2*`LIT_IDX_MAX):0] entry_idx;
    logic                            uc_polarity;

    // Distributed CNF and dummy head node data structure
    node_t      [DEPTH-1:0] buffer;
    dummy_ptr_t             head_nodes, head_nodes_buffer; // [0...NUM_LIT, -1...-NUM_LIT]

    // Send CNF entry to BCP engine
    assign clq2bcp_node_out = buffer[bcp2clq_cnf_idx];

    assign uc_polarity = ucarb2clq_uc_rqst[$clog2(`LIT_IDX_MAX)];

    // Query for dummy head position
    always_comb begin
        clq2bcp_init_ptr = 'b0;
        clq2bcp_init_ptr_valid = 'b0;
        head_nodes_buffer = head_nodes;

        if(uc_polarity) begin // negative
            uc_idx = -ucarb2clq_uc_rqst;
            entry_idx = uc_idx + `LIT_IDX_MAX;
        end
        else begin
            uc_idx = ucarb2clq_uc_rqst;
            entry_idx = uc_idx;
        end

        if(ucarb2clq_uc_rqst_valid) begin
            if (head_nodes_buffer[entry_idx][$clog2(`CLQ_DEPTH)] == 0) begin
                clq2bcp_init_ptr = head_nodes_buffer[entry_idx][$clog2(`CLQ_DEPTH)-1:0];
                clq2bcp_init_ptr_valid = 'b1;
            end
            else begin
                clq2bcp_init_ptr_valid = 'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if(rst_n) begin
            buffer <= 'b0;
            tail   <= 'b0;
            for (int i=0; i<2*`LIT_IDX_MAX; i++)begin
                head_nodes <= 'b0;
            end
        end
        else begin
            if (carb2clq_push) begin
                buffer[tail[$clog2(DEPTH)-1:0]] <= carb2clq_node_in;
                tail <= tail + 1;
            end
            if (carb2bcp_dummies_valid) begin
                head_nodes <= carb2bcp_dummies;
            end
            else begin
                head_nodes <= head_nodes_buffer;
            end
        end
    end

endmodule