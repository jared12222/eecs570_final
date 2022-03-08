#include "test_c_queue_engine.h"
#include "test_uc_queue_arbiter.h"
#include <iostream>

using namespace std;

int sc_main(int argc, char *argv[]){
	cout<<"Building test_c_queue_engine..."<<endl;

	test_clause_queue_engine test_clause_queue_engine_1("test_clause_queue_engine_1");
	test_uc_queue_arbiter test_uc_queue_arbiter_1("test_uc_queue_arbiter_1");
	cout<<"*************************"<<endl;
	cout<<"* Start unit testing... *"<<endl;
	cout<<"*************************"<<endl<<endl;;
	sc_start();
	cout<<endl<<"*************************"<<endl;
	cout<<"** End unit testing... **"<<endl;
	cout<<"*************************"<<endl;
	return 0;
}
