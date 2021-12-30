// RISC-V SiMPLE SV -- Multicycle RISC-V core
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module riscv_core (
    input  clock,
    input  reset,

    output [31:0] bus_address,
    input  [31:0] bus_read_data,
    output [31:0] bus_write_data,
    output [3:0]  bus_byte_enable,
    output        bus_read_enable,
    output        bus_write_enable,

    output [31:0] inst,
    output [31:0] pc
);

    logic [4:0] alu_function;
    logic pc_write_enable;
    logic next_pc_select;
    logic alu_out_write_enable;
    logic alu_operand_a_select;
    logic [1:0] alu_operand_b_select;
    logic inst_write_enable;
    logic data_write_enable;
    logic regfile_write_enable;
    logic [2:0] reg_writeback_select;
    logic inst_or_data;
    logic [6:0] inst_opcode;
    logic [2:0] inst_funct3;
    logic [6:0] inst_funct7;
    logic alu_result_equal_zero;
    logic [31:0] address;
    logic [31:0] read_data;
    logic [31:0] write_data;
    logic [2:0] data_format;
    logic read_enable;
    logic write_enable;

    multicycle_datapath multicycle_datapath (
        .clock                  (clock),
        .reset                  (reset),
        .alu_function           (alu_function),
        .alu_operand_a_select   (alu_operand_a_select),
        .alu_operand_b_select   (alu_operand_b_select),
        .next_pc_select         (next_pc_select),
        .pc_write_enable        (pc_write_enable),
        .alu_out_write_enable   (alu_out_write_enable),
        .inst_write_enable      (inst_write_enable),
        .data_write_enable      (data_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .reg_writeback_select   (reg_writeback_select),
        .inst_or_data           (inst_or_data),
        .mem_address            (address),
        .mem_read_data          (read_data),
        .mem_write_data         (write_data),
        .pc                     (pc),
        .inst                   (inst),
        .inst_opcode            (inst_opcode),
        .inst_funct3            (inst_funct3),
        .inst_funct7            (inst_funct7),
        .alu_result_equal_zero  (alu_result_equal_zero)
    );

    multicycle_ctlpath multicycle_ctlpath(
        .clock                  (clock),
        .reset                  (reset),
        .alu_function           (alu_function),
        .alu_operand_a_select   (alu_operand_a_select),
        .alu_operand_b_select   (alu_operand_b_select),
        .next_pc_select         (next_pc_select),
        .pc_write_enable        (pc_write_enable),
        .alu_out_write_enable   (alu_out_write_enable),
        .inst_write_enable      (inst_write_enable),
        .data_write_enable      (data_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .reg_writeback_select   (reg_writeback_select),
        .inst_or_data           (inst_or_data),
        .inst_opcode            (inst_opcode),
        .inst_funct3            (inst_funct3),
        .inst_funct7            (inst_funct7),
        .alu_result_equal_zero  (alu_result_equal_zero),
        .mem_read_enable        (read_enable),
        .mem_write_enable       (write_enable),
        .data_format            (data_format)
    );

    data_memory_interface data_memory_interface (
        .clock                  (clock),
        .read_enable            (read_enable),
        .write_enable           (write_enable),
        .data_format            (data_format),
        .address                (address),
        .write_data             (write_data),
        .read_data              (read_data),
        .bus_address            (bus_address),
        .bus_read_data          (bus_read_data),
        .bus_write_data         (bus_write_data),
        .bus_read_enable        (bus_read_enable),
        .bus_write_enable       (bus_write_enable),
        .bus_byte_enable        (bus_byte_enable)
    );

endmodule

