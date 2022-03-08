#ifndef __C_QUEUE_ENGINE_H__
#define __C_QUEUE_ENGINE_H__

#include "constant.h"
#include <queue> 


using namespace std;
using namespace sc_core;
using namespace std;

class clause_queue_engine : public sc_module {

    public:
        explicit clause_queue_engine(const sc_module_name& );
        SC_HAS_PROCESS(clause_queue_engine);
        
        //sc_port<sc_fifo_blocking_in_if<bool> > stall;
        sc_port<sc_fifo_blocking_in_if<int> > input_from_unit_clause_queue;
        sc_port<sc_fifo_blocking_in_if<sc_bv<CAUSE_WIDTH>> > input_from_latency_buffer;
        
        sc_port<sc_fifo_blocking_out_if<sc_bv<CAUSE_WIDTH>> > output_to_unit_clause;

        sc_event latency_data_finish, load_data_finish, finish_1st_iter;

        void load_clause_from_latency_buffer();
        void engine_compute();
        
        bool elimination(sc_bv<CAUSE_WIDTH> &clause, int unit_clause);

        sc_bv<CAUSE_WIDTH> get_queue_value(); 

        queue<sc_bv<CAUSE_WIDTH>> clause_queue;
    private:
        int current_itr_count;
        
        int unit_clause;
        sc_bv<CAUSE_WIDTH> fetch_data_from_queue;
};

#endif