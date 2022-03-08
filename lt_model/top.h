#ifndef __TOP_H__
#define __TOP_H__

#include <systemc>
#include "c_queue_engine.h"


using namespace sc_core;
using namespace std;

class top : public sc_module {
    public:

        explicit top(const sc_module_name& );

        clause_queue_engine *clause_queue_engine_1;

};

#endif