
CC=riscv32-unknown-elf-gcc
LD=riscv32-unknown-elf-ld
LDFLAGS=-Tlink.ld
SRCS=$(wildcard *.S)
OBJS=$(SRCS:.S=.o)
ELFS=$(SRCS:.S=.elf)

all: ${ELFS}

%.o: %.S test_macros.h riscv_test.h
	${CC} -c -march=rv32i -o $@ $<

%.elf: %.o 
	${LD} ${LDFLAGS} $< -o $@

clean:
	rm -f ${OBJS} ${ELFS}

