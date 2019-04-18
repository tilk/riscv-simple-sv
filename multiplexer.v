///////////////////////////////////////////////////////////////////////////////
//                   RISC-V SiMPLE - Multiplexador Genérico                  //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
//                                                                           //
//             Multiplexer Parametrizado criado por jakobjones               //
//      Fonte: https://alteraforum.com/forum/showthread.php?t=22519          //
//             Modificado por @arthurbeggs para Verilog-2001                 //
///////////////////////////////////////////////////////////////////////////////
//                               MODO DE USO                                 //
//                                                                           //
// multiplexer #(                                                            //
//     .WIDTH(32),     // Largura da palavra                                 //
//     .CHANNELS(2)    // Quantidade de entradas SEMPRE IGUAL a 2^n          //
// ) nome_do_mux (                                                           //
//     .in_bus({in1, in2, ...}),   // Sinais de entrada concatenados         //
//     .sel(sel_signal),           // Sinal de seleção de entrada            //
//     .out(out_signal)            // Sinal de saída                         //
// );                                                                        //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.v"
`endif

module multiplexer #(
    parameter  WIDTH    = 32,
    parameter  CHANNELS = 2) (
        input  [(CHANNELS * WIDTH) - 1:0]   in_bus,
        input  [$clog2(CHANNELS) - 1:0]     sel,
        output [WIDTH - 1:0]                out
);

genvar ig;

// Vetor de palavras de #(WIDTH) bits com #(CHANNELS) posições.
wire    [WIDTH - 1:0] input_array [0:CHANNELS - 1];

assign  out = input_array[sel];

generate
    for(ig = 0; ig < CHANNELS; ig = ig + 1) begin: array_assignments
        assign input_array[(CHANNELS - 1) - ig] = in_bus[(ig * WIDTH) +: WIDTH];
    end
endgenerate

endmodule

