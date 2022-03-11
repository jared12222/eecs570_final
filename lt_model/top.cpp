#include "top.h"

top::top(const sc_module_name& )
:clk("clk", 10, SC_SEC, 0.2, 10, SC_SEC, false)
{
    read_data_to_latency_buffer();
    string clause_engine_name = "clause_engine";
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        clause_engine_1[i] = new clause_engine("clause_engine");
        clause_engine_1[i]->input_from_unit_clause_fifo_port(engine_input_unit_clause_fifo[i]);
        clause_engine_1[i]->input_from_clause_fifo_port(engine_input_clause_fifo[i]);
        clause_engine_1[i]->output_to_unit_clause_fifo_port(engine_output_unit_clause_fifo[i]);
        clause_engine_1[i]->output_to_clause_fifo_port(switch_input_from_engine_clause_fifo[i]);
        clause_engine_1[i]->clk(clk);
    }
    string clause_switch_name = "clause_switch";
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        clause_switch_1[i] = new clause_switch( "clause_switch");
        clause_switch_1[i]->input_from_latency_buffer_port(switch_input_from_latency_clause_fifo[i]);
        clause_switch_1[i]->input_from_engine_port(switch_input_from_engine_clause_fifo[i]);
        clause_switch_1[i]->output_to_clause_fifo_port(engine_input_clause_fifo[i]);
        clause_switch_1[i]->clk(clk);
    }
    
    uc_queue_arbiter_1 = new uc_queue_arbiter("uc_queue_arbiter_1");
    uc_queue_arbiter_1->input_from_latency_buffer_port(unit_clause_latency_buffer);
    uc_queue_arbiter_1->clk(clk);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        uc_queue_arbiter_1->input_from_clause_engine_fifo_port(engine_output_unit_clause_fifo[i]);
        uc_queue_arbiter_1->output_to_clause_engine_fifo_port(engine_input_unit_clause_fifo[i]);
    }
    latency_buffer_arbiter_1 = new latency_buffer_arbiter("latency_buffer_arbiter_1");
    latency_buffer_arbiter_1->input_from_latency_buffer_port(latency_buffer);
    latency_buffer_arbiter_1->clk(clk);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        latency_buffer_arbiter_1->output_to_clause_fifo_port(switch_input_from_latency_clause_fifo[i]);
    }
    

    // SC_THREAD(egnine_notify_uc_arbiter);
    SC_CTHREAD(top_compute, clk);
    //sensitive<<clk.pos();
}

void top::top_compute(){
    int i=20;
    while(i-- != 0){
        wait();
        if(i==1){
            print_engine_input_clause_fifo(0);
            sc_stop();
        }
    }
    // wait(uc_queue_arbiter_1->no_data_in_queue);
    // print_engine_input_clause_fifo(0);
}

void top::read_data_to_latency_buffer(){
    ifstream input_file;

    input_file.open(input_file_path, ifstream::in);
    if(!input_file.is_open()){
        cout<<"Input file open fail"<<endl;
        exit(-1);
    }
    int num_var_per_clause;
    int num_clause;
    int unit_clause;

    input_file>>unit_clause;
    unit_clause_latency_buffer.write(unit_clause);

    input_file>>num_var_per_clause;
    input_file>>num_clause;

    int var;
    sc_bv<CAUSE_WIDTH> clause;

    for(int i=0; i<num_clause; ++i){
        for(int j=0; j<num_var_per_clause; ++j){
            input_file>>var;
            clause.range((j+1)*WIDTH_PER_VAR-1, j*WIDTH_PER_VAR) = var;
        }
        latency_buffer.write(clause);
    }
    input_file.close();
}

void top::print_engine_input_clause_fifo(int engine_number){
    cout<<"engine["<<engine_number<<"], engine_output_unit_clause_fifo"<<endl;
    engine_output_unit_clause_fifo[engine_number].print();
    cout<<"engine["<<engine_number<<"], engine_input_unit_clause_fifo"<<endl;
    engine_input_unit_clause_fifo[engine_number].print();
    cout<<"engine["<<engine_number<<"], engine_input_clause_fifo"<<endl;
    engine_input_clause_fifo[engine_number].print();
    cout<<"engine["<<engine_number<<"], switch_input_from_engine_clause_fifo"<<endl;
    switch_input_from_engine_clause_fifo[engine_number].print();
    cout<<"engine["<<engine_number<<"], switch_input_from_latency_clause_fifo"<<endl;
    switch_input_from_latency_clause_fifo[engine_number].print();

    cout<<"unit clause latency buffer"<<endl;
    unit_clause_latency_buffer.print();
    cout<<"latency buffer"<<endl;
    latency_buffer.print();
}

void top::egnine_notify_uc_arbiter(){
    while(1){
        wait(clause_engine_1[0]->engine_finish_each_unit_clause_event);
        uc_queue_arbiter_1->engine_finish_each_unit_clause_event[0].notify();
    }
}