// RISC-V SiMPLE SV -- control transfer unit
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module control_transfer (
    input  branch_enable,
    input  jal_enable,
    input  jalr_enable,
    input  result_equal_zero,
    input  [2:0] inst_funct3,

    output [1:0] next_pc_select
);

    // Tabela de entradas do multiplexador do próximo PC
    // 2'b00: PC + 4
    // 2'b01: PC + Imediato
    // 2'b10: {(rs1_data + imm)[31:1], 1'b0}
    // Planejado:
    // 2'b11: Nível privilegiado (máquina)
    
    always_comb begin
        if (branch_enable) begin
            next_pc_select = 2'b00;
            case (inst_funct3)
                `FUNCT3_BRANCH_EQ:  next_pc_select = result_equal_zero ? 2'b01 : 2'b00;
                `FUNCT3_BRANCH_NE:  next_pc_select = result_equal_zero ? 2'b00 : 2'b01;
                `FUNCT3_BRANCH_LT:  next_pc_select = result_equal_zero ? 2'b00 : 2'b01;
                `FUNCT3_BRANCH_GE:  next_pc_select = result_equal_zero ? 2'b01 : 2'b00;
                `FUNCT3_BRANCH_LTU: next_pc_select = result_equal_zero ? 2'b00 : 2'b01;
                `FUNCT3_BRANCH_GEU: next_pc_select = result_equal_zero ? 2'b01 : 2'b00;
                default:            next_pc_select = 2'b00;
            endcase
        end
        else if (jal_enable)
            next_pc_select = 2'b01;
        else if (jalr_enable)
            next_pc_select = 2'b10;
        else
            next_pc_select = 2'b00;
    end

endmodule

