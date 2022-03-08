#include "c_queue_engine.h"

clause_queue_engine::clause_queue_engine(const sc_module_name& )
{
    current_itr_count = 0;
    new_gen_unit_clause = 0;
    //memset(new_gen_unit_clause, 0, sizeof(int) * NUMBER_OF_VAR * 2);
    SC_THREAD(load_clause_from_latency_buffer);
    SC_THREAD(engine_compute);
}


void clause_queue_engine::load_clause_from_latency_buffer(){
    wait(latency_data_finish);
    clause_queue.push(input_from_latency_buffer->read());
    clause_queue.push(input_from_latency_buffer->read());
    clause_queue.push(input_from_latency_buffer->read());
    load_data_finish.notify();
}

void clause_queue_engine::engine_compute() 
{
    while(1){
      
        wait(load_data_finish);
        
        unit_clause = input_from_unit_clause_queue->read();
        
        //while(1){
            // if (stall)
            //     continue;

        current_itr_count = clause_queue.size();    
        
        for(int i=0; i<current_itr_count; ++i){
            
            fetch_data_from_queue = clause_queue.front();
            
            clause_queue.pop();
            if(!elimination(fetch_data_from_queue, unit_clause)){
                clause_queue.push(fetch_data_from_queue);
            }
        }
        if(new_gen_unit_clause != 0){
            output_to_unit_clause->write(new_gen_unit_clause);
            new_gen_unit_clause = 0;
        }
        //cout<<"get_queue_value = "<<get_queue_value()<<endl;
        
        finish_1st_iter.notify();  //for unit test purpose
        //}
    }
}

bool clause_queue_engine::elimination(sc_bv<CAUSE_WIDTH> &clause, int unit_clause){

    sc_bv<WIDTH_PER_VAR> neg_unit_clause = -1*(unit_clause);

    for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i){
        if(clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR) == unit_clause){
            return true;
        }else if(clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR) == neg_unit_clause){
            clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR) = 0;
        }
    }

    // check if there is unit clause and send to fifo between engine and unit clause arbiter
    int temp;
    if(contain_unit_clause(clause)){
        new_gen_unit_clause = return_unit_clause(clause);
        // temp = return_unit_clause(clause);
        // if(temp >= 0)
        //     new_gen_unit_clause[temp]++;
        // else
        //     new_gen_unit_clause[-1*temp+NUMBER_OF_VAR]++;
        // output_to_unit_clause->write(choose_next_unit_clause(clause));
    }
    //***************************************************************************************

    sc_bv<CAUSE_WIDTH> zero;
    for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i){
        zero |= clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR);
    }

    if(zero == 0)
        return true;
    else
        return false;
    return true;
}

bool clause_queue_engine::contain_unit_clause(sc_bv<CAUSE_WIDTH> clause){
    sc_bv<WIDTH_PER_VAR> mask = -1;
    int non_zero_count = 0;

    for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i){
        if((clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR) & mask).to_int() != 0)
        non_zero_count++;
    }
    
    if(non_zero_count == 1){
        return true;
    }
    return false;
    
}

int clause_queue_engine::return_unit_clause(sc_bv<CAUSE_WIDTH> clause){
    sc_bv<WIDTH_PER_VAR> mask = -1;
    
    for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i){
        if((clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR) & mask).to_int() != 0)
            return clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR).to_int();
    }
    return 0;
}

// int clause_queue_engine::choose_next_unit_clause(sc_bv<CAUSE_WIDTH> clause){
//     int max = 0;
//     int idx = 0;

//     for(int i=0; i<NUMBER_OF_VAR*2; ++i){
//         if(new_gen_unit_clause[i] > max){
//             max = new_gen_unit_clause[i];
//             idx = i;
//         }
//     }
//     memset(new_gen_unit_clause, 0, sizeof(int) * NUMBER_OF_VAR * 2);
    
//     if(idx<NUMBER_OF_VAR)
//         return idx;
//     else
//         return -1*(idx-NUMBER_OF_VAR);
// }

sc_bv<CAUSE_WIDTH> clause_queue_engine::get_queue_value(){
    sc_bv<CAUSE_WIDTH> res;
    if(clause_queue.size() == 0){
        cout<<"Fail on calling clause_queue_engine::get_queue_value(), no data in queue"<<endl;
        exit(-1);
    }

    res = clause_queue.front();
    clause_queue.pop();

    return res;
}