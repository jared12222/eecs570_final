#include "test_clause_engine.h"
#include "test_uc_queue_arbiter.h"
#include "test_clause_switch.h"
// #include "test_dual_port_fifo.h"
#include <iostream>

using namespace std;

int sc_main(int argc, char *argv[]){
	cout<<"Building modules..."<<endl;

	test_clause_engine test_clause_engine_1("test_clause_engine_1");
	test_uc_queue_arbiter test_uc_queue_arbiter_1("test_uc_queue_arbiter_1");
	test_clause_switch test_clause_switch_1("test_clause_switch_1");
	// test_dual_fifo test_dual_fifo_1("test_dual_fifo_1");
	cout<<"*************************"<<endl;
	cout<<"* Start unit testing... *"<<endl;
	cout<<"*************************"<<endl<<endl;;
	sc_start();
	cout<<endl<<"*************************"<<endl;
	cout<<"** End unit testing... **"<<endl;
	cout<<"*************************"<<endl;
	return 0;
}
