#include <iostream>
#include <fstream> 
#include <vector>   
#include <stdlib.h>

using namespace std;

int uc_count = 5723;

int num_of_uc;
vector<int> uc;
string tmp;
int num_of_engine;
int num_of_clause_per_engine;
int num_of_lit_per_clause;
vector<vector<vector<int> >> clauses_per_engine;

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
    if(argc != 3){
        cout<<"Enter wrong number of argument !"<<endl;
        return -1;
    }

    ifstream input_file_cnf(argv[1]);
    if(!input_file_cnf.is_open()){
        cout<<"ERROR when opening input cnf file !"<<endl;
        return -1;
    }

    ifstream input_file_trace(argv[2]);
    if(!input_file_trace.is_open()){
        cout<<"ERROR when opening input trace file !"<<endl;
        return -1;
    }
    //input data from cnf
    input_file_cnf >> tmp;
    while(tmp != "Num_of_engine"){
        input_file_cnf >> tmp;
    }
    input_file_cnf >> num_of_engine;
    clauses_per_engine.resize(num_of_engine);

    input_file_cnf >> tmp;
    while(tmp != "Num_of_lit_per_clause"){
        input_file_cnf >> tmp;
    }
    input_file_cnf >> num_of_lit_per_clause;
    int cur_num_of_clause;
    int lit;
    for(int i=0; i<num_of_engine; ++i){
        input_file_cnf >> tmp;
        while(tmp != "Clause_node"){
            input_file_cnf >> tmp;
        }
        input_file_cnf >> cur_num_of_clause;
        clauses_per_engine[i].resize(cur_num_of_clause);
        for(int j=0; j<cur_num_of_clause; ++j){
            for(int k=0; k<num_of_lit_per_clause; ++k){
                input_file_cnf >> lit;
                input_file_cnf >> tmp;
                clauses_per_engine[i][j].push_back(lit);
            }
        }
    }
    //input data from cnf
    int init_uc;
    input_file_trace >> tmp;
    for(int i=0; i<uc_count; ++i){
        while(tmp != "init_uc"){
            input_file_trace >> tmp;
            // cout<<"tmp = "<<tmp<<endl;
        }
        input_file_trace >> init_uc;
        uc.push_back(init_uc);
        input_file_trace >> tmp;
    }
    cout<<"uc = "<<uc.size()<<endl;
    int overall_process_time = 0;
    for(int i=0; i<uc.size(); ++i){
        init_uc = uc[i];
        overall_process_time += longest_process_time(clauses_per_engine, init_uc);
    }

    cout << "Overall_process_time = "<<overall_process_time + uc.size()<<", avg = "<<(float)(overall_process_time+ uc.size())/(float)uc.size()<<endl;
}