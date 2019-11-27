// RISC-V SiMPLE SV -- program text memory bus
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module example_text_memory_bus (
    input  clock,
    input  reset,
    input  read_enable,
    input  [31:0] address,
    output [31:0] read_data,
    output        wait_req,
    output        valid
);

    parameter LATENCY = 5;
    parameter MAX_READS = 3;

    logic [31:0] fetched;

    logic [31:0] last_address     [0:LATENCY];
    logic        last_read_enable [0:LATENCY];

    logic [7:0]  num_reads;

    integer i;
    
    example_text_memory text_memory(
        .address    (last_address[LATENCY][`TEXT_BITS-1:2]),
        .clock      (clock),
        .q          (fetched)
    );
   
    assign read_data = 
        last_read_enable[LATENCY] && last_address[LATENCY] >= `TEXT_BEGIN && last_address[LATENCY] <= `TEXT_END
        ? fetched
        : 32'hxxxxxxxx;

    assign valid = last_read_enable[LATENCY];
    assign wait_req = reset || (num_reads + read_enable >= MAX_READS && !last_read_enable[LATENCY]);

    always_comb begin
        num_reads = 0;
        for (i = 1; i <= LATENCY; i++) num_reads += last_read_enable[i];
    end

    always_ff @(posedge clock) begin
        for (i = 1; i < LATENCY; i++) last_address[i+1] <= last_address[i];
        last_address[1] <= last_address[0];
    end
    
    always_ff @(posedge clock or posedge reset)
        if (reset) for (i = 1; i <= LATENCY; i++) last_read_enable[i] <= 1'b0;
        else begin
            for (i = 1; i < LATENCY; i++) last_read_enable[i+1] <= last_read_enable[i];
            last_read_enable[1] <= last_read_enable[0] && num_reads < MAX_READS;
        end

    assign last_address[0] = address;
    assign last_read_enable[0] = read_enable;

endmodule

