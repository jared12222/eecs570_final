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
  
    if(start >= int(clauses.size())){
        return 0;
    }
    
    for(int i=start; i<clauses.size(); ++i){
        for(int j=0; j<clauses[i].size(); ++j){
            if(clauses[i][j] == var){
                return i;
            }
        }
    }
    return 0;

}

int cal_next_idx_header(vector<vector<int> > clauses, int start, int var){
  
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

bool compare_0 (const vector<int> &clause_a, const vector<int> &clause_b)
{
    return clause_a[0] < clause_b[0];
}

bool compare_1 (const vector<int> &clause_a, const vector<int> &clause_b)
{
    return clause_a[1] < clause_b[1];
}

bool compare_2 (const vector<int> &clause_a, const vector<int> &clause_b)
{
    return clause_a[2] < clause_b[2];
}

int next_idx(vector<vector<int> > clauses, int start, int dimension){
    int init = clauses[start][dimension];
    
    for(int i=start+1; i<clauses.size(); ++i){
        if(clauses[i][dimension] != init){
            return i;
        }
    }
    return clauses.size();
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
    padding = num_of_engine - (num_of_clause - num_clause_per_engine * num_of_engine);
    if(num_of_clause%num_of_engine != 0)
        num_clause_per_engine++;
    // cout<<"after num_of_engine = "<<num_of_engine<<" num_of_clause = "<<num_of_clause<<endl;
    output_file << "Num_of_engine "<<num_of_engine<<endl;
    output_file << "Num_of_clause_per_engine "<<num_clause_per_engine<<endl;
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
        sort(clauses.begin(), clauses.end(), compare_0);
        cout<<"finish 1st sort"<<endl;
        // sort(clauses.begin()+0, clauses.begin()+2, compare_1);
        for(int i=0; i<clauses.size(); ++i){
            int end_idx = next_idx(clauses, i, 0);
            sort(clauses.begin()+i, clauses.begin()+end_idx, compare_1);
        }
        cout<<"finish 2nd sort"<<endl;
        for(int i=0; i<clauses.size(); ++i){
            int end_idx = next_idx(clauses, i, 1);
            sort(clauses.begin()+i, clauses.begin()+end_idx, compare_2);
        }

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
            output_file << cal_next_idx_header(clauses_per_engine[i], -1, k) << endl;
        }
        for (int k=1; k<num_of_var+1; ++k){
            output_file << -k << " ";
            output_file << cal_next_idx_header(clauses_per_engine[i], -1, -k) << endl;
        }

        // output_file << "Clause_node "<<clauses_per_engine[i].size()<<endl;
        for(int j=0; j<clauses_per_engine[i].size(); ++j){
            for(int k=0; k<clauses_per_engine[i][j].size(); ++k){
                output_file << clauses_per_engine[i][j][k] << " ";
                output_file << cal_next_idx(clauses_per_engine[i], j+1, clauses_per_engine[i][j][k])<< " ";
            }
            output_file<<endl;
        }

        if(i >= num_of_engine - padding){
            for(int j=0; j<clauses_per_engine[i][0].size(); ++j){
                output_file << "0 -1 ";
            }
        }
        output_file<<endl<<endl;
    }

}