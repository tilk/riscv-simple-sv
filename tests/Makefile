
CC=riscv32-unknown-elf-gcc
LD=riscv32-unknown-elf-ld
OBJCOPY=riscv32-unknown-elf-objcopy
LDFLAGS=-Tlink.ld
SRCS=$(wildcard *.S)
OBJS=$(SRCS:.S=.o)
ELFS=$(SRCS:.S=.elf)
VHS=$(SRCS:.S=.text.vh) $(SRCS:.S=.data.vh)

all: ${VHS}

%.o: %.S test_macros.h riscv_test.h
	${CC} -c -march=rv32i -o $@ $<

%.elf: %.o 
	${LD} ${LDFLAGS} $< -o $@

%.text.vh: %.elf
	${OBJCOPY} -O verilog $< $@ -j .init -j .text --change-addresses -0x400000

%.data.vh: %.elf
	${OBJCOPY} -O verilog $< $@ -j .data -j .eh_frame -j .fini_array -j .init_array --change-addresses -0x80000000

clean:
	rm -f ${OBJS} ${ELFS} ${VHS}

