real PERIOD = 10.0;

module tb();

logic       clk;
logic       rst_n;
logic       halt;
node_t      carb2clq_node_in;
logic       carb2clq_push;
dummy_ptr_t carb2bcp_dummies;
logic       carb2bcp_dummies_valid;
logic       conflict;

top DUT(
    .clk(clk),
    .rst_n(rst_n),
    .halt(halt),
    .carb2clq_node_in(carb2clq_node_in),
    .carb2clq_push(carb2clq_push),
    .carb2bcp_dummies(carb2bcp_dummies),
    .carb2bcp_dummies_valid(carb2bcp_dummies_valid)
);

always begin
    clk = ~clk;
    #(PERIOD/2);
end

endmodule