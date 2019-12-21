// RISC-V SiMPLE SV -- testbench
// BSD 3-Clause License
// (c) 2019, Marek Materzok, University of Wrocław

#include "Vtoplevel.h"
#include "verilated.h"
#include <iostream>
#include <iomanip>
#include <memory>
#include <string>

int main(int argc, const char **argv, const char **env)
{
    Verilated::commandArgs(argc, argv);

    bool verbose = false;
    const char *str;
    str = Verilated::commandArgsPlusMatch("verbose");
    if (str && str[0]) verbose = true;

    std::unique_ptr<Vtoplevel> top(new Vtoplevel);

    top->reset = 0;

    for (int time = 0; time < 100000; time++) {
        if (time > 9)
            top->reset = 0;
        else if (time > 4)
            top->reset = 1;
        top->clock = time & 1;
        top->eval();
        if (verbose && top->clock && time > 8) {
            std::cout << std::hex << std::setfill('0')
                      << "pc=" << std::setw(8) << top->pc << " "
                      << "inst=" << std::setw(8) << top->inst << " "
                      << (top->inst_wait_req ? "W" : "w") << " "
                      << (top->inst_valid ? "V" : "v") << " "
                      << (top->inst_read_enable ? "E" : "e") << " "
                      << "addr=" << std::setw(8) << top->bus_address << " "
                      << "in=" << std::setw(8) << top->bus_read_data << " "
                      << (top->bus_wait_req ? "W" : "w") << " "
                      << (top->bus_valid ? "V" : "v") << " "
                      << (top->bus_read_enable ? "E" : "e") << " "
                      << "out=" << std::setw(8) << top->bus_write_data << " "
                      << (top->bus_write_enable ? "E" : "e") << " " 
                      << "fmt=" << (int)top->bus_byte_enable << std::endl;
        }
        if (top->bus_write_enable && top->bus_address == 0xfffffff0) {
            if (top->bus_write_data) {
                std::cout << "PASS " << time << std::endl;
                return 0;
            } else {
                std::cout << "FAIL " << time << std::endl;
                return -1;
            }
        }
    }

    std::cout << "TIMEOUT" << std::endl;

    return -1;
}

