default: test.good.elf test.bad.elf


################################################################################
# Known good case. 
################################################################################
main.good.o:
	riscv-none-elf-gcc -c main.c -o main.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3

startup.good.o:
	riscv-none-elf-gcc -c startup.S -o startup.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3

test.good.elf: main.good.o startup.good.o
	riscv-none-elf-gcc main.good.o startup.good.o -o test.good.elf -T test.ld  --specs=nosys.specs --specs=nano.specs -nostartfiles -Wl,--no-relax -Wl,--gc-sections -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wl,-Map=test.good.map
################################################################################


################################################################################
# Bad case. adding  "-Wa,-a,-ad,-alms=main.bad.lst" to the gcc parameters
# triggers the generation of bad DWARF data 
# "-Wa" passes the following parameters to the assembler
# gas manual: https://sourceware.org/binutils/docs-2.40/as.pdf
# -a[cdghlmns]
# Turn on listings, in any of a variety of ways:
# -ac omit false conditionals
# -ad omit debugging directives
# -ag include general information, like as version and options passed
# -ah include high-level source
# -al include assembly
# -am include macro expansions
# -an omit forms processing
# -as include symbols
# =file set the name of the listing fi

################################################################################
main.bad.o:
	riscv-none-elf-gcc -c main.c -o main.bad.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wa,-a=main.bad.lst

startup.bad.o:
	riscv-none-elf-gcc -c startup.S -o startup.bad.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3

test.bad.elf: main.bad.o startup.bad.o
	riscv-none-elf-gcc main.bad.o startup.bad.o -o test.bad.elf -T test.ld  --specs=nosys.specs --specs=nano.specs -nostartfiles -Wl,--no-relax -Wl,--gc-sections -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wl,-Map=test.bad.map
################################################################################





clean:
	rm -f *.o *.elf *.d *.lst *.map

