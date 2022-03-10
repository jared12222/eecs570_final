// To test clause switch module, you need to define TEST in the constant.h. Otherwise, uncomment TEST in constant.h
#ifndef __TEST_CLAUSE_SWITCH_H__
#define __TEST_CLAUSE_SWITCH_H__

#include "/home/wftseng/eecs570_final/lt_model/clause_switch.h"
#include "/home/wftseng/eecs570_final/lt_model/constant.h"

class test_clause_switch : public sc_module {
    
    public:
        explicit test_clause_switch(const sc_module_name& );
        SC_HAS_PROCESS(test_clause_switch);

        sc_fifo<sc_bv<CAUSE_WIDTH> > test_latency_buffer;
        sc_fifo<sc_bv<CAUSE_WIDTH> > test_engine_output_fifo;

        sc_fifo<sc_bv<CAUSE_WIDTH> > test_clause_fifo;

        clause_switch *clause_switch_1 = new clause_switch("clause_switch_1");

        void test_switch_compute();

        int num_of_golden_output;
        sc_bv<CAUSE_WIDTH> golden_clause_output[2], res;
};

#endif