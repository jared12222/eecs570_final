#ifndef __CONTROLLER_H__
#define __CONTROLLER_H__

#include "constant.h"

using namespace sc_core;
using namespace std;

class controller : public sc_module {
    public:
        explicit controller(const sc_module_name& );
        SC_HAS_PROCESS(controller);

        sc_in<bool> clause_engine_done_with_clause_port[NUMBER_OF_ENGINE];
        sc_in<bool> clause_engine_done_with_unit_clause_port[NUMBER_OF_ENGINE];

        sc_in<bool> conflict_in_uc_arbiter_port;
        
        sc_in<bool> clk;

        void controller_compute();
        
        bool conflict_flag, done_with_unit_clause_flag, done_with_clause_flag;
};
#endif