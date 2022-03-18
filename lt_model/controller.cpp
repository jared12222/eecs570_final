#include "controller.h"

controller::controller(const sc_module_name& )
{

    conflict_flag = false;
    done_with_unit_clause_flag = false;
    done_with_clause_flag = false;

    SC_THREAD(controller_compute)
    sensitive<<clk.pos();
    dont_initialize();
}

void controller::controller_compute(){

    while(1){
        wait();

        if(conflict_in_uc_arbiter_port){
            conflict_flag = true;
            break;
        }
        int temp = true;
        for(int i=0; i<NUMBER_OF_ENGINE; ++i){
            if(!clause_engine_done_with_unit_clause_port[i]){
                temp = false;
            }
        }

        if(temp == true){
            done_with_unit_clause_flag = true;
        }
        
        temp = true;
        for(int i=0; i<NUMBER_OF_ENGINE; ++i){
            if(!clause_engine_done_with_clause_port[i]){
                temp = false;
            }
        }

        if(temp == true){
            done_with_clause_flag = true;
        }
    }
}