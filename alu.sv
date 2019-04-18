///////////////////////////////////////////////////////////////////////////////
//         RISC-V SiMPLE - Unidade Lógica Aritmética de 32 e 64 bits         //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.sv"
`endif

module alu (
    input  [4:0] alu_function,
    input  [31:0] operand_a,    // Entrada A da ULA
    input  [31:0] operand_b,    // Entrada B da ULA
    output reg [31:0] result,   // Resultado da operação executada
    output result_equal_zero    // Indica se result == 32'b0
);

`ifdef M_MODULE
    reg  [63:0] signed_multiplication;
    reg  [63:0] unsigned_multiplication;
    reg  [63:0] signed_unsigned_multiplication;
`endif

assign result_equal_zero = (result == 31'b0);

always @ (*) begin
    result = `ZERO;
    case (alu_function)
        `ALU_ZERO:  result = `ZERO;
        `ALU_ADD:   result = operand_a +    operand_b;
        `ALU_SUB:   result = operand_a -    operand_b;
        `ALU_SLL:   result = operand_a <<   operand_b[4:0];
        `ALU_SRL:   result = operand_a >>   operand_b[4:0];
        `ALU_SRA:   result = operand_a >>>  operand_b[4:0];
        `ALU_SLT:   result = operand_a <    operand_b;
        `ALU_SLTU:  result = $unsigned(operand_a) < $unsigned(operand_b);
        `ALU_XOR:   result = operand_a ^    operand_b;
        `ALU_OR:    result = operand_a |    operand_b;
        `ALU_AND:   result = operand_a &    operand_b;
`ifdef M_MODULE
        `ALU_MUL:   result = signed_multiplication[31:0];
        `ALU_MULH:  result = signed_multiplication[63:32];
        `ALU_MULHSU:    result = signed_unsigned_multiplication[63:32];
        `ALU_MULHU: result = unsigned_multiplication[63:32];
        `ALU_DIV:
            if (operand_b == `ZERO) begin
                result = 32'b1;
            end
            else if ((operand_a == 32'h80000000) && (operand_b == 32'b1)) begin
                result = 32'h80000000;
            end
            else begin
                result = operand_a / operand_b;
            end
        `ALU_DIVU:
            if (operand_b == `ZERO) begin
                result = 32'b1;
            end
            else begin
                result = $unsigned(operand_a) / $unsigned(operand_b);
            end
        `ALU_REM:
            if (operand_b == `ZERO) begin
                result = operand_a;
            end
            else if ((operand_a == 32'h80000000) && (operand_b == 32'b1)) begin
                result = `ZERO;
            end
            else begin
                result = operand_a % operand_b;
            end
        `ALU_REMU:
            if (operand_b == `ZERO) begin
                result = operand_a;
            end
            else begin
                result = $unsigned(operand_a) % $unsigned(operand_b);
            end
`endif
        default:
            result = `ZERO;
    endcase
end

`ifdef M_MODULE
    always @ (*) begin
        signed_multiplication   = operand_a * operand_b;
        unsigned_multiplication = $unsigned(operand_a) * $unsigned(operand_b);
        signed_unsigned_multiplication = $signed(operand_a) * $unsigned(operand_b);
    end
`endif

endmodule

