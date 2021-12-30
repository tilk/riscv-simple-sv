// RISC-V SiMPLE SV -- multicycle control path
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module multicycle_ctlpath (
    input  clock,
    input  reset,

    input [6:0] inst_opcode,
    input [2:0] inst_funct3,
    input [6:0] inst_funct7,
    input alu_result_equal_zero,

    // control signals
    output [4:0] alu_function,
    output alu_operand_a_select,
    output [1:0] alu_operand_b_select,
    output next_pc_select,
    output pc_write_enable,
    output alu_out_write_enable,
    output inst_write_enable,
    output data_write_enable,
    output regfile_write_enable,
    output mem_read_enable,
    output mem_write_enable,
    output [2:0] reg_writeback_select,
    output inst_or_data,
    output [2:0] data_format
);

    logic [1:0] alu_op_type;
    logic take_branch;

    multicycle_control multicycle_control(
        .clock                  (clock),
        .reset                  (reset),
        .inst_opcode            (inst_opcode),
        .pc_write_enable        (pc_write_enable),
        .alu_out_write_enable   (alu_out_write_enable),
        .alu_operand_a_select   (alu_operand_a_select),
        .alu_operand_b_select   (alu_operand_b_select),
        .inst_write_enable      (inst_write_enable),
        .data_write_enable      (data_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .mem_read_enable        (mem_read_enable),
        .mem_write_enable       (mem_write_enable),
        .reg_writeback_select   (reg_writeback_select),
        .inst_or_data           (inst_or_data),
        .alu_op_type            (alu_op_type),
        .next_pc_select         (next_pc_select),
        .take_branch            (take_branch)
    );

    control_transfer control_transfer (
        .result_equal_zero  (alu_result_equal_zero),
        .inst_funct3        (inst_funct3),
        .take_branch        (take_branch)
    );

    alu_control alu_control(
        .alu_op_type        (alu_op_type),
        .inst_funct3        (inst_funct3),
        .inst_funct7        (inst_funct7),
        .alu_function       (alu_function)
    );

    assign data_format = inst_or_data ? inst_funct3 : 3'b010;

endmodule

