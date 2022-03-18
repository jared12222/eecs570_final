#include "top.h"
#include <iostream>

using namespace std;

int sc_main(int argc, char *argv[]){
	cout<<"Building top..."<<endl;
	sc_clock clk("clk", 1, SC_NS, 0.5);
	top top1("top1");
	top1.clk(clk);
	
	cout<<endl<<"*******************  Start simulation *******************"<<endl<<endl;
	
	sc_start(MAX_SIM_CYCLE, SC_NS);
	
	cout<<endl<<"*******************  End simulation *********************"<<endl;
	
	return 0;
}
