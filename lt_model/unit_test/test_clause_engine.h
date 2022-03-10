#ifndef __TEST_CLAUSE_ENGINE_H__
#define __TEST_CLAUSE_ENGINE_H__

#include "/home/wftseng/eecs570_final/lt_model/clause_engine.h"
#include "/home/wftseng/eecs570_final/lt_model/constant.h"

class test_clause_engine : public sc_module {
    public:

        explicit test_clause_engine(const sc_module_name& );
        SC_HAS_PROCESS(test_clause_engine);

        sc_fifo<int > test_input_unit_clause_fifo;
        sc_fifo<sc_bv<CAUSE_WIDTH> > test_input_clause_fifo;

        sc_fifo<int > test_output_unit_clause_fifo;
        sc_fifo<sc_bv<CAUSE_WIDTH> > test_output_clause_fifo;
        

        clause_engine *clause_engine_1 = new clause_engine("clause_engine_1");
        
        void test_engine_compute();

        sc_bv<CAUSE_WIDTH> res;
        int unit_clause_res;
        
        int golden_output_clause_number, golden_output_unit_clause_number;
        sc_bv<CAUSE_WIDTH> golden_clause_output[2];
        int golden_unit_clause_output[3];
};




#endif