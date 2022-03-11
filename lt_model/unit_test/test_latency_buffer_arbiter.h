#ifndef __TEST_LATENCY_BUFFER_ARBITER_H__
#define __TEST_LATENCY_BUFFER_ARBITER_H__

#include "/home/wftseng/eecs570_final/lt_model/latency_buffer_arbiter.h"


class test_latency_buffer_arbiter : public sc_module {

    public:
        explicit test_latency_buffer_arbiter(const sc_module_name& );
        SC_HAS_PROCESS(test_latency_buffer_arbiter);

        sc_fifo<sc_bv<CAUSE_WIDTH> > test_latency_buffer;
        sc_fifo<sc_bv<CAUSE_WIDTH> > test_clause_fifo[NUMBER_OF_ENGINE];

        latency_buffer_arbiter *latency_buffer_arbiter_1 = new latency_buffer_arbiter("latency_buffer_arbiter_1");

        void test_latency_buffer_arbiter_compute();
    
    private:
        int num_of_golden_output;
        sc_bv<CAUSE_WIDTH> res;
        sc_bv<CAUSE_WIDTH> golden_clause_output_1[2];
        sc_bv<CAUSE_WIDTH> golden_clause_output_2[2];
};

#endif