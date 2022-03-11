#include "test_latency_buffer_arbiter.h"

test_latency_buffer_arbiter::test_latency_buffer_arbiter(const sc_module_name& )
{
    latency_buffer_arbiter_1->input_from_latency_buffer_port(test_latency_buffer);
    for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        latency_buffer_arbiter_1->output_to_clause_fifo_port(test_clause_fifo[i]);
    }

    num_of_golden_output = 2;

    test_latency_buffer.write("000000110000001000000001");
    test_latency_buffer.write("000001011111111100000100");
    test_latency_buffer.write("100001011101011100000100");
    test_latency_buffer.write("011001011111111100100100");

    golden_clause_output_1[0] = "000000110000001000000001";
    golden_clause_output_1[1] = "100001011101011100000100";

    golden_clause_output_2[0] = "000001011111111100000100";
    golden_clause_output_2[1] = "011001011111111100100100";

    SC_THREAD(test_latency_buffer_arbiter_compute);
}

void test_latency_buffer_arbiter::test_latency_buffer_arbiter_compute(){

    for(int i=0; i<num_of_golden_output; ++i){
        res = test_clause_fifo[0].read();
        if(res != golden_clause_output_1[i]){
            cout<<"Test Fail on latency_buffer_arbiter, test output engine["<<i<<"], output value : "<<res<<", golden value : "<<golden_clause_output_1[i]<<endl;
            exit(-1);
        }
    }

    for(int i=0; i<num_of_golden_output; ++i){
        res = test_clause_fifo[1].read();
        if(res != golden_clause_output_2[i]){
            cout<<"Test Fail on latency_buffer_arbiter, test output engine["<<i<<"], output value : "<<res<<", golden value : "<<golden_clause_output_2[i]<<endl;
            exit(-1);
        }
    }

    cout<<"latency_buffer_arbiter, testing ...... OK"<<endl;
}