real PERIOD = 10.0;

module tb();

logic          clk;
logic          rst_n;
logic          halt;
node_t         node_in;
logic          node_in_valid;
logic          change_eng;
dummy_entry_t  dummy_ptr;
logic          dummy_ptr_valid;
logic          conflict;

lit_t       mem2uca;
logic       mem2uca_done;
logic       mem2uca_valid;

logic mstack_pop;
logic mstack_empty;
lit_t mstack_lit;

integer clk_cnt;

logic       latency_buffer_header_node
logic       latency_buffer_clq


node_t [`TOTAL_CLAUSE-1] latency_buffer_clq;
logic [$clog2(`CLQ_DEPTH):0] header [NUM_CLAUSE-1:0][$clog2(`LIT_IDX_MAX):0];  

top DUT(
    .clk(clk),
    .rst_n(rst_n),
    .halt(halt),
    .node_in(node_in),
    .node_in_valid(node_in_valid),
    .change_eng(change_eng),
    .dummy_ptr(dummy_ptr),
    .dummy_ptr_valid(dummy_ptr_valid),

    .mem2uca(mem2uca),
    .mem2uca_done(mem2uca_done),
    .mem2uca_valid(mem2uca_valid),
    .conflict(conflict),

    
    .mstack_pop(mstack_pop),
    .mstack_empty(mstack_empty),
    .mstack_lit(mstack_lit)
);

node_t nodes_queue[`NUM_ENGINE][$];

task rst_task();
    // Signal Initialization
    clk     = 0;
    rst_n   = 1;
    halt    = 1;
    node_in = 0;
    node_in_valid = 0;
    change_eng = 0;
    dummy_ptr = 0;
    dummy_ptr_valid = 0;
    mem2uca_done  = 0;
    mem2uca_valid = 0;
    mstack_pop = 0;

    @(negedge clk);
    rst_n = 0;
endtask

always begin
    clk = ~clk;
    #(PERIOD/2);
    if (clk) begin
        clk_cnt = clk_cnt + 1;
    end
end

initial begin
    clk = 0;
    clk_cnt = 0;
    rst_n = 1;
    $finish;
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