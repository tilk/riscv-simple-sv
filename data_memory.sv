// RISC-V SiMPLE SV -- data memory model
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

module data_memory (
	address,
	byteena,
	clock,
	data,
	wren,
	q);

	input	[14:0]  address;
	input	[3:0]  byteena;
	input	  clock;
	input	[31:0]  data;
	input	  wren;
	output	[31:0]  q;
    
    reg [31:0] mem[0:2**15-1];

    reg [31:0] to_write;

    assign q = mem[address];

    always @(*) begin
        to_write = mem[address];
        if (byteena[0]) to_write[0+:8] = data[0+:8];
        if (byteena[1]) to_write[8+:8] = data[8+:8];
        if (byteena[2]) to_write[16+:8] = data[16+:8];
        if (byteena[3]) to_write[24+:8] = data[24+:8];
    end

    always @(posedge clock)
        if (wren) begin
            mem[address] <= to_write;
        end

endmodule

