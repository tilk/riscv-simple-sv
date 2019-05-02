// RISC-V SiMPLE SV -- ALU controller module
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module alu_control (
    input  [2:0] alu_op_type,
    input  [2:0] inst_funct3,
    output [4:0] alu_function
);

    logic [4:0] default_funct;
    logic [4:0] secondary_funct;
    logic [4:0] branch_funct;
    `ifdef M_MODULE
        logic [4:0] m_extension_funct;
    `endif
    
    always_comb begin
        case (alu_op_type)
            `CTL_ALU_ZERO:          alu_function = `ALU_ZERO;
            `CTL_ALU_ADD:           alu_function = `ALU_ADD;
            `CTL_ALU_DEFAULT:       alu_function = default_funct;
            `CTL_ALU_SECONDARY:     alu_function = secondary_funct;
            `CTL_ALU_BRANCH:        alu_function = branch_funct;
    `ifdef M_MODULE
            `CTL_ALU_M_EXTENSION:   alu_function = m_extension_funct;
    `endif
            default:                alu_function = 5'bx;
        endcase
    end
    
    always_comb begin
        case (inst_funct3)
            `FUNCT3_ALU_ADD_SUB:    default_funct = `ALU_ADD;
            `FUNCT3_ALU_SLL:        default_funct = `ALU_SLL;
            `FUNCT3_ALU_SLT:        default_funct = `ALU_SLT;
            `FUNCT3_ALU_SLTU:       default_funct = `ALU_SLTU;
            `FUNCT3_ALU_XOR:        default_funct = `ALU_XOR;
            `FUNCT3_ALU_SHIFTR:     default_funct = `ALU_SRL;
            `FUNCT3_ALU_OR:         default_funct = `ALU_OR;
            `FUNCT3_ALU_AND:        default_funct = `ALU_AND;
            default:                default_funct = `ALU_ZERO;
        endcase
    end
    
    always_comb begin
        case (inst_funct3)
            `FUNCT3_ALU_ADD_SUB:    secondary_funct = `ALU_SUB;
            `FUNCT3_ALU_SHIFTR:     secondary_funct = `ALU_SRA;
            default:                secondary_funct = 5'bx;
        endcase
    end
    
    always_comb begin
        case (inst_funct3)
            `FUNCT3_BRANCH_EQ:  branch_funct = `ALU_SUB;
            `FUNCT3_BRANCH_NE:  branch_funct = `ALU_SUB;
            `FUNCT3_BRANCH_LT:  branch_funct = `ALU_SLT;
            `FUNCT3_BRANCH_GE:  branch_funct = `ALU_SLT;
            `FUNCT3_BRANCH_LTU: branch_funct = `ALU_SLTU;
            `FUNCT3_BRANCH_GEU: branch_funct = `ALU_SLTU;
            default:            branch_funct = 5'bx;
        endcase
    end
    
    `ifdef M_MODULE
        always_comb begin
            case (inst_funct3)
                `FUNCT3_ALU_MUL:    m_extension_funct = `ALU_MUL;
                `FUNCT3_ALU_MULH:   m_extension_funct = `ALU_MULH;
                `FUNCT3_ALU_MULHSU: m_extension_funct = `ALU_MULHSU;
                `FUNCT3_ALU_MULHU:  m_extension_funct = `ALU_MULHU;
                `FUNCT3_ALU_DIV:    m_extension_funct = `ALU_DIV;
                `FUNCT3_ALU_DIVU:   m_extension_funct = `ALU_DIVU;
                `FUNCT3_ALU_REM:    m_extension_funct = `ALU_REM;
                `FUNCT3_ALU_REMU:   m_extension_funct = `ALU_REMU;
                default:            m_extension_funct = 5'bx;
            endcase
        end
    `endif

endmodule

