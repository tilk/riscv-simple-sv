// RISC-V SiMPLE SV -- data memory model
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module data_memory (
	input [`DATA_BITS-3:0] address,
	input [3:0] byteena,
	input clock,
	input [31:0] data,
	input wren,
	output [31:0] q
);

    logic [7:0] mem[0:2**`DATA_BITS-1];

    assign q = { mem[{address,2'd3}], mem[{address,2'd2}], mem[{address,2'd1}], mem[{address,2'd0}] };

    always_ff @(posedge clock)
        if (wren) begin
            if (byteena[0]) mem[{address,2'd0}] <= data[0+:8];
            if (byteena[1]) mem[{address,2'd1}] <= data[8+:8];
            if (byteena[2]) mem[{address,2'd2}] <= data[16+:8];
            if (byteena[3]) mem[{address,2'd3}] <= data[24+:8];
        end

`ifdef DATA_HEX
    initial $readmemh(`DATA_HEX, mem);
`endif

endmodule

