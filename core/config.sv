// RISC-V SiMPLE SV -- configuration
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef RV_CONFIG
`define RV_CONFIG

// Select architecture
`define UNICICLO
// `define MULTICICLO
// `define PIPELINE

// Select ISA
`define RV32I

// Select ISA extensions
`define M_MODULE    // multiplication and division
// `define F_MODULE    // floating point operations

// Enable debugging signals
`define DEBUG

// `define TEXT_HEX  "test.rom.vh"
// `define DATA_HEX  "test.ram.vh"

`endif

