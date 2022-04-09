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

logic       latency_buffer_header_node
logic       latency_buffer_clq


node_t [`TOTAL_CLAUSE-1] latency_buffer_clq;
logic [$clog2(`CLQ_DEPTH):0] header [NUM_CLAUSE-1:0][$clog2(`LIT_IDX_MAX):0];  

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

int num_of_engine;
int num_of_padding;
int num_of_var;
int num_of_lit_per_clause;
int tmp;
int num_clause_per_engine;
int idx = 0;
task import_data_to_latency_buffer();

    init_cnf_input_file("../../data/preprocessed_data/preprocessed-vars-100-1.cnf");
    num_of_engine = output_num_of_engine();
    num_of_padding = output_num_of_padding();
    num_of_var = output_num_of_var();
    num_of_lit_per_clause = output_num_of_lit_per_clause();

    for(int i=0; i<num_of_engine; ++i){
        skip_engine_num_head_node_string();
        for(int j=0; j<num_of_var * 2; ++j){ //retrieve header
            tmp = output_number(); //var
            header[i][j] = output_number(); //pointer
        }
        num_clause_per_engine = output_num_of_clause();
        for(int j=0; j<num_clause_per_engine; ++j){ //retrieve clq
            for(int k=0; k<num_of_lit_per_clause; ++k){
                latency_buffer_clq[idx].cla = output_number(); //var
                latency_buffer_clq[idx].ptr = output_number(); //pointer
            }
            idx++;
        }
    }

endtask


endmodule