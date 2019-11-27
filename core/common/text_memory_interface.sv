// RISC-V SiMPLE SV -- data memory interface
// BSD 3-Clause License
// (c) 2017-2019, Marek Materzok, University of Wrocław

module text_memory_interface(
    input  clock,
    input  reset,
    input  next_inst,
    input  inst_wait_req,
    input  inst_valid,
    output inst_read_enable,
    output inst_available,
    input  [31:0] inst_data,
    output [31:0] inst
);

    logic [31:0] stored_inst;
    logic has_stored_inst;

    assign inst = has_stored_inst ? stored_inst : inst_data;
    assign inst_read_enable = !has_stored_inst && !inst_valid;
    assign inst_available = inst_valid || has_stored_inst;

    always_ff @(posedge clock)
        if (reset) has_stored_inst <= 1'b0;
        else has_stored_inst <= !next_inst && (has_stored_inst || inst_valid);

    always_ff @(posedge clock)
        if (inst_valid && !has_stored_inst) stored_inst <= inst_data;

endmodule
