#ifndef __TOP_H__
#define __TOP_H__

#include "constant.h"
#include "clause_engine.h"
#include "uc_queue_arbiter.h"
#include "clause_switch.h"
#include "latency_buffer_arbiter.h"

using namespace sc_core;
using namespace std;

class top : public sc_module {
    public:

        explicit top(const sc_module_name& );
        SC_HAS_PROCESS(top);

        sc_fifo<int > engine_output_unit_clause_fifo[NUMBER_OF_ENGINE]; //depth == N
        sc_fifo<int > engine_input_unit_clause_fifo[NUMBER_OF_ENGINE]; //depth == 1
        sc_fifo<sc_bv<CAUSE_WIDTH> > engine_input_clause_fifo[NUMBER_OF_ENGINE]; //depth == N
        sc_fifo<sc_bv<CAUSE_WIDTH> > switch_input_from_engine_clause_fifo[NUMBER_OF_ENGINE]; //depth == 1
        sc_fifo<sc_bv<CAUSE_WIDTH> > switch_input_from_latency_clause_fifo[NUMBER_OF_ENGINE]; //depth == 1
        
        sc_fifo<int > unit_clause_latency_buffer;
        sc_fifo<sc_bv<CAUSE_WIDTH> > latency_buffer; //depth = N * NUMBER_OF_ENGINE

        clause_engine *clause_engine_1[NUMBER_OF_ENGINE];
        clause_switch *clause_switch_1[NUMBER_OF_ENGINE];

        uc_queue_arbiter *uc_queue_arbiter_1;
        latency_buffer_arbiter *latency_buffer_arbiter_1;

        void top_compute();
        void egnine_notify_uc_arbiter();
        void read_data_to_latency_buffer();

        void print_engine_input_clause_fifo(int engine_number);
        sc_clock clk;
        string input_file_path = "/home/wftseng/eecs570_final/lt_model/input_file/test0";
};

#endif