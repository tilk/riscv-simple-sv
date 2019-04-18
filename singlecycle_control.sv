// RISC-V SiMPLE SV -- control path
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module singlecycle_control (
    input  [6:0] inst_opcode,
    input  inst_bit_30,             // for ALU op selection
`ifdef M_MODULE
    input  inst_bit_25,             // for multiplication op
`endif

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

// Tabela de tipo de operações da ULA (alu_op_type[2:0])
// 3'b000: Zero
// 3'b001: Add
// 3'b010: Função default
// 3'b011: Função secundária (SUB, SRA, ...)
// 3'b100: Branches (comparações)
// 3'b101: Extensão M

// Tabela de entradas do multiplexador de escrita em rd
// 3'b000: Saída da ULA
// 3'b001: Saída da memória de dados
// 3'b010: PC + 4
// 3'b011: Saída do gerador de imediatos
// Planejadas:
// 3'b100: Dado do registrador de ponto flutuante rs1
// 3'b101: Leitura dos CSR's


    always_comb begin
        pc_write_enable         = 1'b1;
        regfile_write_enable    = 1'b0;
        alu_operand_a_select    = 1'b0;
        alu_operand_b_select    = 1'b0;
        alu_op_type             = 3'b000;
        jal_enable              = 1'b0;
        jalr_enable             = 1'b0;
        branch_enable           = 1'b0;
        data_mem_read_enable    = 1'b0;
        data_mem_write_enable   = 1'b0;
        reg_writeback_select    = 3'b000;
    
        case (inst_opcode)
            `OPCODE_LOAD:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b1;
                alu_op_type             = 3'b001;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b1;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b001;
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
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b0;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b0;
                alu_op_type             = 3'b000;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b000;
            end
    
            `OPCODE_OP_IMM:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b1;
                alu_op_type             = 3'b010;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b000;
            end
    
            `OPCODE_AUIPC:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b1;
                alu_operand_b_select    = 1'b1;
                alu_op_type             = 3'b001;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b000;
            end
    
            `OPCODE_STORE:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b0;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b1;
                alu_op_type             = 3'b001;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b1;
                reg_writeback_select    = 3'b000;
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
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b0;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b000;
    
                if (inst_bit_30 == 1'b1)
                    alu_op_type             = 3'b011;
    `ifdef M_MODULE
                else if (inst_bit_25 == 1'b1)
                    alu_op_type             = 3'b101;
    `endif
                else
                    alu_op_type             = 3'b010;
            end
    
            `OPCODE_LUI:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b0;
                alu_op_type             = 3'b000;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b011;
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
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b0;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b0;
                alu_op_type             = 3'b001;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b1;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b000;
            end
    
            `OPCODE_JALR:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b1;
                alu_op_type             = 3'b001;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b1;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b010;
            end
    
            `OPCODE_JAL:
            begin
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b1;
                alu_operand_a_select    = 1'b1;
                alu_operand_b_select    = 1'b1;
                alu_op_type             = 3'b001;
                jal_enable              = 1'b1;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b010;
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
                pc_write_enable         = 1'b1;
                regfile_write_enable    = 1'b0;
                alu_operand_a_select    = 1'b0;
                alu_operand_b_select    = 1'b0;
                alu_op_type             = 3'b000;
                jal_enable              = 1'b0;
                jalr_enable             = 1'b0;
                branch_enable           = 1'b0;
                data_mem_read_enable    = 1'b0;
                data_mem_write_enable   = 1'b0;
                reg_writeback_select    = 3'b000;
            end
        endcase
    end

endmodule

