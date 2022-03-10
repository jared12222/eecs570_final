#include "test_clause_switch.h"

test_clause_switch::test_clause_switch(const sc_module_name& )
{
    clause_switch_1->input_from_latency_buffer_port(test_latency_buffer);
    clause_switch_1->input_from_engine_port(test_engine_output_fifo);

    clause_switch_1->output_to_clause_fifo_port(test_clause_fifo);

    //latency_input = "000000110000001000000001" 3, 2, 1
    test_latency_buffer.write("000000110000001000000001");
    //engine input = "000001011111111100000100" 5, -1, 4
    test_engine_output_fifo.write("000001011111111100000100");

    num_of_golden_output = 1;
    golden_clause_output[0] = "000000110000001000000001";
    golden_clause_output[1] = "000001011111111100000100";
    
    SC_THREAD(test_switch_compute);
}

void test_clause_switch::test_switch_compute(){
    
    for(int i=0; i<num_of_golden_output; ++i){
        res = test_clause_fifo.read();
        if(res != golden_clause_output[i]){
            cout<<"Test Fail on clause_switch, test clause["<<i<<"], output value : "<<res<<", golden value : "<<golden_clause_output[i]<<endl;
            exit(-1);
        }
    }

    cout<<"clause_switch, testing ...... OK"<<endl;
}