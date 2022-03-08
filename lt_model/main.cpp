#include "top.h"
#include <iostream>

using namespace std;

int sc_main(int argc, char *argv[]){
	cout<<"Building top..."<<endl;
	top top1("top1");
	cout<<"Start simulation..."<<endl;
	sc_start();
	cout<<"End simulation..."<<endl;
	return 0;
}
