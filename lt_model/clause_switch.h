#ifndef __CLAUSE_SWITCH_H__
#define __CLAUSE_SWITCH_H__

#include "constant.h"

using namespace std;
using namespace sc_core;
using namespace std;

class clause_switch : public sc_module {

    public:
        explicit clause_switch(const sc_module_name& );
        SC_HAS_PROCESS(clause_switch);

        sc_port<sc_fifo_in_if<sc_bv<CAUSE_WIDTH>> > input_from_latency_buffer_port;
        sc_port<sc_fifo_in_if<sc_bv<CAUSE_WIDTH>> > input_from_engine_port;

        sc_port<sc_fifo_out_if<sc_bv<CAUSE_WIDTH>> > output_to_clause_fifo_port;

        void switch_compute();
    private:
        sc_bv<CAUSE_WIDTH> input;
};

#endif