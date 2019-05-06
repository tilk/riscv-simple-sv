// RISC-V SiMPLE SV -- text memory model
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module example_text_memory (
	input [`TEXT_BITS-3:0] address,
    input clock,
	output [31:0] q
);

    reg [7:0] mem[0:2**`TEXT_BITS-1];

    assign q = { mem[{address,2'd3}], mem[{address,2'd2}], mem[{address,2'd1}], mem[{address,2'd0}] };

`ifdef TEXT_HEX
    initial $readmemh(`TEXT_HEX, mem);
`endif

endmodule

