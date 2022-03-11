#include "clause_engine.h"

clause_engine::clause_engine(const sc_module_name& )
{
    current_itr_count = 0;
    new_gen_unit_clause = 0;
    unit_clause = 0;
    
    SC_THREAD(engine_compute);
    sensitive<<clk.pos();
    dont_initialize();
}



void clause_engine::engine_compute() 
{   
    // int i=5;
    while(1){
        
        wait();

        fetch_data_from_fifo = input_from_clause_fifo_port->read();
        
        if(fetch_data_from_fifo == 0){
            // if(input_from_unit_clause_fifo_port->nb_read(unit_clause)){
            //     cout<<"can't determine"<<endl;
            // }
            unit_clause = input_from_unit_clause_fifo_port->read();
            output_to_clause_fifo_port->write(fetch_data_from_fifo);
            continue;
        }
        if(!elimination(fetch_data_from_fifo, unit_clause)){
            output_to_clause_fifo_port->write(fetch_data_from_fifo);
        }
        output_to_unit_clause_fifo_port->write(new_gen_unit_clause);
        new_gen_unit_clause = 0;
        
        

        // if(input_from_clause_fifo_port->nb_read(fetch_data_from_fifo)){
        //     if(fetch_data_from_fifo == 0){
        //         if(!input_from_unit_clause_fifo_port->nb_read(unit_clause)){
        //             cout<<"error in reading unit clause"<<endl;
        //             exit(-1);
        //         }
        //         if(!elimination(fetch_data_from_fifo, unit_clause)){
        //             output_to_clause_fifo_port->write(fetch_data_from_fifo);
        //         }
        //         output_to_unit_clause_fifo_port->write(new_gen_unit_clause);
        //         new_gen_unit_clause = 0;
        //     }
        // }
    }
}

bool clause_engine::elimination(sc_bv<CAUSE_WIDTH> &clause, int unit_clause){

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

bool clause_engine::contain_unit_clause(sc_bv<CAUSE_WIDTH> clause){
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

int clause_engine::return_unit_clause(sc_bv<CAUSE_WIDTH> clause){
    sc_bv<WIDTH_PER_VAR> mask = -1;
    
    for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i){
        if((clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR) & mask).to_int() != 0)
            return clause.range((i+1)*WIDTH_PER_VAR-1, i*WIDTH_PER_VAR).to_int();
    }
    return 0;
}

