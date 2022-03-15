`define LIT_INDEX_MAX 1024
`define CLA_LENGTH 3
`timescale 1ns/1ns

typedef logic signed [$clog2(`LIT_INDEX_MAX):0] lit_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;