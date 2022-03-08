#include "uc_queue_arbiter.h"

uc_queue_arbiter::uc_queue_arbiter(const sc_module_name& )
{
    unit_var = 0;
    memset(var, 0, sizeof(int) * NUMBER_OF_VAR);
    SC_THREAD(load_unit_clause_from_latency_buffer);
    SC_THREAD(unit_clause_compute);
}

void uc_queue_arbiter::load_unit_clause_from_latency_buffer()
{
    wait(unit_clause_latency_data_finish);
    unit_queue.push(input_from_latency_buffer->read());
    finish_load_data_from_latency_buffer.notify();
}

unit_clause_compute(){
    wait(finish_load_data_from_latency_buffer);

    while(1){
        unit_var = unit_queue.front();
        unit_queue.pop();
        
        for(int i=0; i<NUMBER_OF_VAR; ++i)
            wait(engine_finish_each_unit_clause[i]);
        
        for(int i=0; i<NUMBER_OF_VAR; ++i){
            
        }
    }
}