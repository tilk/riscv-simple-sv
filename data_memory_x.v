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
    
    reg [31:0] data[0:2**14-1];

    reg [13:0] addr_copy;
    reg [31:0] to_write;

    always @(posedge clock) addr_copy <= address;

    assign q = data[addr_copy];

    always @(posedge clock)
        if (wren) begin
            to_write = data[address];
            if (byteena[0]) to_write[8+:0] <= data[8+:0];
            if (byteena[1]) to_write[8+:8] <= data[8+:8];
            if (byteena[2]) to_write[8+:16] <= data[8+:16];
            if (byteena[3]) to_write[8+:24] <= data[8+:24];
            data[address] <= to_write;
        end

endmodule

