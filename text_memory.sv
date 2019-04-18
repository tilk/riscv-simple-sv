module text_memory (
	address,
	clock,
	q);

	input	[13:0]  address;
	input	  clock;
	output	[31:0]  q;

    reg [31:0] mem[0:2**14-1];

//    reg [13:0] addr_copy;

//    always @(posedge clock) addr_copy <= address;

    assign q = mem[address];
  
    initial $readmemh("test.hex", mem);
   
endmodule
