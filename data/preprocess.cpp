#include <iostream>
#include <fstream> 
#include <vector>   
#include <stdlib.h>
#include <algorithm>

#define SORT

using namespace std;

int num_of_engine;
int num_of_var;
int num_of_clause;
int padding;
int num_clause_per_engine;
int size_of_clause;
vector<vector<int> > clauses;
vector<vector<vector<int> >> clauses_per_engine;
// int cal_padding(int num_of_engine, int num_of_clause){
//     int clause_per_engine = 1;
//     while(clause_per_engine * num_of_engine < num_of_clause){
//         clause_per_engine++;
//     }

//     return clause_per_engine * num_of_engine - num_of_clause;
// }

// int cal_clause_per_engine(int num_of_engine, int num_of_clause){
//     int clause_per_engine = 1;
//     while(clause_per_engine * num_of_engine < num_of_clause){
//         clause_per_engine++;
//     }

//     return clause_per_engine;
// }

uint var(int literal) {
	return abs(literal);
}

// int cal_idx(vector<vector<vector<int>* > > clauses, int var){
//     if(var > clauses.size()){
//         cout<<"Wrong argument in cal_idx"<<endl;
//         return -1;
//     }
//     int previous_clause_cnt = 0;
//     for(int i=0; i<var-1; ++i){
//         previous_clause_cnt += clauses[i].size();
//     }

//     return previous_clause_cnt;
// }

int cal_next_idx(vector<vector<int> > clauses, int start, int var){
  
    if(start >= int(clauses.size() - 1)){
        return -1;
    }
    
    for(int i=start+1; i<clauses.size(); ++i){
        for(int j=0; j<clauses[i].size(); ++j){
            if(clauses[i][j] == var){
                return i;
            }
        }
    }
    return -1;

}

bool compare (const vector<int> &clause_a, const vector<int> &clause_b)
{
    // cout<<"clause_a size = "<<clause_a.size()<<" clause_b size = "<<clause_b.size()<<endl; 
//   for(int i=0; i<clause_a.size(); ++i){
//     cout<<"i = "<<i<<endl;
//     if(clause_a[i] < clause_b[i])
//         return true;
//   }
//   return false;

    // if(clause_a[0] < clause_b[0]){
    //     cout<<"idx = 0"<<endl;
    //     return true;
    // }else if(clause_a[1] < clause_b[1]){
    //     cout<<"idx = 1"<<endl;
    //     return true;
    // }else{
    //     return false;
    // }
    return clause_a[0] < clause_b[0];
}

int main(int argc, char *argv[]){

    if(argc != 4){
        cout<<"Enter wrong number of argument !"<<endl;
        return -1;
    }

    ifstream input_file(argv[2]);
    if(!input_file.is_open()){
        cout<<"ERROR when opening input file !"<<endl;
        return -1;
    }

    ofstream output_file(argv[3]);
    if(!output_file.is_open()){
        cout<<"ERROR when opening output file !"<<endl;
        return -1;
    }

    num_of_engine = atoi(argv[1]);
    
    // Ignore comments
    char c = input_file.get();
	while (c == 'c') {
		while (c != '\n')
			c = input_file.get();
		c = input_file.get();
	}
    
    string aux;
	input_file >> aux >> num_of_var >> num_of_clause;
    // cout<<"num_of_engine = "<<num_of_engine<<" num_of_clause = "<<num_of_clause<<endl;
    num_clause_per_engine = num_of_clause / num_of_engine; 
    padding = num_of_clause - num_clause_per_engine * num_of_engine;

    // cout<<"after num_of_engine = "<<num_of_engine<<" num_of_clause = "<<num_of_clause<<endl;
    output_file << "Num_of_engine "<<num_of_engine<<endl;
    // output_file << "Num_of_clause_per_engine "<<num_clause_per_engine<<endl;
    output_file << "Num_of_padding "<<padding<<endl;
    output_file << "Num_of_var "<<num_of_var<<endl;

    clauses.resize(num_of_clause);
    int literal;
    // load all clauses into clauses vector
    for(int i=0; i<num_of_clause; ++i){
        while (input_file >> literal and literal != 0) {
                clauses[i].push_back(literal);
            }
    }

    // sorting //
    #ifdef SORT
        cout<<"start sort"<<endl;
        sort(clauses.begin(), clauses.end(), compare);
        cout<<"end sort"<<endl;
    #endif
    // sorting //
    output_file << "Num_of_lit_per_clause "<<clauses[0].size()<<endl<<endl;
    clauses_per_engine.resize(num_of_engine);

    for(int i=0; i<num_of_clause; ++i){
        clauses_per_engine[i%num_of_engine].push_back(clauses[i]);
    }
    

    for(int i=0; i<num_of_engine; i++){
        output_file << "Engine_num "<<i<<endl;
        output_file << "Head_node "<<endl;
        for (int k=1; k<num_of_var+1; ++k){
            output_file << k << " ";
            output_file << cal_next_idx(clauses_per_engine[i], -1, k) << endl;
        }
        for (int k=1; k<num_of_var+1; ++k){
            output_file << -k << " ";
            output_file << cal_next_idx(clauses_per_engine[i], -1, -k) << endl;
        }

        output_file << "Clause_node "<<clauses_per_engine[i].size()<<endl;
        for(int j=0; j<clauses_per_engine[i].size(); ++j){
            for(int k=0; k<clauses_per_engine[i][j].size(); ++k){
                output_file << clauses_per_engine[i][j][k] << " ";
                output_file << cal_next_idx(clauses_per_engine[i], j+1, clauses_per_engine[i][j][k])<< " ";
            }
            output_file<<endl;
        }

        output_file<<endl<<endl;
    }

}