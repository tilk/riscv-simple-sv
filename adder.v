///////////////////////////////////////////////////////////////////////////////
//                      RISC-V SiMPLE - Somador Genérico                     //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.v"
`endif

module adder #(
    parameter  WIDTH = 32 ) (
        input  [WIDTH-1:0] operand_a,
        input  [WIDTH-1:0] operand_b,
        output reg [WIDTH-1:0] result
);

always @ (*) begin
    result = operand_a + operand_b;
end

endmodule

