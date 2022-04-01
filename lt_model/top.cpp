#include "top.h"

top::top(const sc_module_name& )
// :clk("clk", 1, SC_NS, 0.5)
{   
    
    // reset output file
    ofstream output_file;
    output_file.open(output_file_path, ofstream::out | ofstream::trunc);
    if(!output_file.is_open()){
        cout<<"Output file open fail in the beginning of print_all_engine_input_clause_fifo"<<endl;
        exit(-1);
    }
    output_file.close();
    
    done_with_clause_signal.init(NUMBER_OF_ENGINE);
    done_with_unit_clause_signal.init(NUMBER_OF_ENGINE);
    conflict_signal.init(1);

    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        engine_output_unit_clause_fifo[i] = new sc_fifo<int >(NUMBER_OF_CLAUSE/NUMBER_OF_ENGINE);
        engine_input_unit_clause_fifo[i] = new sc_fifo<int >(NUMBER_OF_VAR_KIND);
        engine_input_clause_fifo[i] = new sc_fifo<sc_bv<CAUSE_WIDTH> >(NUMBER_OF_CLAUSE/NUMBER_OF_ENGINE);
        switch_input_from_engine_clause_fifo[i] = new sc_fifo<sc_bv<CAUSE_WIDTH> >(1);
        switch_input_from_latency_clause_fifo[i] = new sc_fifo<sc_bv<CAUSE_WIDTH> >(1);
    }
    unit_clause_latency_buffer = new sc_fifo<int >(1);
    latency_buffer = new sc_fifo<sc_bv<CAUSE_WIDTH> >(NUMBER_OF_CLAUSE);

    read_data_to_latency_buffer();

    controller_1 = new controller("controller_1");  
    controller_1->conflict_in_uc_arbiter_port(conflict_signal[0]);
    controller_1->clk(clk);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        controller_1->clause_engine_done_with_unit_clause_port[i](done_with_unit_clause_signal[i]);
        controller_1->clause_engine_done_with_clause_port[i](done_with_clause_signal[i]);
    }

    string clause_engine_name = "clause_engine";
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        clause_engine_1[i] = new clause_engine("clause_engine");
        clause_engine_1[i]->input_from_unit_clause_fifo_port(*engine_input_unit_clause_fifo[i]);
        clause_engine_1[i]->input_from_clause_fifo_port(*engine_input_clause_fifo[i]);
        clause_engine_1[i]->output_to_unit_clause_fifo_port(*engine_output_unit_clause_fifo[i]);
        clause_engine_1[i]->output_to_clause_fifo_port(*switch_input_from_engine_clause_fifo[i]);
        clause_engine_1[i]->clk(clk);
        clause_engine_1[i]->clause_engine_done_with_clause_port(done_with_clause_signal[i]);
        clause_engine_1[i]->clause_engine_done_with_unit_clause_port(done_with_unit_clause_signal[i]);
    }
    string clause_switch_name = "clause_switch";
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        clause_switch_1[i] = new clause_switch( "clause_switch");
        clause_switch_1[i]->input_from_latency_buffer_port(*switch_input_from_latency_clause_fifo[i]);
        clause_switch_1[i]->input_from_engine_port(*switch_input_from_engine_clause_fifo[i]);
        clause_switch_1[i]->output_to_clause_fifo_port(*engine_input_clause_fifo[i]);
        clause_switch_1[i]->clk(clk);
    }
    
    uc_queue_arbiter_1 = new uc_queue_arbiter("uc_queue_arbiter_1");
    uc_queue_arbiter_1->input_from_latency_buffer_port(*unit_clause_latency_buffer);
    uc_queue_arbiter_1->clk(clk);
    uc_queue_arbiter_1->conflict_in_uc_arbiter_port(conflict_signal[0]);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        uc_queue_arbiter_1->input_from_clause_engine_fifo_port(*engine_output_unit_clause_fifo[i]);
        uc_queue_arbiter_1->output_to_clause_engine_fifo_port(*engine_input_unit_clause_fifo[i]);
    }
    latency_buffer_arbiter_1 = new latency_buffer_arbiter("latency_buffer_arbiter_1");
    latency_buffer_arbiter_1->input_from_latency_buffer_port(*latency_buffer);
    latency_buffer_arbiter_1->clk(clk);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        latency_buffer_arbiter_1->output_to_clause_fifo_port(*switch_input_from_latency_clause_fifo[i]);
    }
    

    // SC_THREAD(egnine_notify_uc_arbiter);
    SC_THREAD(top_compute);
    sensitive<<clk.neg();
}

