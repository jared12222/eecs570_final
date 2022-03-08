#include "constant.h"

// data_per_clause& data_per_clause::operator=(const data_per_clause& rhs) {
//     for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i)
//         row[i] = rhs.row[i];
//     return *this;
// }

// bool operator==(const data_per_clause& lhs, const data_per_clause& rhs) {
//     for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i){
//         if(lhs.row[i] != rhs.row[i])
//             return false;
//     }
//     return true;
// }

// std::ostream& operator<<(std::ostream& os, const data_per_clause& val) {
//     os << "Literals per clause = ";
//     for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i)
//         os << val.row[i] <<", " ;
//     os << std::endl;
//     return os;
// }

// // void sc_trace(sc_trace_file& f, const data_per_clause& val, std::string name) {
// //     for(int i=0; i<NUMBER_VAR_PER_CLAUSE; ++i)
// //         sc_trace(f, val.row[i], name+str(i));
// // }