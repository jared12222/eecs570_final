#ifndef __LATENCY_BUFFER_ARBITER_H__
#define __LATENCY_BUFFER_ARBITER_H__

#include "constant.h"

using namespace std;
using namespace sc_core;
using namespace std;

class latency_buffer_arbiter : public sc_module {

    public:
        explicit latency_buffer_arbiter(const sc_module_name& );
        SC_HAS_PROCESS(latency_buffer_arbiter);

        sc_port<sc_fifo_in_if<sc_bv<CAUSE_WIDTH>> > input_from_latency_buffer_port;
        sc_port<sc_fifo_out_if<sc_bv<CAUSE_WIDTH>>, NUMBER_OF_ENGINE > output_to_clause_fifo_port;

        void latency_buffer_arbiter_compute();

    private:
        sc_bv<CAUSE_WIDTH> temp[NUMBER_OF_ENGINE];
};

#endif