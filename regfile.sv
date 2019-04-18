// RISC-V SiMPLE SV -- register file
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module regfile (
    input  clock,
    input  reset,
    input  write_enable,        // Habilita a escrita no banco de registradores
    input  [4:0] rd_address,    // Endereço do registrador rd
    input  [4:0] rs1_address,   // Endereço do registrador rs1
    input  [4:0] rs2_address,   // Endereço do registrador rs2
    input  [31:0] rd_data,      // Dado a ser gravado no registrador rd
    output [31:0] rs1_data,     // Dado lido do registrador rs1
    output [31:0] rs2_data      // Dado lido do registrador rs2
);

    // 32 registers of 32-bit width
    logic [31:0] register [0:31];
    
    // Loop counter
    integer i;
    
    initial
        for (i = 0; i <= 31; i = i + 1) begin
            register[i] <= 32'b0;
        end
    
    assign rs1_data = register[rs1_address];
    assign rs2_data = register[rs2_address];
    
    always_ff @(posedge clock or posedge reset)
        if (reset)
            for (i = 0; i <= 31; i = i + 1)
                register[i] <= 32'b0;
        else if (write_enable)
            if (rd_address != 5'b0) register[rd_address] <= rd_data;
            else                    register[rd_address] <= 32'b0;

endmodule

