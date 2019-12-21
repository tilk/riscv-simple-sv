// RISC-V SiMPLE SV -- configuration for testbench
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef RV_CONFIG
`define RV_CONFIG

// Select architecture
// `define SINGLE_CYCLE
`define MULTI_CYCLE
// `define PIPELINE

// Select ISA
`define RV32I

// Select ISA extensions
// `define M_MODULE    // multiplication and division
// `define F_MODULE    // floating point operations

// Enable debugging signals
`define DEBUG

//////////////////////////////////////////
//              Memory config           //
//////////////////////////////////////////

// Program counter initial value
`define INITIAL_PC      32'h00400000

// Instruction memory
`define TEXT_BEGIN      `INITIAL_PC
`define TEXT_BITS       16
`define TEXT_WIDTH      2**`TEXT_BITS
`define TEXT_END        `TEXT_BEGIN + `TEXT_WIDTH - 1

// Data memory
`define DATA_BEGIN      32'h8000_0000
`define DATA_BITS       17
`define DATA_WIDTH      2**`DATA_BITS
`define DATA_END        `DATA_BEGIN + `DATA_WIDTH - 1

// Stack start
`define STACK_ADDRESS   `DATA_END - 3

`define TEXT_HEX  text_mem_file()
`define DATA_HEX  data_mem_file()

function string text_mem_file ();
    string s;
    if ($value$plusargs("text_file=%s", s) != 0)
        return s;
    else begin
        $display("Text memory file not supplied.");
        $finish;
    end
endfunction

function string data_mem_file ();
    string s;
    if ($value$plusargs("data_file=%s", s) != 0)
        return s;
    else begin
        $display("Data memory file not supplied.");
        $finish;
    end
endfunction

`endif
