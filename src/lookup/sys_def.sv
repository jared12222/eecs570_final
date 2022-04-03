// Shared macros
`define LIT_IDX_MAX 1024

// Clause Arbiter
`define NUM_CLAUSE	8

// Engine and Clause
`define CLA_LENGTH 3

typedef logic signed [$clog2(`LIT_IDX_MAX):0] lit_t;
typedef lit_t [`CLA_LENGTH-1:0] cla_t;

// Unit Clause
`define NUM_ENGINE 1
`define MAX_UC 64
`define UCQ_SIZE 16

// Unit Clause Arbiter
typedef enum logic [1:0] {
	UCARB_IDLE  = 2'b00,
	UCARB_READY = 2'b01,
	UCARB_PROC  = 2'b10,
    UCARB_DONE  = 2'b11
} uc_arb_t;

// Clause Queue
`define CLQ_DEPTH 64

// Pointer for a given literal
typedef logic [$clog2(`CLQ_DEPTH)-1:0] ptr_t;

// Stores the clause and its pointer of all literals
typedef struct packed {
    cla_t cla;
    ptr_t [`CLA_LENGTH-1:0] ptr;
} node_t;

// Structure that stores all dummy heads
typedef ptr_t [2*`LIT_IDX_MAX-1:0] dummy_ptr_t;

// Define state of literals
typedef enum logic [1:0] { 
    UNDEFINED = 2'b00,
    TRUE      = 2'b01,
    FALSE     = 2'b10,
    CONFLICT  = 2'b11
} lit_state_t;

// Structure (table) that stores all literal states
typedef lit_state_t [`LIT_IDX_MAX-1:0] lit_table_t;

// BCP PE
typedef enum logic [1:0] {
    BCP_IDLE  = 2'b00,
    BCP_PROC  = 2'b01,
    BCP_DONE  = 2'b11
} bcp_state_t;


`timescale 1ns/1ns