#include "test_clause_engine.h"

test_clause_engine::test_clause_engine(const sc_module_name& )
{
    clause_engine_1->input_from_unit_clause_fifo_port(test_input_unit_clause_fifo);
    clause_engine_1->input_from_clause_fifo_port(test_input_clause_fifo);

    clause_engine_1->output_to_unit_clause_fifo_port(test_output_unit_clause_fifo);
    clause_engine_1->output_to_clause_fifo_port(test_output_clause_fifo);

    sc_bv<CAUSE_WIDTH> test_clause_1; // 3, 2, 1
    test_clause_1 = "000000110000001000000001";
    sc_bv<CAUSE_WIDTH> test_clause_2; // 5, -1, 4
    test_clause_2 = "000001011111111100000100";
    sc_bv<CAUSE_WIDTH> test_clause_3; // 5, 0, 0
    test_clause_3 = "000001010000000000000000";

    test_input_clause_fifo.write(test_clause_1);
    test_input_clause_fifo.write(test_clause_2);
    test_input_clause_fifo.write(test_clause_3);
    test_input_unit_clause_fifo.write(1);
    
    //5, 0 , 4
    golden_clause_output[0] = "000001010000000000000100";
    //5, 0, 0
    golden_clause_output[1] = "000001010000000000000000";
    golden_unit_clause_output[0] = 0;
    golden_unit_clause_output[1] = 0;
    golden_unit_clause_output[2] = 5;
    golden_output_clause_number = 2;
    golden_output_unit_clause_number = 3;
    SC_THREAD(test_engine_compute);
}

void test_clause_engine::test_engine_compute(){
   
    for(int i=0; i<golden_output_clause_number; ++i){
        res = test_output_clause_fifo.read();
        if(res != golden_clause_output[i]){
            cout<<"Test Fail on clause_engine, test clause["<<i<<"], output value : "<<res.to_int()<<", golden value : "<<golden_clause_output[i]<<endl;
            exit(-1);
        }
    }
    
    for(int i=0; i<golden_output_unit_clause_number; ++i){
        res = test_output_unit_clause_fifo.read();
        if(res != golden_unit_clause_output[i]){
            cout<<"Test Fail on clause_engine, test unit clause["<<i<<"], output value : "<<res<<", golden value : "<<golden_unit_clause_output[i]<<endl;
            exit(-1);
        }
    }

    cout<<"clause_engine, testing ...... OK"<<endl;
}
