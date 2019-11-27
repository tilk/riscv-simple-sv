// RISC-V SiMPLE SV -- Toplevel
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module toplevel (
    input  clock,
    input  reset,

    output [31:0] bus_read_data,
    output [31:0] bus_address,
    output [31:0] bus_write_data,
    output [3:0]  bus_byte_enable,
    output        bus_read_enable,
    output        bus_write_enable,

    output [31:0] inst,
    output [31:0] pc,
    output        inst_read_enable,
    output        inst_wait_req,
    output        inst_valid
);

    riscv_core riscv_core (
        .clock                  (clock),
        .reset                  (reset),
        .inst_data              (inst),
        .pc                     (pc),
        .inst_read_enable       (inst_read_enable),
        .inst_wait_req          (inst_wait_req),
        .inst_valid             (inst_valid),
        .bus_address            (bus_address),
        .bus_read_data          (bus_read_data),
        .bus_write_data         (bus_write_data),
        .bus_read_enable        (bus_read_enable),
        .bus_write_enable       (bus_write_enable),
        .bus_byte_enable        (bus_byte_enable)
    );

    example_text_memory_bus text_memory_bus (
        .clock                  (clock),
        .reset                  (reset),
        .read_enable            (inst_read_enable),
        .wait_req               (inst_wait_req),
        .valid                  (inst_valid),
        .address                (pc),
        .read_data              (inst)
    );
    
    example_data_memory_bus data_memory_bus (
        .clock                  (clock),
        .address                (bus_address),
        .read_data              (bus_read_data),
        .write_data             (bus_write_data),
        .read_enable            (bus_read_enable),
        .write_enable           (bus_write_enable),
        .byte_enable            (bus_byte_enable)
    );
    
endmodule

