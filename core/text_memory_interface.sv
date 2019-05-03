// RISC-V SiMPLE SV -- program text memory interface
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module text_memory_interface (
    input  clock,
    input  [31:0] address,
    output [31:0] data_fetched
);

    logic [31:0] fetched;
    
    text_memory text_memory(
        .address    (address[15:2]),
        .clock      (clock),
        .q          (fetched)
    );
   
    assign data_fetched = 
        address >= `TEXT_BEGIN && address <= `TEXT_END
        ? fetched
        : 32'hxxxxxxxx;

endmodule

