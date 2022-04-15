#include <iostream>
#include <fstream> 
#include <vector>   
#include <stdlib.h>
#include <string>

using namespace std;

#define MAX_UC_COUNT 1000
#define NUM_OF_TEST_CASE 30
// int uc_count = 5723;

int num_of_uc;
vector<int> uc;
string tmp;
int num_of_engine;
int num_of_clause_per_engine;
int num_of_lit_per_clause;
vector<vector<vector<int> >> clauses_per_engine;
vector<vector<vector<int> >> sorted_clauses_per_engine;
int num_of_var;

int occurrence_per_engine(vector<vector<int> > clause_per_engine, int uc){
    int acc = 0;

    for(int i=0; i<clause_per_engine.size(); ++i){
        for(int j=0; j<clause_per_engine[i].size(); ++j){
            if(clause_per_engine[i][j] == uc){
                acc++;
                break;
            }
        }
    }
    return acc;
}

int longest_process_time(vector<vector<vector<int> >> clauses_per_engine, int uc){
    int max = 0;
    int acc;
    for(int i=0; i<clauses_per_engine.size(); ++i){
        acc = occurrence_per_engine(clauses_per_engine[i], uc);
        if(acc > max){
            max = acc;
        }
    }
    return max;
}


int main(int argc, char *argv[]){
    if(argc != 4){
        cout<<"Enter wrong number of argument !"<<endl;
        return -1;
    }

    ifstream input_file_cnf(argv[1]);
    if(!input_file_cnf.is_open()){
        cout<<"ERROR when opening input cnf file !"<<endl;
        return -1;
    }
    string input_file_name(argv[1]);
    if(input_file_name.find("100") != string::npos)
        num_of_var = 100;
    else if(input_file_name.find("150") != string::npos)
        num_of_var = 150;
    else if(input_file_name.find("200") != string::npos)
        num_of_var = 200;
    else if(input_file_name.find("250") != string::npos)
        num_of_var = 250;
    else if(input_file_name.find("300") != string::npos)
        num_of_var = 300;
    else{
        cout << "Can find num_of_var"<<endl;
        exit(-1);
    }
    cout<<" Num of var = "<<num_of_var<<endl;
    ifstream sorted_input_file_cnf(argv[2]);
    if(!sorted_input_file_cnf.is_open()){
        cout<<"ERROR when opening input cnf file !"<<endl;
        return -1;
    }

    ifstream input_file_trace(argv[3]);
    if(!input_file_trace.is_open()){
        cout<<"ERROR when opening input trace file !"<<endl;
        return -1;
    }

    // fstream cal_sorted_file("./cal_sorted_effect/"+to_string(num_of_var), ios::in | ios::out);
    fstream cal_sorted_file("./cal_sorted_effect/output", ios::out | ios::app);
    if(!cal_sorted_file.is_open()){
        cout<<"ERROR when opening output file !"<<endl;
        return -1;
    }
    //input data from cnf
    input_file_cnf >> tmp;
    while(tmp != "Num_of_engine"){
        input_file_cnf >> tmp;
    }
    input_file_cnf >> num_of_engine;
    clauses_per_engine.resize(num_of_engine);
    sorted_clauses_per_engine.resize(num_of_engine);
    input_file_cnf >> tmp;
    while(tmp != "Num_of_clause_per_engine"){
        input_file_cnf >> tmp;
    }
    input_file_cnf >> num_of_clause_per_engine;
    
    input_file_cnf >> tmp;
    while(tmp != "Num_of_lit_per_clause"){
        input_file_cnf >> tmp;
    }
    input_file_cnf >> num_of_lit_per_clause;

    
    int lit;
    for(int i=0; i<num_of_engine; ++i){
        input_file_cnf >> tmp;
        while(tmp != "Head_node"){
            input_file_cnf >> tmp;
        }

        for(int j=0; j<num_of_var*4; ++j){
            input_file_cnf >> tmp;
        }
        
        clauses_per_engine[i].resize(num_of_clause_per_engine);
        for(int j=0; j<num_of_clause_per_engine; ++j){
            for(int k=0; k<num_of_lit_per_clause; ++k){
                input_file_cnf >> lit;
                input_file_cnf >> tmp;
                clauses_per_engine[i][j].push_back(lit);
            }
        }
    }
    //input sorted data
    for(int i=0; i<num_of_engine; ++i){
        sorted_input_file_cnf >> tmp;
        while(tmp != "Head_node"){
            sorted_input_file_cnf >> tmp;
        }
        
        for(int j=0; j<num_of_var*4; ++j){
            sorted_input_file_cnf >> tmp;
        }
        
        sorted_clauses_per_engine[i].resize(num_of_clause_per_engine);
        for(int j=0; j<num_of_clause_per_engine; ++j){
            for(int k=0; k<num_of_lit_per_clause; ++k){
                sorted_input_file_cnf >> lit;
                sorted_input_file_cnf >> tmp;
                sorted_clauses_per_engine[i][j].push_back(lit);
            }
        }
    }
    //input sorted data
    //input data from cnf
    int init_uc;
    input_file_trace >> tmp;
    for(int i=0; i<MAX_UC_COUNT; ++i){
        while(tmp != "init_uc" && tmp != "Conflict"){
            input_file_trace >> tmp;
        }
        if(tmp == "Conflict")
            break;
        input_file_trace >> init_uc;
        uc.push_back(init_uc);
        input_file_trace >> tmp;
    }
    int overall_process_time = 0;
    for(int i=0; i<uc.size(); ++i){
        init_uc = uc[i];
        // cout<<"init_uc = "<<init_uc<<" long = "<<longest_process_time(clauses_per_engine, init_uc)<<endl;
        overall_process_time += longest_process_time(clauses_per_engine, init_uc);
    }
    int sorted_overall_process_time = 0;
    for(int i=0; i<uc.size(); ++i){
        init_uc = uc[i];
        // cout<<"init_uc = "<<init_uc<<" long = "<<longest_process_time(clauses_per_engine, init_uc)<<endl;
        sorted_overall_process_time += longest_process_time(sorted_clauses_per_engine, init_uc);
    }

    cout << "Overall_process_time = "<<overall_process_time + uc.size()<<", avg = "<<(float)(overall_process_time+ uc.size())/(float)uc.size()<<endl;
    cout << "Sorted_Overall_process_time = "<<sorted_overall_process_time + uc.size()<<", avg = "<<(float)(sorted_overall_process_time+ uc.size())/(float)uc.size()<<endl;
    cout << "Performance gain = "<<(1-((float)(sorted_overall_process_time+ uc.size())/(float)uc.size())/((float)(overall_process_time+ uc.size())/(float)uc.size()))*100<<" %"<<endl;
    float perf_gain = (1-((float)(sorted_overall_process_time+ uc.size())/(float)uc.size())/((float)(overall_process_time+ uc.size())/(float)uc.size()))*100;
    // float previous_data;
    // cal_sorted_file >> previous_data;
    // // cout<<"previous_data = "<<previous_data<<endl;
    // cal_sorted_file.seekg(ios::beg);
    // cal_sorted_file <<"Num_of_engine "<<num_of_engine<< " Num_of_var "<<num_of_var<< " Perf_gain "<< perf_gain<<endl;
    cal_sorted_file <<num_of_engine<< ","<<num_of_var<< ","<< perf_gain<<endl;
}