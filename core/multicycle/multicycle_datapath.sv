// RISC-V SiMPLE SV -- multicycle data path
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module multicycle_datapath (
    input  clock,
    input  reset,

    input  [31:0] mem_read_data,
    output [31:0] mem_address,
    output [31:0] mem_write_data,

    output [31:0] inst,
    output [31:0] pc,

    output [6:0] inst_opcode,
    output [2:0] inst_funct3,
    output [6:0] inst_funct7,
    output alu_result_equal_zero,

    input [4:0] alu_function,
    input alu_operand_a_select,
    input [1:0] alu_operand_b_select,
    input next_pc_select,
    input pc_write_enable,
    input alu_out_write_enable,
    input inst_write_enable,
    input data_write_enable,
    input regfile_write_enable,
    input [2:0] reg_writeback_select,
    input inst_or_data
);

    // immediate
    logic [31:0] immediate;

    // ALU signals
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic [31:0] alu_out;
    
    // register file signals
    logic [4:0] inst_rd;
    logic [4:0] inst_rs1;
    logic [4:0] inst_rs2;
    
    // register file inputs and outputs
    logic [31:0] rd_data;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] rs1_out;
    logic [31:0] rs2_out;

    // program counter signals
    logic [31:0] next_pc;
    
    logic [31:0] data;

    assign mem_write_data = rs2_out;
    
    immediate_generator immediate_generator(
        .inst                   (inst),
        .immediate              (immediate)
    );
    
    instruction_decoder instruction_decoder(
        .inst                   (inst),
        .inst_opcode            (inst_opcode),
        .inst_funct7            (inst_funct7),
        .inst_funct3            (inst_funct3),
        .inst_rd                (inst_rd),
        .inst_rs1               (inst_rs1),
        .inst_rs2               (inst_rs2)
    );
    
    alu alu(
        .alu_function       (alu_function),
        .operand_a          (alu_operand_a),
        .operand_b          (alu_operand_b),
        .result             (alu_result),
        .result_equal_zero  (alu_result_equal_zero)
    );
    
    register #(
        .WIDTH(32),
        .INITIAL(`INITIAL_PC)
    ) program_counter(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (pc_write_enable),
        .next               (next_pc),
        .value              (pc)
    );

    register #(
        .WIDTH(32)
    ) alu_out_register(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (alu_out_write_enable),
        .next               (alu_result),
        .value              (alu_out)
    );

    register #(
        .WIDTH(32)
    ) inst_register(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (inst_write_enable),
        .next               (mem_read_data),
        .value              (inst)
    );

    register #(
        .WIDTH(32)
    ) data_register(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (data_write_enable),
        .next               (mem_read_data),
        .value              (data)
    );

    register #(
        .WIDTH(32)
    ) rs1_register(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (1'b1),
        .next               (rs1_data),
        .value              (rs1_out)
    );

    register #(
        .WIDTH(32)
    ) rs2_register(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (1'b1),
        .next               (rs2_data),
        .value              (rs2_out)
    );

    multiplexer2 #(
        .WIDTH(32)
    ) mux_mem_address (
        .in0                (pc),
        .in1                (alu_out),
        .sel                (inst_or_data),
        .out                (mem_address)
    );

    multiplexer8 #(
        .WIDTH(32)
    ) mux_mem_to_reg (
        .in0                (alu_out),
        .in1                (data),
        .in2                (pc),
        .in3                (immediate),
        .in4                (32'b0),
        .in5                (32'b0),
        .in6                (32'b0),
        .in7                (32'b0),
        .sel                (reg_writeback_select),
        .out                (rd_data)
    );

    multiplexer2 #(
        .WIDTH(32)
    ) mux_alu_operand_a (
        .in0                (rs1_out),
        .in1                (pc),
        .sel                (alu_operand_a_select),
        .out                (alu_operand_a)
    );

    multiplexer4 #(
        .WIDTH(32)
    ) mux_alu_operand_b (
        .in0                (rs2_out),
        .in1                (immediate),
        .in2                (32'd4),
        .in3                (32'd0),
        .sel                (alu_operand_b_select),
        .out                (alu_operand_b)
    );

    multiplexer2 #(
        .WIDTH(32)
    ) mux_next_pc (
        .in0                ({alu_result[31:1], 1'b0}),
        .in1                (alu_out),
        .sel                (next_pc_select),
        .out                (next_pc)
    );
    
    regfile regfile(
        .clock              (clock),
        .write_enable       (regfile_write_enable),
        .rd_address         (inst_rd),
        .rs1_address        (inst_rs1),
        .rs2_address        (inst_rs2),
        .rd_data            (rd_data),
        .rs1_data           (rs1_data),
        .rs2_data           (rs2_data)
    );

endmodule

