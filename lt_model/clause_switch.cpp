#include "clause_switch.h"

clause_switch::clause_switch(const sc_module_name& )
{
    SC_THREAD(switch_compute);
}

void clause_switch::switch_compute(){

    while(1){

        if(input_from_latency_buffer_port->num_available() == 1){
            //cout<<"check"<<endl;
            input = input_from_latency_buffer_port->read();
            output_to_clause_fifo_port->write(input);
        }else if(input_from_engine_port->num_available() == 1){
            input = input_from_engine_port->read();
            output_to_clause_fifo_port->write(input); 
        }else{
            //do nothing
        }

        #ifdef TEST
            wait();
        #endif
    }
}