// RISC-V SiMPLE SV -- configuration and constants
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
`define CONFIG_AND_CONSTANTS

// Select architecture
`define UNICICLO
// `define MULTICICLO
// `define PIPELINE

// Select ISA
`define RV32I

// Select ISA extensions
`define M_MODULE    // multiplication and division
// `define F_MODULE    // floating point operations

// Enable debugging signals
`define DEBUG

//////////////////////////////////////////
//              Constants               //
//////////////////////////////////////////

`define ON              1'b1
`define OFF             1'b0
`define ZERO            32'b0

// Instruction opcodes
`define OPCODE_LOAD     7'b0000011
`define OPCODE_LOAD_FP  7'b0000111
`define OPCODE_MISC_MEM 7'b0001111
`define OPCODE_OP_IMM   7'b0010011
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_STORE    7'b0100011
`define OPCODE_STORE_FP 7'b0100111
`define OPCODE_OP       7'b0110011
`define OPCODE_LUI      7'b0110111
`define OPCODE_OP_FP    7'b1010011
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_JALR     7'b1100111
`define OPCODE_JAL      7'b1101111
`define OPCODE_SYSTEM   7'b1110011

// Interpretations of the "funct3" field
`define FUNCT3_ALU_ADD_SUB  3'b000
`define FUNCT3_ALU_SLL      3'b001
`define FUNCT3_ALU_SLT      3'b010
`define FUNCT3_ALU_SLTU     3'b011
`define FUNCT3_ALU_XOR      3'b100
`define FUNCT3_ALU_SHIFTR   3'b101
`define FUNCT3_ALU_OR       3'b110
`define FUNCT3_ALU_AND      3'b111

// Interpretations of the "funct3" field for extension M
`define FUNCT3_ALU_MUL      3'b000
`define FUNCT3_ALU_MULH     3'b001
`define FUNCT3_ALU_MULHSU   3'b010
`define FUNCT3_ALU_MULHU    3'b011
`define FUNCT3_ALU_DIV      3'b100
`define FUNCT3_ALU_DIVU     3'b101
`define FUNCT3_ALU_REM      3'b110
`define FUNCT3_ALU_REMU     3'b111

// Interpretations of the "funct7" field for extension F
`define FUNCT7_FPALU_ADD    7'b0000000
`define FUNCT7_FPALU_SUB    7'b0000100
`define FUNCT7_FPALU_MUL    7'b0001000
`define FUNCT7_FPALU_DIV    7'b0001100
`define FUNCT7_FPALU_SQRT   7'b0101100
`define FUNCT7_FPALU_SIGN   7'b0010000
`define FUNCT7_FPALU_MINMAX 7'b0010100
`define FUNCT7_FPALU_CVT_W  7'b1100000
`define FUNCT7_FPALU_MV_X   7'b1110000
`define FUNCT7_FPALU_COMP   7'b1010000
`define FUNCT7_FPALU_CLASS  7'b1110000
`define FUNCT7_FPALU_CVT_S  7'b1101000
`define FUNCT7_FPALU_MV_W   7'b1111000

// Interpretations of the "funct3" field for extension F (rounding modes)
`define FUNCT3_ROUND_RNE    3'b000
`define FUNCT3_ROUND_RTZ    3'b001
`define FUNCT3_ROUND_RDN    3'b010
`define FUNCT3_ROUND_RUP    3'b011
`define FUNCT3_ROUND_RMM    3'b100
`define FUNCT3_ROUND_DYN    3'b111

// Interpretations of the "funct3" field for loads and stores
`define FUNCT3_MEM_BYTE     3'b000
`define FUNCT3_MEM_HALF     3'b001
`define FUNCT3_MEM_WORD     3'b010
`define FUNCT3_MEM_BYTE_U   3'b100
`define FUNCT3_MEM_HALF_U   3'b101

// Interpretations of the "funct3" field for branches
`define FUNCT3_BRANCH_EQ    3'b000
`define FUNCT3_BRANCH_NE    3'b001
`define FUNCT3_BRANCH_LT    3'b100
`define FUNCT3_BRANCH_GE    3'b101
`define FUNCT3_BRANCH_LTU   3'b110
`define FUNCT3_BRANCH_GEU   3'b111

// ALU operations
`define ALU_ZERO    5'b00000
`define ALU_ADD     5'b00001
`define ALU_SUB     5'b00010
`define ALU_SLL     5'b00011
`define ALU_SRL     5'b00100
`define ALU_SRA     5'b00101
`define ALU_SLT     5'b00110
`define ALU_SLTU    5'b00111
`define ALU_XOR     5'b01000
`define ALU_OR      5'b01001
`define ALU_AND     5'b01010
`define ALU_MUL     5'b01011
`define ALU_MULH    5'b01100
`define ALU_MULHSU  5'b01101
`define ALU_MULHU   5'b01110
`define ALU_DIV     5'b01111
`define ALU_DIVU    5'b10000
`define ALU_REM     5'b10001
`define ALU_REMU    5'b10010

//////////////////////////////////////////
//              Addresses               //
//////////////////////////////////////////

// Program counter initial value
`define INITIAL_PC      32'h00400000

// Instruction memory
`define TEXT_BEGIN      `INITIAL_PC
`define TEXT_BITS       16
`define TEXT_WIDTH      2**`TEXT_BITS
`define TEXT_END        `TEXT_BEGIN + `TEXT_WIDTH - 1

// Data memory
`define DATA_BEGIN      32'h1001_0000
`define DATA_BITS       17
`define DATA_WIDTH      2**`DATA_BITS
`define DATA_END        `DATA_BEGIN + `DATA_WIDTH - 1

// Stack start
`define STACK_ADDRESS   `DATA_END - 3

`endif

