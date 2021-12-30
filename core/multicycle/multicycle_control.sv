// RISC-V SiMPLE SV -- multicycle controller
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module multicycle_control (
    input  clock,
    input  reset,

    input [6:0] inst_opcode,
    input take_branch,

    // control signals
    output logic [1:0] alu_op_type,
    output logic alu_operand_a_select,
    output logic [1:0] alu_operand_b_select,
    output logic pc_write_enable,
    output logic alu_out_write_enable,
    output logic inst_write_enable,
    output logic data_write_enable,
    output logic regfile_write_enable,
    output logic mem_write_enable,
    output logic mem_read_enable,
    output logic [2:0] reg_writeback_select,
    output logic inst_or_data,
    output logic next_pc_select
);

    logic [3:0] state;

    `define STATE_FETCH         4'd0
    `define STATE_DECODE        4'd1
    `define STATE_EXECUTE       4'd2
    `define STATE_ALU_WRITEBACK 4'd3
    `define STATE_MEM_ADDR      4'd4
    `define STATE_MEM_READ      4'd5
    `define STATE_MEM_WRITE     4'd6
    `define STATE_MEM_WRITEBACK 4'd7
    `define STATE_BRANCH        4'd8
    `define STATE_LUI           4'd9
    `define STATE_JAL           4'd10
    `define STATE_JALR          4'd11
    `define STATE_EXECUTE_IMM   4'd12

    always_ff @(posedge clock or posedge reset)
        if (reset) state <= `STATE_FETCH;
        else case (state)
            `STATE_FETCH: state <= `STATE_DECODE;
            `STATE_DECODE:
                case (inst_opcode)
                    `OPCODE_LOAD, `OPCODE_STORE: state <= `STATE_MEM_ADDR;
                    `OPCODE_BRANCH: state <= `STATE_BRANCH;
                    `OPCODE_JAL: state <= `STATE_JAL;
                    `OPCODE_JALR: state <= `STATE_JALR;
                    `OPCODE_OP: state <= `STATE_EXECUTE;
                    `OPCODE_OP_IMM: state <= `STATE_EXECUTE_IMM;
                    `OPCODE_LUI: state <= `STATE_LUI;
                    `OPCODE_AUIPC: state <= `STATE_ALU_WRITEBACK;
                    `OPCODE_MISC_MEM: state <= `STATE_FETCH;
                    default: state <= 4'bx;
                endcase
            `STATE_EXECUTE: state <= `STATE_ALU_WRITEBACK;
            `STATE_EXECUTE_IMM: state <= `STATE_ALU_WRITEBACK;
            `STATE_LUI: state <= `STATE_FETCH;
            `STATE_JAL: state <= `STATE_FETCH;
            `STATE_JALR: state <= `STATE_FETCH;
            `STATE_ALU_WRITEBACK: state <= `STATE_FETCH;
            `STATE_MEM_ADDR: 
                case (inst_opcode)
                    `OPCODE_LOAD: state <= `STATE_MEM_READ;
                    `OPCODE_STORE: state <= `STATE_MEM_WRITE;
                    default: state <= 4'bx;
                endcase
            `STATE_MEM_READ: state <= `STATE_MEM_WRITEBACK;
            `STATE_MEM_WRITE: state <= `STATE_FETCH;
            `STATE_MEM_WRITEBACK: state <= `STATE_FETCH;
            `STATE_BRANCH: state <= `STATE_FETCH;
            default: state <= 4'bx;
        endcase

    always_comb
        case (state)
            `STATE_DECODE: pc_write_enable = 1'b1;
            `STATE_BRANCH: pc_write_enable = take_branch;
            `STATE_JAL:    pc_write_enable = 1'b1;
            `STATE_JALR:   pc_write_enable = 1'b1;
            default: pc_write_enable = 1'b0;
        endcase

    always_comb begin
        alu_op_type             = 2'bx;
        alu_out_write_enable    = 1'b0;
        inst_write_enable       = 1'b0;
        data_write_enable       = 1'b0;
        regfile_write_enable    = 1'b0;
        mem_read_enable         = 1'b0;
        mem_write_enable        = 1'b0;
        reg_writeback_select    = 3'bx;
        inst_or_data            = 1'bx;
        alu_operand_a_select    = 1'bx;
        alu_operand_b_select    = 2'bx;
        next_pc_select          = 1'bx;
        case (state)
            `STATE_FETCH: begin
                mem_read_enable         = 1'b1;
                inst_or_data            = 1'b0;
                inst_write_enable       = 1'b1;
                alu_op_type             = `CTL_ALU_ADD;
                alu_operand_a_select    = `CTL_ALU_A_PC;
                alu_operand_b_select    = `MC_CTL_ALU_B_4;
                alu_out_write_enable    = 1'b1;
            end
            `STATE_DECODE: begin
                alu_op_type             = `CTL_ALU_ADD;
                alu_operand_a_select    = `CTL_ALU_A_PC;
                alu_operand_b_select    = `MC_CTL_ALU_B_IMM;
                alu_out_write_enable    = 1'b1;
                next_pc_select          = `MC_CTL_PC_ALU_OUT;
            end
            `STATE_EXECUTE: begin
                alu_out_write_enable    = 1'b1;
                alu_op_type             = `CTL_ALU_OP;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `MC_CTL_ALU_B_RS2;
            end
            `STATE_EXECUTE_IMM: begin
                alu_out_write_enable    = 1'b1;
                alu_op_type             = `CTL_ALU_OP_IMM;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `MC_CTL_ALU_B_IMM;
            end
            `STATE_LUI: begin
                regfile_write_enable    = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_IMM;
            end
            `STATE_ALU_WRITEBACK: begin
                regfile_write_enable    = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_ALU;
            end
            `STATE_MEM_ADDR: begin
                alu_out_write_enable    = 1'b1;
                alu_op_type             = `CTL_ALU_ADD;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `MC_CTL_ALU_B_IMM;
            end
            `STATE_MEM_WRITE: begin
                inst_or_data            = 1'b1;
                mem_write_enable        = 1'b1;
            end
            `STATE_MEM_READ: begin
                inst_or_data            = 1'b1;
                mem_read_enable         = 1'b1;
                data_write_enable       = 1'b1;
            end
            `STATE_MEM_WRITEBACK: begin
                regfile_write_enable    = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_DATA;
            end
            `STATE_BRANCH: begin
                alu_op_type             = `CTL_ALU_BRANCH;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `MC_CTL_ALU_B_RS2;
                next_pc_select          = `MC_CTL_PC_ALU_OUT;
            end
            `STATE_JAL: begin
                regfile_write_enable    = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_PC4;
                next_pc_select          = `MC_CTL_PC_ALU_OUT;
            end
            `STATE_JALR: begin
                regfile_write_enable    = 1'b1;
                reg_writeback_select    = `CTL_WRITEBACK_PC4;
                alu_op_type             = `CTL_ALU_ADD;
                alu_operand_a_select    = `CTL_ALU_A_RS1;
                alu_operand_b_select    = `MC_CTL_ALU_B_IMM;
                next_pc_select          = `MC_CTL_PC_ALU_RES;
            end
            default: begin
                alu_out_write_enable    = 1'bx;
                inst_write_enable       = 1'bx;
                data_write_enable       = 1'bx;
                regfile_write_enable    = 1'bx;
            end
        endcase
    end

endmodule

