real PERIOD = 10.0;

module tb();

logic       clk;
logic       rst_n;
logic       halt;
node_t      node_in;
logic       node_in_valid;
logic       change_eng;
ptr_t       dummy_ptr;
logic       carb2bcp_dummies_valid;
logic       conflict;

top DUT(
    .clk(clk),
    .rst_n(rst_n),
    .halt(halt),
    .node_in(node_in),
    .node_in_valid(node_in_valid),
    .change_eng(change_eng)    
    .dummy_ptr(dummy_ptr),
    .dummy_ptr_valid(dummy_ptr_valid),
    .conflict(conflict)
);

always begin
    clk = ~clk;
    #(PERIOD/2);
end

initial begin
    clk = 0;
    rst_n = 1;
end

endmodule