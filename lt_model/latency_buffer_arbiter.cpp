#include "latency_buffer_arbiter.h"

latency_buffer_arbiter::latency_buffer_arbiter(const sc_module_name& )
{
    SC_THREAD(latency_buffer_arbiter_compute);
}

void latency_buffer_arbiter::latency_buffer_arbiter_compute()
{
    while(1){

        for(int i=0; i<NUMBER_OF_ENGINE; ++i){
            temp[i] = input_from_latency_buffer_port->read();
        }
        for(int i=0; i<NUMBER_OF_ENGINE; ++i){
            output_to_clause_fifo_port[i]->write(temp[i]);
        }
    }
}