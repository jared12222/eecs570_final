#include "latency_buffer_arbiter.h"

latency_buffer_arbiter::latency_buffer_arbiter(const sc_module_name& )
{
    SC_THREAD(latency_buffer_arbiter_compute);
    sensitive<<clk.pos();
    dont_initialize();
}

void latency_buffer_arbiter::latency_buffer_arbiter_compute()
{
    // int i=5;
    while(1){
        // Need to rewrite to handle the case that the number of data in latency buffer 
        // can't be divided by Number of engine
        // cout<<"start latency arbiter"<<endl;
        wait();
        // cout<<"before latency arbiter"<<endl;
        for(int i=0; i<NUMBER_OF_ENGINE; ++i){
            // cout<<"l arbiter read start"<<endl;
            //temp[i] = input_from_latency_buffer_port->read();
            if(input_from_latency_buffer_port->nb_read(temp[i])){
                output_to_clause_fifo_port[i]->write(temp[i]);
            }
            // cout<<"l arbiter read end"<<endl;
        }
        // for(int i=0; i<NUMBER_OF_ENGINE; ++i){
        //     output_to_clause_fifo_port[i]->write(temp[i]);
        // }
        // cout<<"suposed to close latency arbiter"<<endl;
    }
}