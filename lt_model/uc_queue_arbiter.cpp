#include "uc_queue_arbiter.h"

uc_queue_arbiter::uc_queue_arbiter(const sc_module_name& )
{
    unit_var = 0;

    // SC_THREAD(load_unit_clause_from_latency_buffer);
    SC_THREAD(unit_clause_compute);
    sensitive<<clk.pos();
    dont_initialize();
}

// void uc_queue_arbiter::load_unit_clause_from_latency_buffer()
// {
//     wait(unit_clause_latency_data_finish);
//     unit_queue.push(input_from_latency_buffer_port->read());
//     finish_load_data_from_latency_buffer.notify();
// }

void uc_queue_arbiter::unit_clause_compute(){
    // wait(finish_load_data_from_latency_buffer);
    // int i=5;
    while(1){
        // cout<<"start uc clause arbiter"<<endl;
        wait();
        // cout<<"before uc clause arbiter"<<endl;
        int temp = 0;
        if(input_from_latency_buffer_port->nb_read(temp)){
            for(int i=0; i<NUMBER_OF_ENGINE; ++i)
                output_to_clause_engine_fifo_port[i]->write(temp);
        }
       
        
        int number_unit_clause_in_engine;
        for(int i=0; i<NUMBER_OF_ENGINE; ++i){
            if(input_from_clause_engine_fifo_port[i]->nb_read(temp)){
                if(temp != 0 && previous_unit_clause.find(temp) == previous_unit_clause.end()){
                    previous_unit_clause.insert(temp);
                    //unit_queue.push(temp);
                    for(int i=0; i<NUMBER_OF_ENGINE; ++i)
                        output_to_clause_engine_fifo_port[i]->write(temp);
                }
            }
        }
        
        // if(unit_queue.size() == 0){
        //     no_data_in_queue.notify();
        // }
        // cout<<"suposed to close uc clause engine"<<endl;
    }
}

// int uc_queue_arbiter::find_next_unit_clause(int* pos_var, int* neg_var)
// {
//     int pos_max = 0, neg_max = 0;
//     int pos_idx = 0, neg_idx = 0;

//     for(int i=0; i<NUMBER_OF_VAR; ++i){
//         if(pos_var[i] > pos_max){
//             pos_max = pos_var[i];
//             pos_idx = i;
//         }
//         if(neg_var[i] > neg_max){
//             neg_max = neg_var[i];
//             neg_idx = i;
//         }
//     }

//     memset(pos_var, 0, sizeof(int) * NUMBER_OF_VAR);
//     memset(neg_var, 0, sizeof(int) * NUMBER_OF_VAR);

//     if(pos_max > neg_max)
//         return pos_idx;
//     else
//         return -1*neg_idx;

// }

int uc_queue_arbiter::get_queue_value(){
    int res;
    if(unit_queue.size() == 0){
        cout<<"Fail on calling uc_queue_arbiter::get_queue_value(), no data in queue"<<endl;
        exit(-1);
    }

    res = unit_queue.front();
    unit_queue.pop();

    return res;
}