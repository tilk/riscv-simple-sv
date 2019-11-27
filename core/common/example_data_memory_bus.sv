// RISC-V SiMPLE SV -- data memory bus
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module example_data_memory_bus (
    input  clock,
    input  reset,
    input  [31:0] address,
    output [31:0] read_data,
    input  [31:0] write_data,
    input   [3:0] byte_enable,
    input         read_enable,
    input         write_enable,
    output        wait_req,
    output        valid
);

    parameter LATENCY = 0;
    parameter MAX_READS = 1;
    parameter MAX_WRITES = 1;

    logic [31:0] fetched;
    logic is_data_memory;
    
    logic [31:0] last_address      [1:LATENCY];
    logic [31:0] last_write_data   [1:LATENCY];
    logic  [3:0] last_byte_enable  [1:LATENCY];
    logic        last_read_enable  [1:LATENCY];
    logic        last_write_enable [1:LATENCY];

    logic [31:0] last_address_h      [0:LATENCY];
    logic [31:0] last_write_data_h   [0:LATENCY];
    logic  [3:0] last_byte_enable_h  [0:LATENCY];
    logic        last_read_enable_h  [0:LATENCY];
    logic        last_write_enable_h [0:LATENCY];

    logic [7:0]  num_reads;
    logic [7:0]  num_writes;

    integer i;

    assign is_data_memory = last_address_h[LATENCY] >= `DATA_BEGIN && last_address_h[LATENCY] <= `DATA_END;
    
    example_data_memory data_memory(
        .clock      (clock),
        .address    (last_address_h[LATENCY][`DATA_BITS-1:2]),
        .byteena    (last_byte_enable_h[LATENCY]),
        .data       (last_write_data_h[LATENCY]),
        .wren       (last_write_enable_h[LATENCY] && is_data_memory),
        .q          (fetched)
    );
   
    assign read_data = 
        last_read_enable_h[LATENCY] && is_data_memory
        ? fetched
        : 32'hxxxxxxxx;

    assign valid = last_read_enable_h[LATENCY];
    assign wait_req = num_reads >= MAX_READS && !last_read_enable_h[LATENCY]
                   || num_writes >= MAX_WRITES && !last_write_enable_h[LATENCY];

    always_comb begin
        num_reads = 0;
        for (i = 1; i <= LATENCY; i++) num_reads = num_reads + last_read_enable[i];
        num_writes = 0;
        for (i = 1; i <= LATENCY; i++) num_writes = num_writes + last_write_enable[i];
    end

    always_ff @(posedge clock) begin
        for (i = 1; i < LATENCY; i++) begin
            last_address[i+1] <= last_address[i];
            last_write_data[i+1] <= last_write_data[i];
            last_byte_enable[i+1] <= last_byte_enable[i];
        end;
        last_address[1] <= address;
        last_write_data[1] <= write_data;
        last_byte_enable[1] <= byte_enable;
    end
    
    always_ff @(posedge clock or posedge reset)
        if (reset) for (i = 1; i <= LATENCY; i++) last_read_enable[i] <= 1'b0;
        else begin
            for (i = 1; i < LATENCY; i++) last_read_enable[i+1] <= last_read_enable[i];
            last_read_enable[1] <= read_enable && !wait_req;
        end

    always_ff @(posedge clock or posedge reset)
        if (reset) for (i = 1; i <= LATENCY; i++) last_write_enable[i] <= 1'b0;
        else begin
            for (i = 1; i < LATENCY; i++) last_write_enable[i+1] <= last_write_enable[i];
            last_write_enable[1] <= write_enable && !wait_req;
        end

    genvar g;

    assign last_address_h[0] = address;
    assign last_write_data_h[0] = write_data;
    assign last_byte_enable_h[0] = byte_enable;
    assign last_read_enable_h[0] = read_enable;
    assign last_write_enable_h[0] = write_enable;

    for (g = 1; g <= LATENCY; g++) begin
        assign last_address_h[g] = last_address[g];
        assign last_write_data_h[g] = last_write_data[g];
        assign last_byte_enable_h[g] = last_byte_enable[g];
        assign last_read_enable_h[g] = last_read_enable[g];
        assign last_write_enable_h[g] = last_write_enable[g];
    end

endmodule

