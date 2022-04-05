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
    
    logic [$clog2(`LIT_IDX_MAX)-2:0] uc_idx;
    logic                            uc_polarity;

    // Distributed CNF and dummy head node data structure
    node_t      [DEPTH-1:0] buffer;
    dummy_ptr_t             head_nodes;

    // Send CNF entry to BCP engine
    assign node_out = buffer[idx];

    assign uc_polarity = ucarb2clq_uc_rqst[$clog2(`LIT_IDX_MAX)];
    assign uc_idx = uc_polarity? 
        ~ucarb2clq_uc_rqst[$clog2(`LIT_IDX_MAX)-1:0] + 1 : 
         ucarb2clq_uc_rqst[$clog2(`LIT_IDX_MAX)-1:0];

    // Query for dummy head position
    always_comb begin
        clq2bcp_init_ptr = 'b0;
        clq2bcp_init_ptr_valid = 'b0;

        if(ucarb2clq_uc_rqst_valid) begin
            clq2bcp_init_ptr = head_nodes[uc_idx + uc_polarity*LIT_IDX_MAX];
            clq2bcp_init_ptr_valid = 'b1;
        end
    end

    always_ff @(posedge clk) begin
        if(rst_n) begin
            buffer <= 'b0;
            tail   <= 'b0;
            for (int i=0; i<2*`LIT_IDX_MAX; i++)begin
                head_nodes = 'b0;
            end
        end
        else begin
            if (push) begin
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