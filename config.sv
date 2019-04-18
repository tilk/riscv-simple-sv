// RISC-V SiMPLE SV -- configuration and constants
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`ifndef CONFIG_AND_CONSTANTS
`define CONFIG_AND_CONSTANTS

// Selecione a microarquitetura a ser sintetizada [ative somente uma]
`define UNICICLO
// `define MULTICICLO
// `define PIPELINE

// Selecione a ISA a ser implementada [ative somente uma]
`define RV32I

// Selecione os módulos extras da ISA a serem implementados
`define M_MODULE    // Operações de multiplicação e divisão
// `define F_MODULE    // Operações de ponto flutuante com precisão simples

// Selecione se sinais virtuais de depuração serão sintetizados
`define DEBUG

// Selecione a FPGA utilizada [ative somente uma]
// `define DE1_SOC
`define DE2_115

// Selecione os periféricos a serem implementados
// `define USE_LEDS
// `define USE_7SEG
// `define USE_VIDEO
// `define USE_LCD
// `define USE_AUDIO
// `define USE_KEYBOARD
// `define USE_DRAM
// `define USE_GPIO
// `define USE_HSMC
// `define USE_I2C
// `define USE_ARM_HPS
// `define USE_TV_DECODER


//////////////////////////////////////////
//              Constantes              //
//////////////////////////////////////////

`define ON              1'b1
`define OFF             1'b0
`define ZERO            32'b0

// Ciclos para a parada do processador (clock de 50Mhz)
`define TIMEUP_CYCLES   500000000

// Opcodes das instruções de 32 bits
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

// Interpretação do campo funct3 para a Unidade Lógica e Aritmética
`define FUNCT3_ALU_ADD_SUB  3'b000
`define FUNCT3_ALU_SLL      3'b001
`define FUNCT3_ALU_SLT      3'b010
`define FUNCT3_ALU_SLTU     3'b011
`define FUNCT3_ALU_XOR      3'b100
`define FUNCT3_ALU_SHIFTR   3'b101
`define FUNCT3_ALU_OR       3'b110
`define FUNCT3_ALU_AND      3'b111

// Interpretação do campo funct3 para a extensão M
`define FUNCT3_ALU_MUL      3'b000
`define FUNCT3_ALU_MULH     3'b001
`define FUNCT3_ALU_MULHSU   3'b010
`define FUNCT3_ALU_MULHU    3'b011
`define FUNCT3_ALU_DIV      3'b100
`define FUNCT3_ALU_DIVU     3'b101
`define FUNCT3_ALU_REM      3'b110
`define FUNCT3_ALU_REMU     3'b111

// Interpretação do campo funct7 para a extensão F
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

// Interpretação do campo funct3 para os modos de arredondamento da extensão F
`define FUNCT3_ROUND_RNE    3'b000
`define FUNCT3_ROUND_RTZ    3'b001
`define FUNCT3_ROUND_RDN    3'b010
`define FUNCT3_ROUND_RUP    3'b011
`define FUNCT3_ROUND_RMM    3'b100
`define FUNCT3_ROUND_DYN    3'b111

// Interpretação do campo funct3 para loads/stores
`define FUNCT3_MEM_BYTE     3'b000
`define FUNCT3_MEM_HALF     3'b001
`define FUNCT3_MEM_WORD     3'b010
`define FUNCT3_MEM_BYTE_U   3'b100
`define FUNCT3_MEM_HALF_U   3'b101

// Interpretação do campo funct3 para Branches
`define FUNCT3_BRANCH_EQ    3'b000
`define FUNCT3_BRANCH_NE    3'b001
`define FUNCT3_BRANCH_LT    3'b100
`define FUNCT3_BRANCH_GE    3'b101
`define FUNCT3_BRANCH_LTU   3'b110
`define FUNCT3_BRANCH_GEU   3'b111

// Operações da ULA
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
//              Endereços               //
//////////////////////////////////////////
// TODO: Reorganizar endereços

// Valor inicial do program counter
`define INITIAL_PC      32'h00400000

// Memória de instruções
`define TEXT_BEGIN      `INITIAL_PC
`define TEXT_WIDTH      2**16
`define TEXT_END        `TEXT_BEGIN + `TEXT_WIDTH - 1

// Memória de dados
`define DATA_BEGIN      32'h1001_0000
`define DATA_WIDTH      2**17
`define DATA_END        `DATA_BEGIN + `DATA_WIDTH - 1

// Início da pilha
`define STACK_ADDRESS   `DATA_END - 3

// Memory Mapped Input and Output
`define MMIO_BEGIN      32'hFF00_0000

// VGA Frame 0 [320 x 240]
`define VGA0_BEGIN      32'hFF00_0000
`define VGA0_END        32'hFF01_2BFF

// VGA Frame 1 [320 x 240]
`define VGA1_BEGIN      32'hFF10_0000
`define VGA1_END        32'hFF11_2BFF

// VGA Frame Select
`define VGA_FRAME       32'hFF20_0604

// Keyboard and Display MMIO Simulator do RARS
`define KDMMIO_CONTROL  32'hFF20_0000
`define KDMMIO_DATA     32'hFF20_0004

// Buffer de scancodes do teclado PS2
`define KEYBOARD_BUFFER0    32'hFF20_0100
`define KEYBOARD_BUFFER1    32'hFF20_0104

// Keymap do teclado
`define KEYBOARD_KEYMAP0    32'hFF20_0520
`define KEYBOARD_KEYMAP1    32'hFF20_0524
`define KEYBOARD_KEYMAP2    32'hFF20_0528
`define KEYBOARD_KEYMAP3    32'hFF20_052C

// CODEC de Áudio
`define AUDIO_IN_L      32'hFF20_0160
`define AUDIO_IN_R      32'hFF20_0164
`define AUDIO_OUT_L     32'hFF20_0168
`define AUDIO_OUT_R     32'hFF20_016C
`define AUDIO_CTRL1     32'hFF20_0170
`define AUDIO_CRTL2     32'hFF20_0174

// Sintetizador de Áudio
`define NOTE_SYSCALL    32'hFF20_0178
`define NOTE_CLOCK      32'hFF20_017C
`define NOTE_MELODY     32'hFF20_0180
`define MUSIC_TEMPO     32'hFF20_0184
`define SYNTH_CONTROL   32'hFF20_0188
`define SYNTH_PAUSE     32'hFF20_018C

// Stopwatch
`define STOPWATCH       32'hFF20_0510

// Gerador de Números Aleatórios (RNG) por Linear Feedback Shift Register
`define LFSR_RNG        32'hFF20_0514

// Endereço de Breakpoint setável pelo In-System Memory Content Editor
`define BREAK_ADDRESS   32'hFF20_0600

//////////////////////////////////////////
//             Microcódigo              //
//////////////////////////////////////////


//////////////////////////////////////////
//               Pipeline               //
//////////////////////////////////////////


`endif

