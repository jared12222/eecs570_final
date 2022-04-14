#include <iostream>
#include <fstream>
#include <stdio.h>
#include <regex>
#include "svdpi.h"

using namespace std;
extern "C" {
static ifstream cnf_input_file;
static ifstream trace_input_file;

void init_cnf_input_file(char* file_path) {
    cnf_input_file.open(file_path, ios::in);
    if(!cnf_input_file.is_open()){
        cout<<"ERROR when opening cnf_input_file !"<<endl;
        exit(-1);
    }
}

void init_trace_input_file(char* file_path) {
    trace_input_file.open(file_path, ios::in);
    if(!trace_input_file.is_open()){
        cout<<"ERROR when opening trace_input_file !"<<endl;
        exit(-1);
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
    return res;
}

int output_num_of_clause_per_engine(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_clause_per_engine"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res;
}

int output_num_of_padding(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_padding"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res;
}

int output_num_of_var(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_var"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res;
}

int output_num_of_lit_per_clause(){
    int res;
    string tmp;
    cnf_input_file >> tmp;
    while(tmp != "Num_of_lit_per_clause"){
        cnf_input_file >> tmp;
    }
    cnf_input_file >> res;
    return res;
}

void skip_engine_num_head_node_string(){
    string tmp;
    cnf_input_file >> tmp;
    while(!regex_match(tmp, regex("(Head_node)(.*)"))){
        cnf_input_file >> tmp;
    }
    // cnf_input_file >> tmp >> tmp;
    cout <<"output " << tmp <<endl;
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
    cout<<"res = "<<res<<endl;
    return res;
}

int output_iter_trace(){
    int res;
    string tmp;
    trace_input_file >> tmp;
    while(tmp != "iter" && (tmp != "SATISFIABLE" || tmp != "UNSATISFIABLE" || tmp != "Conflict")){
        trace_input_file >> tmp;
    }
    cout << tmp << endl;
    if((tmp == "SATISFIABLE" || tmp == "UNSATISFIABLE" || tmp == "Conflict")){
        return -1;
    }else{
        trace_input_file >> res;
        return res;
    }
}

// int stop_at_conflict(){
//     string tmp;
//     cnf_input_file >> tmp;
//     while(!regex_match(tmp, regex("(Conflict)(.*)")) && ){
//         cnf_input_file >> tmp;
//     }
//     // cnf_input_file >> tmp >> tmp;
//     if(regex_match(tmp, regex("(Conflict)(.*)")))
//         return -1;
//     else
//         return 0;
//     // cout <<"output " << tmp <<endl;
// }

void skip_model_trace(){
    string tmp;
    trace_input_file >> tmp;
    while(tmp != "model"){
        trace_input_file >> tmp;
    }
}

int output_init_uc_trace(){
    int res;
    string tmp;
    trace_input_file >> tmp;
    while(tmp != "init_uc" && tmp != "Conflict"){
        trace_input_file >> tmp;
    }
    if(tmp == "Conflict"){
        return 0;
    }else{
        trace_input_file >> res;
        return res;
    }
    
}

int output_num_of_clause_trace(){
    int res;
    string tmp;
    trace_input_file >> tmp;
    while(tmp != "num_of_clause"){
        trace_input_file >> tmp;
    }
    trace_input_file >> res;
    return res;
}

int output_bcp_result(){
    
    string tmp;
    trace_input_file >> tmp;
    while(tmp != "bcp_result"){
        trace_input_file >> tmp;
    }
    trace_input_file >> tmp;
    if(tmp == "UNDEFINE"){
        return 0;
    }else{
        return 1;
    }
}
}
