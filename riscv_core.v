///////////////////////////////////////////////////////////////////////////////
//                  RISC-V SiMPLE - Soft core RISC-V SiMPLE                  //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.v"
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

singlecycle_datapath singlecycle_datapath (
    .clock                  (clock),
    .reset                  (reset),
    .data_mem_data_fetched  (bus_data_fetched),
    .data_mem_read_enable   (bus_read_enable),
    .data_mem_write_enable  (bus_write_enable),
    .data_mem_address       (bus_address),
    .data_mem_write_data    (bus_write_data),
    .data_mem_format        (bus_format),
    .inst                   (inst),
    .pc                     (pc)
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

