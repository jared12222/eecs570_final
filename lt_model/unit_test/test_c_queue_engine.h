#ifndef __TEST_C_QUEUE_ENGINE_H__
#define __TEST_C_QUEUE_ENGINE_H__

#include "/home/wftseng/eecs570_final/lt_model/c_queue_engine.h"
#include "/home/wftseng/eecs570_final/lt_model/constant.h"
#include <systemc.h>

class test_clause_queue_engine : public sc_module {
    public:

        explicit test_clause_queue_engine(const sc_module_name& );
        SC_HAS_PROCESS(test_clause_queue_engine);

        sc_fifo<int > test_input_unit_clause_queue;
        sc_fifo<sc_bv<CAUSE_WIDTH> > test_input_clause_queue;
        sc_fifo<int > test_output_unit_clause_queue;

        clause_queue_engine *clause_queue_engine_1 = new clause_queue_engine("clause_queue_engine_1");
        
        void test_engine_compute();
        sc_bv<CAUSE_WIDTH> golden_output_1, golden_output_2;
        int golden_unit_clause_output;
};




#endif