// RISC-V SiMPLE SV -- program text memory
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

module text_memory (
	address,
	clock,
	q);

	input	[13:0]  address;
	input	  clock;
	output	[31:0]  q;

    reg [31:0] mem[0:2**14-1];

    assign q = mem[address];
  
    initial $readmemh("test.hex", mem);
   
endmodule
