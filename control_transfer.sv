///////////////////////////////////////////////////////////////////////////////
//            RISC-V SiMPLE - Unidade de Transferência de Controle           //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module control_transfer (
    input  branch_enable,           // Instrução == Branch
    input  jal_enable,              // Instrução == JAL
    input  jalr_enable,             // Instrução == JALR
    input  result_equal_zero,       // Sinal de resultado da ULA == 64'b0
    input  [2:0] inst_funct3,       // Campo funct3 da instrução

    output reg [1:0] next_pc_select // Seletor do multiplexer de próximo PC
);

// Tabela de entradas do multiplexador do próximo PC
// 2'b00: PC + 4
// 2'b01: PC + Imediato
// 2'b10: {(rs1_data + imm)[31:1], 1'b0}
// Planejado:
// 2'b11: Nível privilegiado (máquina)

always @ ( * ) begin
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
    else if (jal_enable) begin
        next_pc_select = 2'b01;
    end
    else if (jalr_enable) begin
        next_pc_select = 2'b10;
    end
    else begin
        next_pc_select = 2'b00;
    end
end

endmodule

