real PERIOD = 10.0;

module tb_gst();

    logic clk;
    logic rst_n;

    // Global State Table <-> BCP Engine
    cla_t                         bcp2gst_curr_cla;
    logic                         bcp2gst_curr_cla_valid;
    bcp_state_t [`NUM_ENGINE-1:0] bcp2gst_curr_state;
    lit_state_t [`CLA_LENGTH-1:0] gst2bcp_lit_state;
    logic       [`NUM_ENGINE-1:0] gst2bcp_update_finish;

    // UC Arbiter <-> Global State Table
    lit_t ucarb2gst_lit;
    logic gst2ucarb_pop;
    logic ucarb2gst_empty;

    // Intermediates
    lit_t lit_a;
    lit_t lit_b;
    lit_t lit_c;

gst gst(
    .clk(clk),
    .rst_n(rst_n),

    // Global State Table <-> BCP Engine
    .bcp2gst_curr_cla(bcp2gst_curr_cla),
    .bcp2gst_curr_cla_valid(bcp2gst_curr_cla_valid),
    .bcp2gst_curr_state(bcp2gst_curr_state),
    .gst2bcp_lit_state(gst2bcp_lit_state),
    .gst2bcp_update_finish(gst2bcp_update_finish),

    // UC Arbiter <-> Global State Table
    .ucarb2gst_lit(ucarb2gst_lit),
    .ucarb2gst_empty(ucarb2gst_empty),
    .gst2ucarb_pop(gst2ucarb_pop)
);

always begin
    #(PERIOD/2);
    clk = ~clk;
end

task reset_sys();
    // Toggle reset
    rst_n = 1; 
    @(negedge clk);
    rst_n = 0; 
endtask

task update_lit(int lit);
    @(negedge clk);
    bcp2gst_curr_cla_valid = 1;
    bcp2gst_curr_state     = BCP_DONE;
    ucarb2gst_lit          = lit;
endtask

task clause_lookup(
    lit_t a, 
    lit_t b, 
    lit_t c
);
    @(negedge clk);
    bcp2gst_curr_cla_valid = 1;
    bcp2gst_curr_state = BCP_PROC;
    // for (int i=0; i<`CLA_LENGTH; i++) begin
    //     bcp2gst_curr_cla[i] = a
    // end
    bcp2gst_curr_cla   = {a, b, c};
endtask

initial begin
    clk = 0;
    bcp2gst_curr_cla = 0;
    bcp2gst_curr_cla_valid = 0;
    bcp2gst_curr_state = BCP_IDLE;
    ucarb2gst_empty = 0;
    reset_sys();

    repeat(5) begin
        @(negedge clk);
    end

    update_lit(3);
    update_lit(4);
    update_lit(5);

    @(negedge clk);
    ucarb2gst_empty = 1;

    @(negedge clk);
    lit_a = 3;
    lit_b = 4;
    lit_c = 5;
    clause_lookup(lit_a, lit_b, lit_c);

    repeat(5) begin
        @(negedge clk);
    end
    $finish;

end

endmodule