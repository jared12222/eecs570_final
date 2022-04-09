#ifndef __CONSTANT_H__
#define __CONSTANT_H__

#include <tlm>
#include <systemc.h>
#include <ostream>
#include <queue>
#include <string>

#define CAUSE_WIDTH 24
#define WIDTH_PER_VAR 8
#define NUMBER_VAR_PER_CLAUSE 3
#define NUMBER_OF_ENGINE 4
#define NUMBER_OF_VAR 100 //need to add 1 since the var start from 1


#define NUMBER_OF_CLAUSE 1000
#define NUMBER_OF_VAR_KIND 100

#define PREEMPTION_CYCLE 3

#define MAX_SIM_CYCLE 2000
// #define TEST

static std::string input_file_path = "/home/wftseng/eecs570_final/lt_model/input_file/test1";
static std::string output_file_path = "/home/wftseng/eecs570_final/lt_model/output_file/test1_trace";

#endif