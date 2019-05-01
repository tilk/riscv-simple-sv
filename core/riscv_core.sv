// RISC-V SiMPLE SV -- RISC-V core
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

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

    logic pc_write_enable;
    logic regfile_write_enable;
    logic alu_operand_a_select;
    logic alu_operand_b_select;
    logic [2:0] reg_writeback_select;
    logic [6:0] inst_opcode;
    logic [2:0] inst_funct3;
    logic inst_bit_30;
    `ifdef M_MODULE
    logic inst_bit_25;
    `endif
    logic [4:0] inst_rd;
    logic [4:0] inst_rs1;
    logic [4:0] inst_rs2;
    logic [31:0] immediate;
    logic [1:0] next_pc_select;
    logic [4:0] alu_function;
    logic alu_result_equal_zero;

    assign bus_format = inst_funct3;

    singlecycle_datapath singlecycle_datapath (
        .clock                  (clock),
        .reset                  (reset),
        .data_mem_data_fetched  (bus_data_fetched),
        .data_mem_address       (bus_address),
        .data_mem_write_data    (bus_write_data),
        .immediate              (immediate),
        .inst_rd                (inst_rd),
        .inst_rs1               (inst_rs1),
        .inst_rs2               (inst_rs2),
        .pc                     (pc),
        .pc_write_enable        (pc_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .alu_operand_a_select   (alu_operand_a_select),
        .alu_operand_b_select   (alu_operand_b_select),
        .reg_writeback_select   (reg_writeback_select),
        .next_pc_select         (next_pc_select),
        .alu_result_equal_zero  (alu_result_equal_zero),
        .alu_function           (alu_function)
    );

    instruction_decoder instruction_decoder(
        .inst                   (inst),
        .inst_opcode            (inst_opcode),
        .inst_bit_30            (inst_bit_30),
    `ifdef M_MODULE
        .inst_bit_25            (inst_bit_25),
    `endif
        .inst_funct3            (inst_funct3),
        .inst_rd                (inst_rd),
        .inst_rs1               (inst_rs1),
        .inst_rs2               (inst_rs2)
    );
    
    immediate_generator immediate_generator(
        .inst                   (inst),
        .immediate              (immediate)
    );
    
    singlecycle_ctlpath singlecycle_ctlpath(
        .inst_opcode            (inst_opcode),
        .inst_funct3            (inst_funct3),
        .inst_bit_30            (inst_bit_30),
    `ifdef M_MODULE
        .inst_bit_25            (inst_bit_25),
    `endif
        .alu_result_equal_zero  (alu_result_equal_zero),
        .pc_write_enable        (pc_write_enable),
        .regfile_write_enable   (regfile_write_enable),
        .alu_operand_a_select   (alu_operand_a_select),
        .alu_operand_b_select   (alu_operand_b_select),
        .data_mem_read_enable   (bus_read_enable),
        .data_mem_write_enable  (bus_write_enable),
        .reg_writeback_select   (reg_writeback_select),
        .alu_function           (alu_function),
        .next_pc_select         (next_pc_select)
    );
    
    data_memory_interface data_memory_interface (
        .clock                  (clock),
        .read_enable            (bus_read_enable),
        .write_enable           (bus_write_enable),
        .data_format            (inst_funct3),
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

