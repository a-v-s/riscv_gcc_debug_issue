# RISCV DEBUGGING ISSUE

When building a firmware with gcc 12 I an into issues with debugging. GDB 
acted like the stack was corrupt, but the firmware appeared to function
without problems. The same firmware built with gcc 8 did not have this issue. 

Investigating the problem, it looks like gcc 12 emits bad DWARF when a
function is called with a pointer as parameter, when certain parameters
are passed during compilation.

I am still in the process of determining the exact parameter that triggers
this issue. For now, there is a Makefile with known good and known bad results.

```
$ make
riscv-none-elf-gcc -c main.c -o main.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3
riscv-none-elf-gcc -c startup.S -o startup.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3
riscv-none-elf-gcc main.good.o startup.good.o -o test.good.elf -T test.ld  --specs=nosys.specs --specs=nano.specs -nostartfiles -Wl,--no-relax -Wl,--gc-sections -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wl,-Map=test.good.map
riscv-none-elf-gcc -c -march=rv32imac -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 -O0 -g3 -Wall -fdata-sections -ffunction-sections -MMD -MP -MF"main.bad.c.d" -Wa,-a,-ad,-alms=main.bad.lst main.c -o main.bad.o
riscv-none-elf-gcc -x assembler-with-cpp -c  -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2   -O0 -g3 -Wall -fdata-sections -ffunction-sections  -MMD -MP -MF"startup.bad.S.d" startup.S -o startup.bad.o
riscv-none-elf-gcc main.bad.o startup.bad.o -nostartfiles -Wl,--no-relax -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 --specs=nosys.specs --specs=nano.specs -Ttest.ld   -Wl,--gc-sections -Wl,-Map=test.bad.map,--cref -o test.bad.elf
$ dwarfdump test.good.elf  | grep ERROR 
$ dwarfdump test.bad.elf  | grep ERROR 
ERROR: on getting fde details for fde row for address 0x00000006
ERROR: Printing fde 0 fails. Error DW_DLE_DF_FRAME_DECODING_ERROR(193)
ERROR: printing fdes fails. DW_DLE_DF_FRAME_DECODING_ERROR(193)  Attempting to continue. 
There were 3 DWARF errors reported: see ERROR above.

```
