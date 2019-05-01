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
    
    always_comb
        if (address >= `TEXT_BEGIN && address <= `TEXT_END)
            data_fetched = fetched;
        else
            data_fetched = 32'hxxxxxxxx;

endmodule

