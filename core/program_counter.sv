// RISC-V SiMPLE SV -- program counter
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module program_counter (
    input  clock,
    input  reset,
    input  write_enable,
    input  [31:0] next_pc,

    output [31:0] pc
);

   initial pc = `INITIAL_PC;
   
   always_ff @ (posedge clock or posedge reset)
       if (reset) pc <= `INITIAL_PC;
       else if (write_enable) pc <= next_pc;

endmodule
