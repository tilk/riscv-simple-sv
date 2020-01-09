// RISC-V SiMPLE SV -- pipeline controller
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module pipeline_control (
    input  [6:0] inst_opcode,
    input  take_branch,
    input  [1:0] branch_status,
    input  want_stall,
    output logic pc_write_enable,
    output logic no_stall,
    output logic jump_start,
    output logic inject_bubble,
    output logic regfile_write_enable,
    output logic alu_operand_a_select,
    output logic alu_operand_b_select,
    output logic [1:0] alu_op_type,
    output logic data_mem_read_enable,
    output logic data_mem_write_enable,
    output logic [2:0] reg_writeback_select,
    output logic [1:0] next_pc_select
);

    always_comb
        if (branch_status[0])
        case (inst_opcode)
            `OPCODE_BRANCH: next_pc_select = take_branch ? `CTL_PC_PC_IMM : `CTL_PC_PC4_BR;
            `OPCODE_JALR:   next_pc_select = `CTL_PC_RS1_IMM;
            `OPCODE_JAL:    next_pc_select = `CTL_PC_PC_IMM;
            default:        next_pc_select = `CTL_PC_PC4;
        endcase
        else next_pc_select = `CTL_PC_PC4;

    always_comb begin
        pc_write_enable         = 1'b1;
        no_stall                = 1'b1;
        jump_start              = 1'b0;
        inject_bubble           = 1'b0;

        if (want_stall) begin
            pc_write_enable = 1'b0;
            no_stall        = 1'b0;
            inject_bubble   = 1'b1;
        end else case (inst_opcode)
            `OPCODE_BRANCH, `OPCODE_JALR, `OPCODE_JAL:
            begin
                pc_write_enable         = |branch_status;
                no_stall                = branch_status[1];
                jump_start              = !(|branch_status);
            end
            default: ;
        endcase
    end

    always_comb begin
        regfile_write_enable    = 1'b0;
        data_mem_read_enable    = 1'b0;
        data_mem_write_enable   = 1'b0;
        case (inst_opcode)
            `OPCODE_LOAD:
            begin
                regfile_write_enable    = 1'b1;
                data_mem_read_enable    = 1'b1;
            end
            `OPCODE_STORE:
                data_mem_write_enable   = 1'b1;
            `OPCODE_OP, `OPCODE_OP_IMM, `OPCODE_LUI, `OPCODE_AUIPC:
                regfile_write_enable    = 1'b1;
            `OPCODE_JALR, `OPCODE_JAL:
                regfile_write_enable    = !(|branch_status);
            default: ;
        endcase
    end

    always_comb begin
        alu_operand_a_select    = 1'b1; // to avoid useless stalls
        alu_operand_b_select    = 1'b1; // -- || --
        alu_op_type             = 2'bx;
        reg_writeback_select    = 3'bx;
    
        case (inst_opcode)
            `OPCODE_LOAD:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                reg_writeback_select    = `CTL_WRITEBACK_DATA;
            end
    
            `OPCODE_MISC_MEM:
            begin
                // Fence - ignore
            end
    
            `OPCODE_OP_IMM:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_OP_IMM;
                reg_writeback_select    = `CTL_WRITEBACK_ALU;
            end
    
            `OPCODE_AUIPC:
            begin
                alu_operand_a_select    = `CTL_ALU_A_PC;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                reg_writeback_select    = `CTL_WRITEBACK_ALU;
            end
    
            `OPCODE_STORE:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
            end
    
            `OPCODE_OP:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_RS2;
                reg_writeback_select    = `CTL_WRITEBACK_ALU;
                alu_op_type             = `CTL_ALU_OP;
            end
    
            `OPCODE_LUI:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_RS2;
                reg_writeback_select    = `CTL_WRITEBACK_IMM;
            end
    
            `OPCODE_BRANCH:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_RS2;
                alu_op_type             = `CTL_ALU_BRANCH;
            end
    
            `OPCODE_JALR:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                reg_writeback_select    = `CTL_WRITEBACK_PC4;
            end
    
            `OPCODE_JAL:
            begin
                alu_operand_a_select    = `CTL_ALU_A_PC;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                reg_writeback_select    = `CTL_WRITEBACK_PC4;
            end
    
            default: ;
        endcase
    end

endmodule

