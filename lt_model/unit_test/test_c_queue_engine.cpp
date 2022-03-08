#include "test_c_queue_engine.h"

test_clause_queue_engine::test_clause_queue_engine(const sc_module_name& )
{
    clause_queue_engine_1->input_from_unit_clause_queue(test_input_unit_clause_queue);
    clause_queue_engine_1->input_from_latency_buffer(test_input_clause_queue);
    clause_queue_engine_1->output_to_unit_clause(test_output_unit_clause_queue);

    sc_bv<CAUSE_WIDTH> test_clause_1; // 3, 2, 1
    test_clause_1 = "000000110000001000000001";
    sc_bv<CAUSE_WIDTH> test_clause_2; // 5, -1, 4
    test_clause_2 = "000001011111111100000100";
    sc_bv<CAUSE_WIDTH> test_clause_3; // 5, 2, 3
    test_clause_3 = "000001010000000000000000";

    test_input_clause_queue.write(test_clause_1);
    test_input_clause_queue.write(test_clause_2);
    test_input_clause_queue.write(test_clause_3);
    test_input_unit_clause_queue.write(1);
    
    //5, 0 , 4
    golden_output_1 = "000001010000000000000100";
    //5, 2, 3
    golden_output_2 = "000001010000000000000000";
    golden_unit_clause_output = 5;
    SC_THREAD(test_engine_compute);
}

void test_clause_queue_engine::test_engine_compute(){
    clause_queue_engine_1->latency_data_finish.notify();
    wait(clause_queue_engine_1->finish_1st_iter);
    // while(clause_queue_engine_1->finished_1st_itr == false);
    sc_bv<CAUSE_WIDTH> res;
    int unit_clause_res;
    res = clause_queue_engine_1->get_queue_value();
    if(res != golden_output_1){
        cout<<"Test Fail on c_queue_engine, test 1, output value : "<<res<<", golden value : "<<golden_output_1<<endl;
        exit(-1);
    }
    res = clause_queue_engine_1->get_queue_value();
    if(res != golden_output_2){
        cout<<"Test Fail on c_queue_engine, test 2, output value : "<<res<<", golden value : "<<golden_output_2<<endl;
        exit(-1);
    }

    unit_clause_res = test_output_unit_clause_queue.read();
    if(unit_clause_res !=  golden_unit_clause_output){
        cout<<"Test Fail on c_queue_engine, test 3, unit clause output value : "<<unit_clause_res<<", golden value : "<<golden_unit_clause_output<<endl;
        exit(-1);
    }

    cout<<"c_queue_engine, testing ...... OK"<<endl;
}
