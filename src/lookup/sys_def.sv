// Shared macros
`define LIT_IDX_MAX 1024

// Clause Arbiter
`define NUM_CLAUSE	8

// Engine and Clause
`define CLA_LENGTH 3

typedef logic signed [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;

// Unit Clause
`define NUM_ENGINE 4
`define MAX_UC 64
`define UCQ_SIZE 16

// Clause Queue
`define CLQ_DEPTH 64
typedef struct packed {
    cla_t cla,
    logic [`CLA_LENGTH-1:0][$clog2(`CLQ_SIZE)-1:0] ptr
} list_t;

`timescale 1ns/1ns
