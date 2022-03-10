#include "test_uc_queue_arbiter.h"

test_uc_queue_arbiter::test_uc_queue_arbiter(const sc_module_name& ){
    
    uc_queue_arbiter_1->input_from_latency_buffer_port(test_input_from_latency_buffer);
    // uc_queue_arbiter_1->input_from_clause_queue(test_input_from_clause_fifo);
    // uc_queue_arbiter_1->output_to_clause_queue(test_output_to_clause_fifo);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        uc_queue_arbiter_1->input_from_clause_engine_fifo_port(test_input_from_clause_fifo[i]);
        uc_queue_arbiter_1->output_to_clause_engine_fifo_port(test_output_to_clause_fifo[i]);
    }
    
    test_input_from_latency_buffer.write(-1);
    // test_input_from_clause_fifo.write(2);
    test_input_from_clause_fifo[0].write(3);
    test_input_from_clause_fifo[1].write(4);
    

    golden_output_unit_clause_number = 2;
    golden_unit_clause_output_engine[0] = -1;
    golden_unit_clause_output_engine[1] = 3;
    
    SC_THREAD(test_uc_arbiter);
}

void test_uc_queue_arbiter::test_uc_arbiter()
{
    // uc_queue_arbiter_1->unit_clause_latency_data_finish.notify();
    for(int i=0; i<NUMBER_OF_ENGINE; ++i)
        uc_queue_arbiter_1->engine_finish_each_unit_clause_event[i].notify();

    
    

    int res;
    for(int i=0; i<golden_output_unit_clause_number; ++i){
        res = test_output_to_clause_fifo[0].read();
        if(res != golden_unit_clause_output_engine[i]){
            cout<<"Test Fail on uc_queue_arbiter engine_1, test unit clause ["<<i<<"], output value : "<<res<<", golden value : "<<golden_unit_clause_output_engine[i]<<endl;
            exit(-1);
        }
    }

    for(int i=0; i<golden_output_unit_clause_number; ++i){
        res = test_output_to_clause_fifo[1].read();
        if(res != golden_unit_clause_output_engine[i]){
            cout<<"Test Fail on uc_queue_arbiter engine_2, test unit clause ["<<i<<"], output value : "<<res<<", golden value : "<<golden_unit_clause_output_engine[i]<<endl;
            exit(-1);
        }
    }
    cout<<"uc_queue_arbiter testing ...... OK"<<endl;
}
