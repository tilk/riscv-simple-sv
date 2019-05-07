// RISC-V SiMPLE SV -- control transfer unit
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module control_transfer (
    input  branch_enable,
    input  jal_enable,
    input  jalr_enable,
    input  result_equal_zero,
    input  [2:0] inst_funct3,

    output logic [1:0] next_pc_select
);

    always_comb begin
        next_pc_select = `CTL_PC_PC4;
        if (branch_enable)
            case (inst_funct3)
                `FUNCT3_BRANCH_EQ:  next_pc_select = result_equal_zero ? `CTL_PC_PC_IMM : `CTL_PC_PC4;
                `FUNCT3_BRANCH_NE:  next_pc_select = result_equal_zero ? `CTL_PC_PC4    : `CTL_PC_PC_IMM;
                `FUNCT3_BRANCH_LT:  next_pc_select = result_equal_zero ? `CTL_PC_PC4    : `CTL_PC_PC_IMM;
                `FUNCT3_BRANCH_GE:  next_pc_select = result_equal_zero ? `CTL_PC_PC_IMM : `CTL_PC_PC4;
                `FUNCT3_BRANCH_LTU: next_pc_select = result_equal_zero ? `CTL_PC_PC4    : `CTL_PC_PC_IMM;
                `FUNCT3_BRANCH_GEU: next_pc_select = result_equal_zero ? `CTL_PC_PC_IMM : `CTL_PC_PC4;
                default: next_pc_select = 2'bx;
            endcase
        else if (jal_enable)
            next_pc_select = `CTL_PC_PC_IMM;
        else if (jalr_enable)
            next_pc_select = `CTL_PC_RS1_IMM;
    end

endmodule

