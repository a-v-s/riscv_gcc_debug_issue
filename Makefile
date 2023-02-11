default: test.good.elf test.bad.elf

main.bad.o:
	riscv-none-elf-gcc -c -march=rv32imac -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 -O0 -g3 -Wall -fdata-sections -ffunction-sections -MMD -MP -MF"main.bad.c.d" -Wa,-a,-ad,-alms=main.bad.lst main.c -o main.bad.o


startup.bad.o:
	riscv-none-elf-gcc -x assembler-with-cpp -c  -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2   -O0 -g3 -Wall -fdata-sections -ffunction-sections  -MMD -MP -MF"startup.bad.S.d" startup.S -o startup.bad.o

test.bad.elf: main.bad.o startup.bad.o
	riscv-none-elf-gcc main.bad.o startup.bad.o -nostartfiles -Wl,--no-relax -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 --specs=nosys.specs --specs=nano.specs -Ttest.ld   -Wl,--gc-sections -Wl,-Map=test.bad.map,--cref -o test.bad.elf



main.good.o:
	riscv-none-elf-gcc -c main.c -o main.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3

startup.good.o:
	riscv-none-elf-gcc -c startup.S -o startup.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3

test.good.elf: main.good.o startup.good.o
	riscv-none-elf-gcc main.good.o startup.good.o -o test.good.elf -T test.ld  --specs=nosys.specs --specs=nano.specs -nostartfiles -Wl,--no-relax -Wl,--gc-sections -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wl,-Map=test.good.map



clean:
	rm -f *.o *.elf *.d *.lst *.map

