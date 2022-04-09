#include <iostream>
#include <stdio.h>
#include "svdpi.h"

using namespace std;

static ifstream cnf_input_file = NULL;
static ifstream trace_input_file = NULL;

void init_cnf_input_file(string file_path) {
    if (cnf_input_file == NULL){
        cnf_input_file.open(file_path, ios::in);
        if(!cnf_input_file.is_open()){
            cout<<"ERROR when opening cnf_input_file !"<<endl;
            exit(-1);
        }
    }
}

void init_trace_input_file(string file_path) {
    if (trace_input_file == NULL){
        trace_input_file.open(file_path, ios::in);
        if(!trace_input_file.is_open()){
            cout<<"ERROR when opening trace_input_file !"<<endl;
            exit(-1);
        }
    }
}

int output_num_of_engine(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_engine"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res
}

int output_num_of_padding(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_padding"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res
}

int output_num_of_var(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_var"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res
}

int output_num_of_lit_per_clause(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_lit_per_clause"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res
}

void skip_engine_num_head_node_string(){
    string tmp;
    cnf_input_file >> tmp >> tmp >> tmp;
}

int output_num_of_clause(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    cnf_input_file >> res;
    return res;
}

int output_number(){ //output header value or clause value
    int res;
    cnf_input_file >> res;
    return res;
}

