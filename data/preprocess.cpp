#include <iostream>
#include <fstream> 
#include <vector>   
#include <stdlib.h>

using namespace std;

int num_of_engine;
int num_of_var;
int num_of_clause;
int padding;
int num_clause_per_engine;
int size_of_clause;
int cal_padding(int num_of_engine, int num_of_clause){
    int clause_per_engine = 1;
    while(clause_per_engine * num_of_engine < num_of_clause){
        clause_per_engine++;
    }

    return clause_per_engine * num_of_engine - num_of_clause;
}

int cal_clause_per_engine(int num_of_engine, int num_of_clause){
    int clause_per_engine = 1;
    while(clause_per_engine * num_of_engine < num_of_clause){
        clause_per_engine++;
    }

    return clause_per_engine;
}

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
    padding = cal_padding(num_of_engine, num_of_clause);
    num_clause_per_engine = cal_clause_per_engine(num_of_engine, num_of_clause);
    // cout<<"after num_of_engine = "<<num_of_engine<<" num_of_clause = "<<num_of_clause<<endl;
    output_file << "Num_of_engine "<<num_of_engine<<endl;
    output_file << "Num_of_clause_per_engine "<<num_clause_per_engine<<endl;
    output_file << "Num_of_padding "<<padding<<endl;
    output_file << "Num_of_var "<<num_of_var<<endl;

    for(int i=0; i<num_of_engine - 1; i++){
        // cout<<"engine = "<<i<<endl;
        vector<vector<int> > clauses;
        clauses.resize(num_clause_per_engine);
        // vector<vector<vector<int>* > > positiveClauses;
        // vector<vector<vector<int>* > > negativeClauses;
        // positiveClauses.resize(num_of_var + 1);
        // negativeClauses.resize(num_of_var + 1);
        int literal;
        for(int j=0; j<num_clause_per_engine; ++j){
            while (input_file >> literal and literal != 0) {
                clauses[j].push_back(literal);
            }
            if(i==0 && j==0){
                size_of_clause = clauses[0].size();
                output_file << "Num_of_literal_per_clause "<<size_of_clause<<endl<<endl;
            }
        }

        output_file << "Engine_num "<<i<<endl;
        output_file << "Head_node "<<endl;
        for (int k=1; k<num_of_var+1; ++k){
            output_file << k << " ";
            output_file << cal_next_idx(clauses, -1, k) << endl;
        }
        for (int k=1; k<num_of_var+1; ++k){
            output_file << -k << " ";
            output_file << cal_next_idx(clauses, -1, -k) << endl;
        }

        for(int j=0; j<num_clause_per_engine; ++j){
            for(int k=0; k<clauses[j].size(); ++k){
                output_file << clauses[j][k] << " ";
                output_file << cal_next_idx(clauses, j+1, clauses[j][k])<< " ";
            }
            output_file<<endl;
        }

        output_file<<endl<<endl;
    }
    
    //last engine with padding
    vector<vector<int> > clauses;
    clauses.resize(num_clause_per_engine-padding);
    
    int literal;
    for(int j=0; j<num_clause_per_engine-padding; ++j){
        if(j<num_clause_per_engine-padding){
            while (input_file >> literal and literal != 0) {
                clauses[j].push_back(literal);
            }
        }
    }

    output_file << "Engine_num "<<num_of_engine-1<<endl;
    output_file << "Head node "<<endl;
    for (int k=1; k<num_of_var+1; ++k){
        output_file << k << " ";
        output_file << cal_next_idx(clauses, -1, k) << endl;
    }
    for (int k=1; k<num_of_var+1; ++k){
        output_file << -k << " ";
        output_file << cal_next_idx(clauses, -1, -k) << endl;
    }

    for(int j=0; j<num_clause_per_engine-padding; ++j){
        for(int k=0; k<clauses[j].size(); ++k){
            output_file << clauses[j][k] << " ";
            output_file << cal_next_idx(clauses, j+1, clauses[j][k])<< " ";
        }
        output_file<<endl;
    }

    for(int j=0; j<padding; ++j){
        for(int k=0; k<size_of_clause; ++k){
            output_file << "0" << " ";
            output_file << "-1" << " ";
        }
        output_file<<endl;
    }


    output_file<<endl<<endl;

}