#include "c_queue_engine.h"

clause_queue_engine::clause_queue_engine(const sc_module_name& )
{
    current_itr_count = 0;

    
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