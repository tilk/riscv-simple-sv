///////////////////////////////////////////////////////////////////////////////
//                 RISC-V SiMPLE - Caminho de Dados Uniciclo                 //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.v"
`endif

module singlecycle_datapath (
    input  clock,
    input  reset,

    input  [31:0] data_mem_data_fetched,
    output [31:0] data_mem_address,
    output [31:0] data_mem_write_data,
    output [2:0]  data_mem_format,

    input  [31:0] inst,
    output [31:0] pc,
    
// Sinais de controle
    input pc_write_enable,
    input regfile_write_enable,
    input alu_operand_a_select,
    input alu_operand_b_select,
    input jal_enable,
    input jalr_enable,
    input branch_enable,
    input [2:0] alu_op_type,
    input [2:0] reg_writeback_select
);

// Sinal do Imediato
wire [31:0] immediate;

// Sinais de dados do regfile
wire [31:0] rd_data;
wire [31:0] rs1_data;
wire [31:0] rs2_data;

// Sinais do Program Counter
wire [1:0]  next_pc_select;
wire [31:0] pc_plus_4;
wire [31:0] pc_plus_immediate;
wire [31:0] next_pc;

// Sinais da ULA
wire [4:0]  alu_function;
wire [31:0] alu_operand_a;
wire [31:0] alu_operand_b;
wire [31:0] alu_result;
wire alu_result_equal_zero;

assign data_mem_address     = alu_result;
assign data_mem_write_data  = rs2_data;
assign data_mem_format      = inst[14:12];

adder #(
    .WIDTH(32)
    ) adder_pc_plus_4 (
        .operand_a      (32'h00000004),
        .operand_b      (pc),
        .result         (pc_plus_4)
);

adder #(
    .WIDTH(32)
    ) adder_pc_plus_immediate (
        .operand_a      (pc),
        .operand_b      (immediate),
        .result         (pc_plus_immediate)
);

alu alu(
    .alu_function       (alu_function),
    .operand_a          (alu_operand_a),
    .operand_b          (alu_operand_b),
    .result             (alu_result),
    .result_equal_zero  (alu_result_equal_zero)
);

alu_control alu_control(
    .alu_op_type        (alu_op_type),
    .inst_funct3        (inst[14:12]),
    .alu_function       (alu_function)
);

control_transfer control_transfer (
    .branch_enable      (branch_enable),
    .jal_enable         (jal_enable),
    .jalr_enable        (jalr_enable),
    .result_equal_zero  (alu_result_equal_zero),
    .inst_funct3        (inst[14:12]),
    .next_pc_select     (next_pc_select)
);

immediate_generator immediate_generator(
    .inst               (inst),
    .immediate          (immediate)
);

multiplexer #(
    .WIDTH(32),
    .CHANNELS(4)
    ) mux_next_pc_select (
        .in_bus         ({  {pc_plus_4},
                            {pc_plus_immediate},
                            {alu_result[31:1], 1'b0},
                            {32'b0}
                        }),
        .sel            (next_pc_select),
        .out            (next_pc)
);

multiplexer #(
    .WIDTH(32),
    .CHANNELS(2)
    ) mux_operand_a (
        .in_bus         ({  {rs1_data},
                            {pc}
                        }),
        .sel            (alu_operand_a_select),
        .out            (alu_operand_a)
);

multiplexer #(
    .WIDTH(32),
    .CHANNELS(2)
    ) mux_operand_b (
        .in_bus         ({  {rs2_data},
                            {immediate}
                        }),
        .sel            (alu_operand_b_select),
        .out            (alu_operand_b)
);

multiplexer #(
    .WIDTH      (32),
    .CHANNELS   (8)
    ) mux_reg_writeback (
        .in_bus         ({  {alu_result},
                            {data_mem_data_fetched},
                            {pc_plus_4},
                            {immediate},
                            {32'b0},
                            {32'b0},
                            {32'b0},
                            {32'b0}
                        }),
        .sel            (reg_writeback_select),
        .out            (rd_data)
);

program_counter program_counter(
    .clock              (clock),
    .reset              (reset),
    .write_enable       (pc_write_enable),
    .next_pc            (next_pc),
    .pc                 (pc)
);

regfile regfile(
    .clock              (clock),
    .reset              (reset),
    .write_enable       (regfile_write_enable),
    .rd_address         (inst[11:7]),
    .rs1_address        (inst[19:15]),
    .rs2_address        (inst[24:20]),
    .rd_data            (rd_data),
    .rs1_data           (rs1_data),
    .rs2_data           (rs2_data)
);

endmodule

