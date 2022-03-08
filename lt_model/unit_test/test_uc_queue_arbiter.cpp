#include "test_uc_queue_arbiter.h"

test_uc_queue_arbiter::test_uc_queue_arbiter(const sc_module_name& ){
    
    uc_queue_arbiter_1->input_from_latency_buffer(test_input_from_latency_buffer);
    // uc_queue_arbiter_1->input_from_clause_queue(test_input_from_clause_fifo);
    // uc_queue_arbiter_1->output_to_clause_queue(test_output_to_clause_fifo);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        uc_queue_arbiter_1->input_from_clause_queue(test_input_from_clause_fifo[i]);
        uc_queue_arbiter_1->output_to_clause_queue(test_output_to_clause_fifo[i]);
    }
    
    test_input_from_latency_buffer.write(-1);
    // test_input_from_clause_fifo.write(2);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        if(i <= 5)
            test_input_from_clause_fifo[i].write(3);
        else{
            test_input_from_clause_fifo[i].write(i);
        }
    }
    golden_output_1 = 3;
    
    SC_THREAD(test_uc_arbiter);
}

void test_uc_queue_arbiter::test_uc_arbiter()
{
    uc_queue_arbiter_1->unit_clause_latency_data_finish.notify();
    
    // uc_queue_arbiter_1->engine_finish_each_unit_clause.notify();
    // for(int i=0; i<NUMBER_OF_ENGINE; ++i)
    //     uc_queue_arbiter_1->engine_finish_each_unit_clause[i].notify();

    wait(uc_queue_arbiter_1->finish_1st_iter);
    int res;
    res = uc_queue_arbiter_1->get_queue_value();
    if(res != golden_output_1){
        cout<<"Test Fail on uc_queue_arbiter, test 1, output value : "<<res<<", golden value : "<<golden_output_1<<endl;
        exit(-1);
    }
    cout<<"uc_queue_arbiter testing ...... OK"<<endl;
}
