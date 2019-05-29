// RISC-V SiMPLE SV -- pipelined data path
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module pipeline_datapath (
    input  clock,
    input  reset,

    input  [31:0] _data_mem_read_data,
    output [31:0] _data_mem_address,
    output [31:0] _data_mem_write_data,
    output _data_mem_read_enable,
    output _data_mem_write_enable,
    output [2:0] _data_mem_format,

    input  [31:0] _inst,
    output [31:0] _pc,

    output [6:0] inst_opcode,
    output [2:0] inst_funct3,
    output [6:0] inst_funct7,
    output alu_result_equal_zero,
    output [1:0] _branch_status,
    output want_stall,
    
    // control signals
    input pc_write_enable,
    input no_stall,
    input jump_start,
    input inject_bubble,
    input _regfile_write_enable,
    input _alu_operand_a_select,
    input _alu_operand_b_select,
    input [2:0] _reg_writeback_select,
    input [1:0] next_pc_select,
    input [4:0] _alu_function,
    input _read_enable,
    input _write_enable
);
    // names for pipeline steps
    localparam PL_IF  = 0; // instruction fetch
    localparam PL_ID  = 1; // instruction decode
    localparam PL_EX  = 2; // instruction execute
    localparam PL_MEM = 3; // memory access
    localparam PL_WB  = 4; // writeback

    logic [31:0] inst[PL_IF:PL_ID];
    logic [31:0] pc[PL_IF:PL_EX];
    logic [31:0] data_mem_read_data[PL_MEM:PL_WB];
    logic regfile_write_enable[PL_ID:PL_WB];
    logic alu_operand_a_select[PL_ID:PL_EX];
    logic alu_operand_b_select[PL_ID:PL_EX];
    logic [4:0] alu_function[PL_ID:PL_EX];
    logic [2:0] reg_writeback_select[PL_ID:PL_WB];
    logic [2:0] data_mem_format[PL_ID:PL_MEM];
    logic data_mem_read_enable[PL_ID:PL_MEM];
    logic data_mem_write_enable[PL_ID:PL_MEM];
    logic branch_status[PL_ID:PL_MEM];

    // register file inputs and outputs
    logic [31:0] rd_data[PL_WB:PL_WB];
    logic [31:0] rs1_data[PL_ID:PL_EX];
    logic [31:0] rs2_data[PL_ID:PL_MEM];
    
    // program counter signals
    logic [31:0] pc_plus_4[PL_IF:PL_WB];
    logic [31:0] pc_plus_immediate[PL_EX:PL_EX];
    logic [31:0] next_pc;
    logic [4:0] inst_rd[PL_ID:PL_WB];
    logic [4:0] inst_rs1[PL_ID:PL_ID];
    logic [4:0] inst_rs2[PL_ID:PL_ID];
    
    // ALU signals
    logic [31:0] alu_operand_a[PL_EX:PL_EX];
    logic [31:0] alu_operand_b[PL_EX:PL_EX];
    logic [31:0] alu_result[PL_EX:PL_WB];
    
    // immediate
    logic [31:0] immediate[PL_ID:PL_WB];
    
    // ID pipeline registers
    always_ff @(posedge clock or posedge reset) if (reset) begin
        inst[PL_ID] <= 32'h00000013; // nop
    end else if (no_stall) begin
        inst[PL_ID] <= inst[PL_IF];
        pc[PL_ID] <= pc[PL_IF];
        pc_plus_4[PL_ID] <= pc_plus_4[PL_IF];
    end

    // EX pipeline registers
    always_ff @(posedge clock or posedge reset) if (reset) begin
        regfile_write_enable[PL_EX] <= 1'b0;
        data_mem_read_enable[PL_EX] <= 1'b0;
        data_mem_write_enable[PL_EX] <= 1'b0;
        branch_status[PL_EX] <= 1'b0;
    end else begin
        rs1_data[PL_EX] <= rs1_data[PL_ID];
        rs2_data[PL_EX] <= rs2_data[PL_ID];
        immediate[PL_EX] <= immediate[PL_ID];
        pc[PL_EX] <= pc[PL_ID];
        pc_plus_4[PL_EX] <= pc_plus_4[PL_ID];
        inst_rd[PL_EX] <= inst_rd[PL_ID];
        regfile_write_enable[PL_EX] <= regfile_write_enable[PL_ID];
        alu_operand_a_select[PL_EX] <= alu_operand_a_select[PL_ID];
        alu_operand_b_select[PL_EX] <= alu_operand_b_select[PL_ID];
        alu_function[PL_EX] <= alu_function[PL_ID];
        reg_writeback_select[PL_EX] <= reg_writeback_select[PL_ID];
        data_mem_format[PL_EX] <= data_mem_format[PL_ID];
        data_mem_read_enable[PL_EX] <= data_mem_read_enable[PL_ID];
        data_mem_write_enable[PL_EX] <= data_mem_write_enable[PL_ID];
        branch_status[PL_EX] <= branch_status[PL_ID];
        if (inject_bubble) begin
            branch_status[PL_EX] <= 1'b0;
            regfile_write_enable[PL_EX] <= 1'b0;
            data_mem_read_enable[PL_EX] <= 1'b0;
            data_mem_write_enable[PL_EX] <= 1'b0;
        end
    end

    // MEM pipeline registers
    always_ff @(posedge clock or posedge reset) if (reset) begin
        regfile_write_enable[PL_MEM] <= 1'b0;
        data_mem_read_enable[PL_MEM] <= 1'b0;
        data_mem_write_enable[PL_MEM] <= 1'b0;
    end else begin
        rs2_data[PL_MEM] <= rs2_data[PL_EX];
        immediate[PL_MEM] <= immediate[PL_EX];
        alu_result[PL_MEM] <= alu_result[PL_EX];
        pc_plus_4[PL_MEM] <= pc_plus_4[PL_EX];
        inst_rd[PL_MEM] <= inst_rd[PL_EX];
        regfile_write_enable[PL_MEM] <= regfile_write_enable[PL_EX];
        reg_writeback_select[PL_MEM] <= reg_writeback_select[PL_EX];
        data_mem_format[PL_MEM] <= data_mem_format[PL_EX];
        data_mem_read_enable[PL_MEM] <= data_mem_read_enable[PL_EX];
        data_mem_write_enable[PL_MEM] <= data_mem_write_enable[PL_EX];
        branch_status[PL_MEM] <= branch_status[PL_EX];
    end

    // WB pipeline registers
    always_ff @(posedge clock or posedge reset) if (reset) begin
        regfile_write_enable[PL_WB] <= 1'b0;
    end else begin
        immediate[PL_WB] <= immediate[PL_MEM];
        alu_result[PL_WB] <= alu_result[PL_MEM];
        data_mem_read_data[PL_WB] <= data_mem_read_data[PL_MEM];
        pc_plus_4[PL_WB] <= pc_plus_4[PL_MEM];
        inst_rd[PL_WB] <= inst_rd[PL_MEM];
        regfile_write_enable[PL_WB] <= regfile_write_enable[PL_MEM];
        reg_writeback_select[PL_WB] <= reg_writeback_select[PL_MEM];
    end

    // inject inputs into pipeline
    assign inst[PL_IF] = _inst;
    assign data_mem_read_data[PL_MEM]   = _data_mem_read_data;
    assign regfile_write_enable[PL_ID]  = _regfile_write_enable;
    assign alu_operand_a_select[PL_ID]  = _alu_operand_a_select;
    assign alu_operand_b_select[PL_ID]  = _alu_operand_b_select;
    assign alu_function[PL_ID]          = _alu_function;
    assign reg_writeback_select[PL_ID]  = _reg_writeback_select;
    assign data_mem_read_enable[PL_ID]  = _read_enable;
    assign data_mem_write_enable[PL_ID] = _write_enable;
    assign data_mem_format[PL_ID] = inst_funct3;
    assign branch_status[PL_ID] = jump_start;

    // extract outputs from pipeline
    assign _pc = pc[PL_IF];
    assign _data_mem_address      = alu_result[PL_MEM];
    assign _data_mem_write_data   = rs2_data[PL_MEM];
    assign _data_mem_format       = data_mem_format[PL_MEM];
    assign _data_mem_read_enable  = data_mem_read_enable[PL_MEM];
    assign _data_mem_write_enable = data_mem_write_enable[PL_MEM];
    assign _branch_status         = {branch_status[PL_MEM], branch_status[PL_EX]};

    assign want_stall =
           regfile_write_enable[PL_MEM] && inst_rd[PL_MEM] == inst_rs1[PL_ID] && |inst_rd[PL_MEM] && alu_operand_a_select[PL_ID] == `CTL_ALU_A_RS1
        || regfile_write_enable[PL_MEM] && inst_rd[PL_MEM] == inst_rs2[PL_ID] && |inst_rd[PL_MEM] && alu_operand_b_select[PL_ID] == `CTL_ALU_B_RS2
        || regfile_write_enable[PL_MEM] && inst_rd[PL_MEM] == inst_rs2[PL_ID] && |inst_rd[PL_MEM] && (data_mem_read_enable[PL_ID] || data_mem_write_enable[PL_ID])
        || regfile_write_enable[PL_EX] && inst_rd[PL_EX] == inst_rs1[PL_ID] && |inst_rd[PL_EX] && alu_operand_a_select[PL_ID] == `CTL_ALU_A_RS1
        || regfile_write_enable[PL_EX] && inst_rd[PL_EX] == inst_rs2[PL_ID] && |inst_rd[PL_EX] && alu_operand_b_select[PL_ID] == `CTL_ALU_B_RS2
        || regfile_write_enable[PL_EX] && inst_rd[PL_EX] == inst_rs2[PL_ID] && |inst_rd[PL_EX] && (data_mem_read_enable[PL_ID] || data_mem_write_enable[PL_ID])
        || regfile_write_enable[PL_WB] && inst_rd[PL_WB] == inst_rs1[PL_ID] && |inst_rd[PL_WB] && alu_operand_a_select[PL_ID] == `CTL_ALU_A_RS1
        || regfile_write_enable[PL_WB] && inst_rd[PL_WB] == inst_rs2[PL_ID] && |inst_rd[PL_WB] && alu_operand_b_select[PL_ID] == `CTL_ALU_B_RS2
        || regfile_write_enable[PL_WB] && inst_rd[PL_WB] == inst_rs2[PL_ID] && |inst_rd[PL_WB] && (data_mem_read_enable[PL_ID] || data_mem_write_enable[PL_ID]);
    
    adder #(
        .WIDTH(32)
    ) adder_pc_plus_4 (
        .operand_a      (32'h00000004),
        .operand_b      (pc[PL_IF]),
        .result         (pc_plus_4[PL_IF])
    );
    
    adder #(
       .WIDTH(32)
    ) adder_pc_plus_immediate (
        .operand_a      (pc[PL_EX]),
        .operand_b      (immediate[PL_EX]),
        .result         (pc_plus_immediate[PL_EX])
    );
    
    alu alu(
        .alu_function       (alu_function[PL_EX]),
        .operand_a          (alu_operand_a[PL_EX]),
        .operand_b          (alu_operand_b[PL_EX]),
        .result             (alu_result[PL_EX]),
        .result_equal_zero  (alu_result_equal_zero)
    );
    
    multiplexer4 #(
        .WIDTH(32)
    ) mux_next_pc_select (
        .in0 (pc_plus_4[PL_IF]),
        .in1 (pc_plus_immediate[PL_EX]),
        .in2 ({alu_result[PL_EX][31:1], 1'b0}),
        .in3 (pc_plus_4[PL_EX]),
        .sel (next_pc_select),
        .out (next_pc)
    );
    
    multiplexer2 #(
        .WIDTH(32)
    ) mux_operand_a (
        .in0 (rs1_data[PL_EX]),
        .in1 (pc[PL_EX]),
        .sel (alu_operand_a_select[PL_EX]),
        .out (alu_operand_a[PL_EX])
    );
    
    multiplexer2 #(
        .WIDTH(32)
    ) mux_operand_b (
        .in0 (rs2_data[PL_EX]),
        .in1 (immediate[PL_EX]),
        .sel (alu_operand_b_select[PL_EX]),
        .out (alu_operand_b[PL_EX])
    );
    
    multiplexer8 #(
        .WIDTH(32)
    ) mux_reg_writeback (
        .in0 (alu_result[PL_WB]),
        .in1 (data_mem_read_data[PL_WB]),
        .in2 (pc_plus_4[PL_WB]),
        .in3 (immediate[PL_WB]),
        .in4 (32'b0),
        .in5 (32'b0),
        .in6 (32'b0),
        .in7 (32'b0),
        .sel (reg_writeback_select[PL_WB]),
        .out (rd_data[PL_WB])
    );
    
    register #(
        .WIDTH(32),
        .INITIAL(`INITIAL_PC)
    ) program_counter(
        .clock              (clock),
        .reset              (reset),
        .write_enable       (pc_write_enable),
        .next               (next_pc),
        .value              (pc[PL_IF])
    );
    
    regfile regfile(
        .clock              (clock),
        .write_enable       (regfile_write_enable[PL_WB]),
        .rd_address         (inst_rd[PL_WB]),
        .rs1_address        (inst_rs1[PL_ID]),
        .rs2_address        (inst_rs2[PL_ID]),
        .rd_data            (rd_data[PL_WB]),
        .rs1_data           (rs1_data[PL_ID]),
        .rs2_data           (rs2_data[PL_ID])
    );

    instruction_decoder instruction_decoder(
        .inst                   (inst[PL_ID]),
        .inst_opcode            (inst_opcode),
        .inst_funct7            (inst_funct7),
        .inst_funct3            (inst_funct3),
        .inst_rd                (inst_rd[PL_ID]),
        .inst_rs1               (inst_rs1[PL_ID]),
        .inst_rs2               (inst_rs2[PL_ID])
    );
    
    immediate_generator immediate_generator(
        .inst                   (inst[PL_ID]),
        .immediate              (immediate[PL_ID])
    );
    
endmodule

