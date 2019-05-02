
VERILATOR_INCLUDE=/usr/share/verilator/include
VERILATED_SRCS=Vriscv_core.cpp Vriscv_core__Syms.cpp Vriscv_core__Dpi.cpp Vriscv_core___024unit.cpp
OBJS=$(VERILATED_SRCS:.cpp=.o) main.o
CXXFLAGS=-I ${VERILATOR_INCLUDE} -I ${VERILATOR_INCLUDE}/vltstd
VFLAGS=-Wno-fatal -DUNICICLO -DRV32I -DTEXT_HEX="text_mem_file()" -DDATA_HEX="data_mem_file()" -I. -I../core 
TESTDIR=../tests
TESTS=$(notdir $(patsubst %.S,%,$(wildcard $(TESTDIR)/*.S)))

run: $(addsuffix .run,$(TESTS))

%.run: testbench
	./testbench +text_file=$(TESTDIR)/$(@:.run=).text.vh +data_file=$(TESTDIR)/$(@:.run=).data.vh

testbench: ${OBJS}
	${CXX} ${CXXFLAGS} ${OBJS} ${VERILATOR_INCLUDE}/verilated.cpp -o testbench

%.o: %.cpp
	${CXX} ${CXXFLAGS} -c -o $@ $<

${VERILATED_SRCS}: $(wildcard ../core/*.sv) config.sv
	verilator ${VFLAGS} -I../core --cc ../core/riscv_core.sv --Mdir .

clean:
	rm -f testbench ${OBJS} $(wildcard V*)

