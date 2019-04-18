// RISC-V SiMPLE SV -- RISC-V core
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module riscv_core (
    input  clock,
    input  reset,

    output [31:0] bus_data_fetched,
    output [31:0] bus_address,
    output [31:0] bus_write_data,
    output [2:0]  bus_format,
    output bus_read_enable,
    output bus_write_enable,

    output [31:0] inst,
    output [31:0] pc
);

    wire pc_write_enable;
    wire regfile_write_enable;
    wire alu_operand_a_select;
    wire alu_operand_b_select;
    wire jal_enable;
    wire jalr_enable;
    wire branch_enable;
    wire [2:0] alu_op_type;
    wire [2:0] reg_writeback_select;

singlecycle_datapath singlecycle_datapath (
    .clock                  (clock),
    .reset                  (reset),
    .data_mem_data_fetched  (bus_data_fetched),
    .data_mem_address       (bus_address),
    .data_mem_write_data    (bus_write_data),
    .data_mem_format        (bus_format),
    .inst                   (inst),
    .pc                     (pc),
    .pc_write_enable        (pc_write_enable),
    .regfile_write_enable   (regfile_write_enable),
    .alu_operand_a_select   (alu_operand_a_select),
    .alu_operand_b_select   (alu_operand_b_select),
    .alu_op_type            (alu_op_type),
    .jal_enable             (jal_enable),
    .jalr_enable            (jalr_enable),
    .branch_enable          (branch_enable),
    .reg_writeback_select   (reg_writeback_select)
);

singlecycle_control singlecycle_control(
    .inst_opcode            (inst[6:0]),
    .inst_bit_30            (inst[30]),
`ifdef M_MODULE
    .inst_bit_25            (inst[25]),
`endif
    .pc_write_enable        (pc_write_enable),
    .regfile_write_enable   (regfile_write_enable),
    .alu_operand_a_select   (alu_operand_a_select),
    .alu_operand_b_select   (alu_operand_b_select),
    .alu_op_type            (alu_op_type),
    .jal_enable             (jal_enable),
    .jalr_enable            (jalr_enable),
    .branch_enable          (branch_enable),
    .data_mem_read_enable   (bus_read_enable),
    .data_mem_write_enable  (bus_write_enable),
    .reg_writeback_select   (reg_writeback_select)
);

data_memory_interface data_memory_interface (
    .clock                  (clock),
    .core_clock             (clock),
    .read_enable            (bus_read_enable),
    .write_enable           (bus_write_enable),
    .data_format            (inst[14:12]),
    .address                (bus_address),
    .write_data             (bus_write_data),
    .data_fetched           (bus_data_fetched)
);

text_memory_interface text_memory_interface (
    .clock                  (clock),
    .address                (pc),
    .data_fetched           (inst)
);

endmodule

