// RISC-V SiMPLE SV -- control path
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module singlecycle_control (
    input  [6:0] inst_opcode,
    output pc_write_enable,
    output regfile_write_enable,
    output alu_operand_a_select,
    output alu_operand_b_select,
    output [2:0] alu_op_type,
    output jal_enable,
    output jalr_enable,
    output branch_enable,
    output data_mem_read_enable,
    output data_mem_write_enable,
    output [2:0] reg_writeback_select
);

    always_comb begin
        pc_write_enable         = 1'b1;
        regfile_write_enable    = 1'b0;
        alu_operand_a_select    = 1'b0;
        alu_operand_b_select    = 1'b0;
        alu_op_type             = `CTL_ALU_ZERO;
        jal_enable              = 1'b0;
        jalr_enable             = 1'b0;
        branch_enable           = 1'b0;
        data_mem_read_enable    = 1'b0;
        data_mem_write_enable   = 1'b0;
        reg_writeback_select    = `CTL_WRITEBACK_ALU;
    
        case (inst_opcode)
            `OPCODE_LOAD:
            begin
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                data_mem_read_enable    = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_DATA;
            end
    
            // // `OPCODE_LOAD_FP:
            // begin
            //     pc_write_enable         = 1'b1;
            //     regfile_write_enable    = 1'b0;
            //     alu_operand_a_select    = 1'b0;
            //     alu_operand_b_select    = 1'b0;
            //     alu_op_type             = 3'b000;
            //     jal_enable              = 1'b0;
            //     jalr_enable             = 1'b0;
            //     branch_enable           = 1'b0;
            //     data_mem_read_enable    = 1'b0;
            //     data_mem_write_enable   = 1'b0;
            //     reg_writeback_select    = 3'b000;
            // end
    
            `OPCODE_MISC_MEM:
            begin
                // Fence - Ignorado, mas não causa exceção
            end
    
            `OPCODE_OP_IMM:
            begin
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_OP_IMM;
                reg_writeback_select    = `CTL_WRITEBACK_ALU;
            end
    
            `OPCODE_AUIPC:
            begin
                regfile_write_enable    = 1'b1;
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
                data_mem_write_enable   = 1'b1;
            end
    
            // // `OPCODE_STORE_FP:
            // begin
            //     pc_write_enable         = 1'b1;
            //     regfile_write_enable    = 1'b0;
            //     alu_operand_a_select    = 1'b0;
            //     alu_operand_b_select    = 1'b0;
            //     alu_op_type             = 3'b000;
            //     jal_enable              = 1'b0;
            //     jalr_enable             = 1'b0;
            //     branch_enable           = 1'b0;
            //     data_mem_read_enable    = 1'b0;
            //     data_mem_write_enable   = 1'b0;
            //     reg_writeback_select    = 3'b000;
            // end
    
            `OPCODE_OP:
            begin
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_RS2;
                reg_writeback_select    = `CTL_WRITEBACK_ALU;
                alu_op_type             = `CTL_ALU_OP;
            end
    
            `OPCODE_LUI:
            begin
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_RS2;
                alu_op_type             = `CTL_ALU_ZERO;
                reg_writeback_select    = `CTL_WRITEBACK_IMM;
            end
    
            // // `OPCODE_OP_FP:
            // begin
            //     pc_write_enable         = 1'b1;
            //     regfile_write_enable    = 1'b0;
            //     alu_operand_a_select    = 1'b0;
            //     alu_operand_b_select    = 1'b0;
            //     alu_op_type             = 3'b000;
            //     jal_enable              = 1'b0;
            //     jalr_enable             = 1'b0;
            //     branch_enable           = 1'b0;
            //     data_mem_read_enable    = 1'b0;
            //     data_mem_write_enable   = 1'b0;
            //     reg_writeback_select    = 3'b000;
            // end
    
            `OPCODE_BRANCH:
            begin
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_RS2;
                alu_op_type             = `CTL_ALU_BRANCH;
                branch_enable           = 1'b1;
            end
    
            `OPCODE_JALR:
            begin
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                jalr_enable             = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_PC4;
            end
    
            `OPCODE_JAL:
            begin
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = `CTL_ALU_A_PC;
                alu_operand_b_select    = `CTL_ALU_B_IMM;
                alu_op_type             = `CTL_ALU_ADD;
                jal_enable              = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_PC4;
            end
    
            // // `OPCODE_SYSTEM:
            // begin
            //     pc_write_enable         = 1'b1;
            //     regfile_write_enable    = 1'b0;
            //     alu_operand_a_select    = 1'b0;
            //     alu_operand_b_select    = 1'b0;
            //     alu_op_type             = 3'b000;
            //     jal_enable              = 1'b0;
            //     jalr_enable             = 1'b0;
            //     branch_enable           = 1'b0;
            //     data_mem_read_enable    = 1'b0;
            //     data_mem_write_enable   = 1'b0;
            //     reg_writeback_select    = 3'b000;
            // end
            
            default:
            begin
                pc_write_enable         = 1'bx;
                regfile_write_enable    = 1'bx;
                alu_operand_a_select    = 1'bx;
                alu_operand_b_select    = 1'bx;
                alu_op_type             = 3'bx;
                jal_enable              = 1'bx;
                jalr_enable             = 1'bx;
                branch_enable           = 1'bx;
                data_mem_read_enable    = 1'bx;
                data_mem_write_enable   = 1'bx;
                reg_writeback_select    = 3'bx;
            end
        endcase
    end

endmodule

