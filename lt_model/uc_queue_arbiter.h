#ifndef __UC_QUEUE_ARBITER_H__
#define __UC_QUEUE_ARBITER_H__

#include "constant.h"

class uc_queue_arbiter : public sc_module {
    public:
        
        explicit uc_queue_arbiter(const sc_module_name& );
        SC_HAS_PROCESS(uc_queue_arbiter);

        queue<int> unit_queue;
        sc_port<sc_fifo_blocking_in_if<int>> input_from_latency_buffer;
        sc_port<sc_fifo_blocking_in_if<int>, NUMBER_OF_ENGINE> input_from_clause_queue;
        sc_port<sc_fifo_blocking_out_if<int>, NUMBER_OF_ENGINE> output_to_clause_queue

        sc_event unit_clause_latency_data_finish, finish_load_data_from_latency_buffer, engine_finish_each_unit_clause[NUMBER_OF_ENGINE];

        void load_unit_clause_from_latency_buffer();
        void unit_clause_compute();

        int unit_var;
        int var[NUMBER_OF_VAR * 2];
};

#endif