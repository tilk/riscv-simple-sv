///////////////////////////////////////////////////////////////////////////////
//               RISC-V SiMPLE - Interface da Memória de Texto               //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module text_memory_interface (
    input  clock,
    input  [31:0] address,
    output reg [31:0] data_fetched
);

wire [31:0] fetched;

text_memory text_memory(
    .address    (address[15:2]),
    .clock      (clock),
    .q          (fetched)
);

always @ (*) begin
    if ((address >= `TEXT_BEGIN) && (address <= `TEXT_END))
        data_fetched = fetched;
    else
        data_fetched = 32'hzzzzzzzz;
end

endmodule

