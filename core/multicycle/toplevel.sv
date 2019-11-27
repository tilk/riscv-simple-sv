// RISC-V SiMPLE SV -- Toplevel
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

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
    output        bus_wait_req,
    output        bus_valid,

    output [31:0] inst,
    output [31:0] pc,
    output        inst_read_enable,
    output        inst_wait_req,
    output        inst_valid
);

    assign inst_read_enable = 0;
    assign inst_wait_req = 0;
    assign inst_valid = 0;

    riscv_core riscv_core (
        .clock                  (clock),
        .reset                  (reset),
        .inst                   (inst),
        .pc                     (pc),
        .bus_address            (bus_address),
        .bus_read_data          (bus_read_data),
        .bus_write_data         (bus_write_data),
        .bus_wait_req           (bus_wait_req),
        .bus_valid              (bus_valid),
        .bus_read_enable        (bus_read_enable),
        .bus_write_enable       (bus_write_enable),
        .bus_byte_enable        (bus_byte_enable)
    );

    example_memory_bus memory_bus (
        .clock                  (clock),
        .reset                  (reset),
        .wait_req               (bus_wait_req),
        .valid                  (bus_valid),
        .address                (bus_address),
        .read_data              (bus_read_data),
        .write_data             (bus_write_data),
        .read_enable            (bus_read_enable),
        .write_enable           (bus_write_enable),
        .byte_enable            (bus_byte_enable)
    );
    
endmodule