void top::top_compute(){
    int i = 0;
    while(1){
        wait();


        if(controller_1->conflict_flag){
            cout<<"Conflict detected !"<<endl;
            cout<<"Cycle = "<<sc_time_stamp().to_default_time_units ()<<endl;
            print_all_engine_input_clause_fifo();
            sc_stop();
        }else if(controller_1->done_with_unit_clause_flag){
            cout<<"Unit clause fifo empty detected !"<<endl;
            cout<<"Cycle = "<<sc_time_stamp().to_default_time_units ()<<endl;
            print_all_engine_input_clause_fifo();
            sc_stop();
        }else if(controller_1->done_with_clause_flag){
            cout<<"Clause fifo empty detected !"<<endl;
            cout<<"Cycle = "<<sc_time_stamp().to_default_time_units ()<<endl;
            print_all_engine_input_clause_fifo();
            sc_stop();
        }

        // if(i == 5){
        //     if(controller_1->conflict_flag){
        //         cout<<"Conflict detected !"<<endl;
        //         cout<<sc_time_stamp()<<endl;
        //         print_all_engine_input_clause_fifo();
        //         sc_stop();
        //     }else if(controller_1->done_with_unit_clause_flag){
        //         cout<<"Done with uc detected !"<<endl;
        //         cout<<sc_time_stamp()<<endl;
        //         print_all_engine_input_clause_fifo();
        //         sc_stop();
        //     }else if(controller_1->done_with_clause_flag){
        //         cout<<"Done with c detected !"<<endl;
        //         cout<<sc_time_stamp()<<endl;
        //         print_all_engine_input_clause_fifo();
        //         sc_stop();
        //     }
        // }
        // if(controller_1->conflict_flag){
        //         cout<<"Conflict detected !"<<endl;
        //         cout<<sc_time_stamp()<<endl;
        //         print_all_engine_input_clause_fifo();
        //         sc_stop();
        //     }
        
        // if(i<10){
        //     print_engine_input_clause_fifo(0);
        //     // sc_stop();
        // }
        // i++;
        //print_all_engine_input_clause_fifo();
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
    
    unit_clause_latency_buffer->write(unit_clause);
    
    input_file>>num_var_per_clause;
    input_file>>num_clause;

    int var;
    sc_bv<CAUSE_WIDTH> clause;

    for(int i=0; i<NUMBER_OF_ENGINE; ++i)
        latency_buffer->write(0);

    for(int i=0; i<num_clause; ++i){
        for(int j=0; j<num_var_per_clause; ++j){
            input_file>>var;
            clause.range((j+1)*WIDTH_PER_VAR-1, j*WIDTH_PER_VAR) = var;
        }
        latency_buffer->write(clause);
    }
    input_file.close();
}

void top::print_engine_input_clause_fifo(int engine_number){
    
    ofstream output_file;

    output_file.open(output_file_path, ofstream::out | ofstream::app);
    if(!output_file.is_open()){
        cout<<"Output file open fail"<<endl;
        exit(-1);
    }

    output_file<<"***************** Engine["<<engine_number<<"] *****************"<<endl<<endl;
    output_file<<"Cycle = "<<sc_time_stamp().to_default_time_units ()<<endl;
    output_file<<"engine["<<engine_number<<"], engine_output_unit_clause_fifo"<<endl;
    engine_output_unit_clause_fifo[engine_number]->print(output_file);
    output_file<<"engine["<<engine_number<<"], engine_input_unit_clause_fifo"<<endl;
    engine_input_unit_clause_fifo[engine_number]->print(output_file);
    output_file<<"engine["<<engine_number<<"], engine_input_clause_fifo"<<endl;
    engine_input_clause_fifo[engine_number]->print(output_file);
    output_file<<"engine["<<engine_number<<"], switch_input_from_engine_clause_fifo"<<endl;
    switch_input_from_engine_clause_fifo[engine_number]->print(output_file);
    output_file<<"engine["<<engine_number<<"], switch_input_from_latency_clause_fifo"<<endl;
    switch_input_from_latency_clause_fifo[engine_number]->print(output_file);

    output_file<<"unit clause latency buffer"<<endl;
    unit_clause_latency_buffer->print(output_file);
    output_file<<"latency buffer"<<endl;
    latency_buffer->print(output_file);
    output_file<<endl<<"*********************************************"<<endl<<endl;
    output_file.close();
}

void top::print_all_engine_input_clause_fifo(){

    for (int i=0; i<NUMBER_OF_ENGINE; ++i){
        print_engine_input_clause_fifo(i);
    }
    
}

void top::egnine_notify_uc_arbiter(){
    while(1){
        wait(clause_engine_1[0]->engine_finish_each_unit_clause_event);
        uc_queue_arbiter_1->engine_finish_each_unit_clause_event[0].notify();
    }
}