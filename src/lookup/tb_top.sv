real PERIOD = 10.0;

import "DPI-C" function void init_cnf_input_file(string file_path);
import "DPI-C" function void init_trace_input_file(string file_path);
import "DPI-C" function int output_num_of_engine();
import "DPI-C" function int output_num_of_clause_per_engine();
import "DPI-C" function int output_num_of_padding();
import "DPI-C" function int output_num_of_var();
import "DPI-C" function int output_num_of_lit_per_clause();
import "DPI-C" function void skip_engine_num_head_node_string();
import "DPI-C" function int output_num_of_clause();
import "DPI-C" function int output_number();
import "DPI-C" function int output_iter_trace();
import "DPI-C" function void skip_model_trace();
import "DPI-C" function int output_init_uc_trace();
import "DPI-C" function int output_num_of_clause_trace();
import "DPI-C" function int output_bcp_result();
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
logic          stall;

lit_t       mem2uca;
logic       mem2uca_done;
logic       mem2uca_valid;

logic mstack_pop;
logic mstack_empty;
lit_t mstack_lit;

integer clk_cnt;

node_t [`TOTAL_CLAUSE-1] latency_buffer_clq;
dummy_ptr_t [`NUM_ENGINE-1:0] header;

lit_t  queue_init_uc[$];
lit_t  queue_result[$];

lit_t [`MAX_ITER-1] init_uc;

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
    .stall(stall),

    
    .mstack_pop(mstack_pop),
    .mstack_empty(mstack_empty),
    .mstack_lit(mstack_lit)
);

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

int num_of_engine;
int num_of_clause_per_engine;
int num_of_var;
int num_of_lit_per_clause;
int tmp;
int idx = 0;
task import_data_to_latency_buffer();

    init_cnf_input_file("/home/boray/eecs570/eecs570_final/data/preprocessed_data/preprocessed-vars-100-1.cnf");
    num_of_engine = output_num_of_engine();
    num_of_clause_per_engine = output_num_of_clause_per_engine();
    num_of_var = output_num_of_var();
    num_of_lit_per_clause = output_num_of_lit_per_clause();

    for(int i=0; i<num_of_engine; ++i) begin
        skip_engine_num_head_node_string();
        header[i][0] = -1;
        for(int j=1; j<=`LIT_IDX_MAX; ++j) begin // Positive
            //retrieve header
            if(j<=num_of_var) begin
                tmp = output_number(); //var
                header[i][j] = output_number(); //pointer
            end
            else begin
                header[i][j] = -1;
            end
        end
        for(int j=`LIT_IDX_MAX+1; j<=2*`LIT_IDX_MAX; ++j) begin // Negative
            //retrieve header
            if(j<=`LIT_IDX_MAX + num_of_var) begin
                tmp = output_number(); //var
                header[i][j] = output_number(); //pointer
            end
            else begin
                header[i][j] = -1;
            end
        end
        for(int j=0; j<num_of_clause_per_engine; ++j) begin //retrieve clq
            for(int k=0; k<num_of_lit_per_clause; ++k) begin
                latency_buffer_clq[idx].cla[k] = output_number(); //var
                latency_buffer_clq[idx].ptr[k] = output_number(); //pointer
            end
            idx++;
        end
    end

endtask

task import_CLQ_to_engine();
    
    for(int i=0; i<num_of_clause_per_engine * num_of_engine; ++i) begin
        @(negedge clk);
        node_in_valid = 1;
        node_in       = latency_buffer_clq[i];
        if (i != 0 && i%num_of_clause_per_engine == 0) begin
            change_eng = 1;
        end
        else begin
            change_eng = 0;
        end
    end
    node_in_valid = 0;

endtask

task import_header_to_engine();
    for(int j = 0; j < `NUM_ENGINE; j++) begin
        for(int i=0; i<`LIT_IDX_MAX*2+1; ++i) begin
            @(negedge clk);
            dummy_ptr = header[j][i];
            dummy_ptr_valid = 1;
        end
    end
    @(negedge clk);
    dummy_ptr_valid = 0;
endtask

int num;
int max_iter=0;
int uc_idx = 0;
task uc_handler();
    logic prev_stall = 0;
    @(negedge clk);
    halt = 0;
    while(uc_idx < max_iter) begin
        @(negedge clk);
        if(stall & prev_stall==0) begin
            mem2uca = init_uc[uc_idx];
            mem2uca_done  = 1;
            mem2uca_valid = 1;
            uc_idx++;
        end
        else begin
            mem2uca_done  = 0;
            mem2uca_valid = 0;
            mem2uca = 0;
        end
        prev_stall = stall;
    end
endtask

task import_trace_to_buffer();
    init_trace_input_file("/home/boray/eecs570/eecs570_final/data/sat_trace/bcp_trace_vars-100-1.out");
    for(int i=0; i<`MAX_ITER; ++i) begin
        
        // output_iter_trace
        num = output_init_uc_trace();
        $display("Trace iter trace %d, num = %d", i, num);
        if(num == -1) begin
            break;
        end
        init_uc[i]  = num;
        // queue_init_uc.push_back(num);
        // skip_model_trace();
        max_iter++;
    end
    $display("max_iter: %d",max_iter);
endtask

always begin
    clk = ~clk;
    #(PERIOD/2);
    if (clk) begin
        clk_cnt = clk_cnt + 1;
        if(!mstack_empty) begin
            mstack_pop = 1;
            queue_result.push_back(mstack_lit);
        end
        else mstack_pop = 0;
    end
end

initial begin
    clk = 0;
    clk_cnt = 0;
    rst_n = 1;
    halt = 1;
    mem2uca_done = 0;
    mem2uca_valid = 0;
    import_data_to_latency_buffer();
    import_trace_to_buffer();
    @(negedge clk);
    rst_n = 0;
    fork
        import_CLQ_to_engine();
        import_header_to_engine();    
    join
    uc_handler();
    $finish;
end

endmodule