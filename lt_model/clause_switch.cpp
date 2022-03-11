#include "clause_switch.h"

clause_switch::clause_switch(const sc_module_name& )
{
    input = 0;
    SC_THREAD(switch_compute);
    sensitive<<clk.pos();
    dont_initialize();
}

void clause_switch::switch_compute(){

    // int i=7;
    while(1){
        
        wait();
        
        // input = input_from_latency_buffer_port->read();

        

        if(input_from_latency_buffer_port->nb_read(input)){
            output_to_clause_fifo_port->write(input);
        }else if(input_from_engine_port->nb_read(input)){
            output_to_clause_fifo_port->write(input); 
        }

        // input_from_latency_buffer_port->nb_read(input);
        // //cout<<"input switch"<<endl;
        // output_to_clause_fifo_port->write(input);
        //cout<<"output switch"<<endl;
        // input = input_from_engine_port->read();
        // cout<<"output switch"<<endl;
        // output_to_clause_fifo_port->write(input);
        // cout<<"check in switch"<<endl;
        // wait(input_from_latency_buffer_port->data_written_event() | input_from_engine_port->data_written_event());
        // if(input_from_latency_buffer_port->num_available() >= 1){
        //     input = input_from_latency_buffer_port->read();
        //     output_to_clause_fifo_port->write(input);
        // }else if(input_from_engine_port->num_available() >= 1){
        //     input = input_from_engine_port->read();
        //     output_to_clause_fifo_port->write(input); 
        // }else{
        //     //do nothing
        // }

        #ifdef TEST
            wait();
        #endif
        // cout<<"suposed to close clause switch"<<endl;
    }
}