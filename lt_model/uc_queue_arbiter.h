#ifndef __UC_QUEUE_ARBITER_H__
#define __UC_QUEUE_ARBITER_H__

#include "constant.h"
#include <unordered_set>

using namespace std;

class uc_queue_arbiter : public sc_module {
    public:
        
        explicit uc_queue_arbiter(const sc_module_name& );
        SC_HAS_PROCESS(uc_queue_arbiter);

        
        sc_port<sc_fifo_in_if<int> > input_from_latency_buffer_port;
        // sc_port<sc_fifo_nonblocking_in_if<int> > input_from_clause_queue;
        // sc_port<sc_fifo_blocking_out_if<int> > output_to_clause_queue;
        sc_port<sc_fifo_in_if<int>, NUMBER_OF_ENGINE > input_from_clause_engine_fifo_port;
        sc_port<sc_fifo_out_if<int>, NUMBER_OF_ENGINE > output_to_clause_engine_fifo_port;

        //sc_event unit_clause_latency_data_finish, finish_load_data_from_latency_buffer, engine_finish_each_unit_clause, finish_1st_iter;
        sc_event engine_finish_each_unit_clause_event[NUMBER_OF_ENGINE];
        sc_event_and_list and_list;
        // void load_unit_clause_from_latency_buffer();
        void unit_clause_compute();
        int find_next_unit_clause(int* pos_var, int* neg_var);
        int get_queue_value();

        queue<int> unit_queue;
        int unit_var;
        unordered_set<int> previous_unit_clause;
};

#endif