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
    output pc_write_enable,
    output alu_out_write_enable,
    output inst_write_enable,
    output data_write_enable,
    output regfile_write_enable,
    output mem_to_reg,
    output inst_or_data
);

    logic [2:0] alu_op_type;

    multicycle_control multicycle_control(
        .clock                  (clock),
        .reset                  (reset),
        .inst_opcode            (inst_opcode),
        .alu_result_equal_zero  (alu_result_equal_zero),
        .pc_write_enable        (pc_write_enable),
        .alu_out_write_enable   (alu_out_write_enable),
        .inst_write_enable      (inst_write_enable),
        .data_write_enable      (data_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .mem_to_reg             (mem_to_reg),
        .inst_or_data           (inst_or_data),
        .alu_op_type            (alu_op_type)
    );

    alu_control alu_control(
        .alu_op_type        (alu_op_type),
        .inst_funct3        (inst_funct3),
        .inst_funct7        (inst_funct7),
        .alu_function       (alu_function)
    );

endmodule

