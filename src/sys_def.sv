// Shared macros
`define LIT_IDX_MAX 1024

// Engine and Clause
`define CLA_LENGTH 3

// Unit Clause
`define NUM_ENGINE 1
`define MAX_UC 64
`define UCQ_SIZE 16

// Clause Queue
`define CLQ_DEPTH 64

`timescale 1ns/1ns

typedef logic signed [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;