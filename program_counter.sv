// RISC-V SiMPLE SV -- program counter
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module program_counter (
    input  clock,
    input  reset,
    input  write_enable,
    input  [31:0] next_pc,

    output reg [31:0] pc
);

initial begin
    pc <= `INITIAL_PC;
end

always @ (posedge clock or posedge reset) begin
    // Reseta o contador de programa
    if (reset) begin
        pc <= `INITIAL_PC;
    end

    // Habilta a escrita de PC
    else if (write_enable) begin
        pc <= next_pc;
    end
end

endmodule
