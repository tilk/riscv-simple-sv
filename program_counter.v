///////////////////////////////////////////////////////////////////////////////
//                    RISC-V SiMPLE - Contador de Programa                   //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.v"
`endif

module program_counter (
    input  clock,
    input  reset,
    input  write_enable,
    input  [31:0] next_pc,

    output reg [31:0] pc
);

initial begin
    pc <= `INITIAL_PC;
end

always @ (posedge clock or posedge reset) begin
    // Reseta o contador de programa
    if (reset) begin
        pc <= `INITIAL_PC;
    end

    // Habilta a escrita de PC
    else if (write_enable) begin
        pc <= next_pc;
    end
end

endmodule
