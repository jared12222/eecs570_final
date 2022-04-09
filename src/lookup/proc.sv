module proc (
    input  logic   clk,
    input  logic   rst_n,
    input  logic   proc_halt,
    
    // Carb <-> CLQ
    input  node_t      carb2clq_node_in,
    input  logic       carb2clq_push,
    input  dummy_ptr_t carb2bcp_dummies,
    input  logic       carb2bcp_dummies_valid,

    // UCarb <-> UCQ_out
    input  logic ucarb2UCQ_out_push,
    input  lit_t ucarb2UCQ_out_uc,
    output logic UCQ_out_full,

    // UCarb <-> UCQ_in
    input  logic ucarb2UCQ_in_pop,
    output lit_t UCQ_in2uarb_uc,
    output logic UCQ_in_empty,

    output logic conflict
);

// Wait till carb has fully written everything to CLQ
logic  bcp_halt;

// Global State Table (inside CLQ) <-> BCP engine
cla_t       bcp2gst_curr_cla;
logic       bcp2gst_curr_cla_valid;
bcp_state_t bcp2gst_curr_state;
lit_state_t [`CLA_LENGTH-1:0] gst2bcp_lit_state;

// BCP <-> UCQ_in implication (unit clause)
logic bcp2UCQ_in_valid;
lit_t bcp2UCQ_in_uc;

// UCQ_in
logic UCQ_in_full;

// UCQ_out <-> BCP
lit_t UCQ_out2eng_uc;

// CLQ <-> BCP
ptr_t  bcp2CLQ_ptr;
ptr_t  clq2bcp_init_ptr;
node_t clq2bcp_node_out;

assign bcp_halt = UCQ_in_full | proc_halt;

bcp_pe bcp_pe(
    .clk(clk),
    .rst_n(rst_n),

    // CLQ <-> BCP engine
    .clq2bcp_init_ptr(clq2bcp_init_ptr),
    .clq2bcp_init_ptr_valid(clq2bcp_init_ptr_valid),
    .node(clq2bcp_node_out),
    .node_ptr(bcp2CLQ_ptr),

    // Ucarb <-> BCP engine
    .ucarb2bcp_newLit(UCQ_out2eng_uc),
    .ucarb2bcp_newLitValid(!UCQ_out_empty),
    .bcp2ucarb_newLitAccept(eng2UCQ_out_pop),
    
    // CArb <-> BCP engine
    // Wait till carb has fully written everything to CLQ
    .halt(bcp_halt),

    // Global State Table <-> BCP engine
    .bcp2gst_curr_cla(bcp2gst_curr_cla),
    .bcp2gst_curr_cla_valid(bcp2gst_curr_cla_valid),
    .bcp2gst_curr_state(bcp2gst_curr_state),
    .gst2bcp_lit_state(gst2bcp_lit_state),

    // implication (unit clause)
    .imply_valid(bcp2UCQ_in_valid),
    .imply_lit(bcp2UCQ_in_uc),

    .conflict(conflict)
);

cla_queue #(
    .DEPTH(`CLQ_DEPTH)
)
CLQ (
    .clk(clk),
    .rst_n(rst_n),

    // Carb <-> CLQ
    .carb2clq_node_in(carb2clq_node_in),
    .carb2clq_push(carb2clq_push),
    .carb2bcp_dummies(carb2bcp_dummies),
    .carb2bcp_dummies_valid(carb2bcp_dummies_valid),

    // UCarb (UCQ_OUT) <-> CLQ
    .ucarb2clq_uc_rqst(UCQ_out2eng_uc),
    .ucarb2clq_uc_rqst_valid(!UCQ_out_empty),

    // CLQ <-> BCP engine
    .bcp2clq_cnf_idx(bcp2CLQ_ptr),
    .clq2bcp_init_ptr(clq2bcp_init_ptr),
    .clq2bcp_init_ptr_valid(clq2bcp_init_ptr_valid),
    .clq2bcp_node_out(clq2bcp_node_out)
);

queue #(
    .DATA_LEN(`LIT_IDX_MAX*2),
    .QUEUE_SIZE(`UCQ_SIZE)
)
UCQ_in(
    .clk(clk),
    .rst(rst_n),
    .push(bcp2UCQ_in_valid),
    .pop(ucarb2UCQ_in_pop),
    .data(bcp2UCQ_in_uc),
    .empty(UCQ_in_empty),
    .full(UCQ_in_full),
    .qout(UCQ_in2uarb_uc)
);

queue #(
    .DATA_LEN(`LIT_IDX_MAX*2),
    .QUEUE_SIZE(`UCQ_SIZE)
)
UCQ_out(
    .clk(clk),
    .rst(rst_n),
    .push(ucarb2UCQ_out_push),
    .pop(eng2UCQ_out_pop),
    .data(ucarb2UCQ_out_uc),
    .empty(UCQ_out_empty),
    .full(UCQ_out_full),
    .qout(UCQ_out2eng_uc)
);

endmodule