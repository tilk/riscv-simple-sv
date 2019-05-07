
VERILATOR_INCLUDE=/usr/share/verilator/include
VERILATED_SRCS=Vtoplevel.cpp Vtoplevel__Syms.cpp Vtoplevel__Dpi.cpp Vtoplevel___024unit.cpp
OBJS=$(VERILATED_SRCS:.cpp=.o) main.o
CXXFLAGS=-I ${VERILATOR_INCLUDE} -I ${VERILATOR_INCLUDE}/vltstd
VFLAGS=-Wno-fatal -DSINGLE_CYCLE -DRV32I -I. -I../../core/common/ -I../../core/$(CORETYPE)
TESTDIR=../../tests
TESTS=$(notdir $(patsubst %.S,%,$(wildcard $(TESTDIR)/*.S)))

run: $(addsuffix .run,$(TESTS))

%.run: testbench
	./testbench +text_file=$(TESTDIR)/$(@:.run=).text.vh +data_file=$(TESTDIR)/$(@:.run=).data.vh

testbench: ${OBJS}
	${CXX} ${CXXFLAGS} ${OBJS} ${VERILATOR_INCLUDE}/verilated.cpp -o testbench

%.o: %.cpp
	${CXX} ${CXXFLAGS} -c -o $@ $<

main.cpp: ../main.cpp
	cp ../main.cpp .

${VERILATED_SRCS}: $(wildcard ../core/common/*.sv) $(wildcard ../core/$(CORETYPE)/*.sv) config.sv
	verilator ${VFLAGS} --cc ../../core/$(CORETYPE)/toplevel.sv --Mdir .

clean:
	rm -f testbench main.cpp ${OBJS} $(wildcard V*)

