#ifndef __TEST_UC_QUEUE_ARBITER_H__
#define __TEST_UC_QUEUE_ARBITER_H__

#include "/home/wftseng/eecs570_final/lt_model/uc_queue_arbiter.h"
//#include "/home/wftseng/eecs570_final/lt_model/constant.h"

class test_uc_queue_arbiter : public sc_module {
    public:
        explicit test_uc_queue_arbiter(const sc_module_name& );
        SC_HAS_PROCESS(test_uc_queue_arbiter);

        sc_fifo<int > test_input_from_latency_buffer;
        sc_fifo<int > test_input_from_clause_fifo[NUMBER_OF_ENGINE];
        sc_fifo<int > test_output_to_clause_fifo[NUMBER_OF_ENGINE];

        uc_queue_arbiter *uc_queue_arbiter_1 = new uc_queue_arbiter("uc_queue_arbiter_1");

        void test_uc_arbiter();

        int golden_unit_clause_output_engine[2];
        int golden_output_unit_clause_number;
};

#endif
