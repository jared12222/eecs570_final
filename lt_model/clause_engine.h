#ifndef __CLAUSE_ENGINE_H__
#define __CLAUSE_ENGINE_H__

#include "constant.h"
#include <queue> 


using namespace std;
using namespace sc_core;
using namespace std;

class clause_engine : public sc_module {

    public:
        explicit clause_engine(const sc_module_name& );
        SC_HAS_PROCESS(clause_engine);
        
        sc_port<sc_fifo_in_if<int> > input_from_unit_clause_fifo_port;
        sc_port<sc_fifo_in_if<sc_bv<CAUSE_WIDTH>> > input_from_clause_fifo_port;
        
        sc_port<sc_fifo_out_if<int> > output_to_unit_clause_fifo_port;
        sc_port<sc_fifo_out_if<sc_bv<CAUSE_WIDTH>> > output_to_clause_fifo_port;

        sc_event finish_1st_iter;

        void engine_compute();
        
        bool elimination(sc_bv<CAUSE_WIDTH> &clause, int unit_clause);

        bool contain_unit_clause(sc_bv<CAUSE_WIDTH> clause);
        int return_unit_clause(sc_bv<CAUSE_WIDTH> clause);

    private:
        int current_itr_count;
        
        int unit_clause;
        int new_gen_unit_clause;
        
        sc_bv<CAUSE_WIDTH> fetch_data_from_fifo;
};

#endif