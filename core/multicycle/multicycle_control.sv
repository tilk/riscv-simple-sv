// RISC-V SiMPLE SV -- multicycle controller
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module multicycle_control (
    input  clock,
    input  reset,

    input [6:0] inst_opcode,
    input alu_result_equal_zero,

    // control signals
    output logic [2:0] alu_op_type,
    output logic pc_write_enable,
    output logic alu_out_write_enable,
    output logic inst_write_enable,
    output logic data_write_enable,
    output logic regfile_write_enable,
    output logic mem_to_reg,
    output logic inst_or_data
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

    always_ff @(posedge clock or posedge reset)
        if (reset) state <= `STATE_FETCH;
        else case (state)
            `STATE_FETCH: state <= `STATE_DECODE;
            `STATE_DECODE:
                case (inst_opcode)
                    `OPCODE_LOAD, `OPCODE_STORE: state <= `STATE_MEM_ADDR;
                    `OPCODE_BRANCH: state <= `STATE_BRANCH;
                    `OPCODE_OP: state <= `STATE_EXECUTE;
                    default: state <= 4'bx;
                endcase
            `STATE_EXECUTE: state <= `STATE_ALU_WRITEBACK;
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

    always_comb begin
        alu_op_type             = 3'bx;
        pc_write_enable         = 1'b0;
        alu_out_write_enable    = 1'b0;
        inst_write_enable       = 1'b0;
        data_write_enable       = 1'b0;
        regfile_write_enable    = 1'b0;
        mem_to_reg              = 1'bx;
        inst_or_data            = 1'bx;
        case (state)
            `STATE_FETCH: begin
                inst_or_data            = 1'b0;
                inst_write_enable       = 1'b1;
                /* TODO increment program counter */
            end
            default: begin
                pc_write_enable         = 1'bx;
                alu_out_write_enable    = 1'bx;
                inst_write_enable       = 1'bx;
                data_write_enable       = 1'bx;
                regfile_write_enable    = 1'bx;
            end
        endcase
    end

endmodule

