# RISCV DEBUGGING ISSUE

When building a firmware with gcc 12 I an into issues with debugging. GDB 
acted like the stack was corrupt, but the firmware appeared to function
without problems. The same firmware built with gcc 8 did not have this issue. 

The issue seems to be triggered when
* assembly listing is enabled when compiling a C file
* a function is passed a pointer as parameter

## Known bad test case

### Building 
```
]$ make test.bad.elf 
riscv-none-elf-gcc -c -march=rv32imac -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 -O0 -g3 -Wall -fdata-sections -ffunction-sections -MMD -MP -MF"main.bad.c.d" -Wa,-a,-ad,-alms=main.bad.lst main.c -o main.bad.o
riscv-none-elf-gcc -x assembler-with-cpp -c  -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2   -O0 -g3 -Wall -fdata-sections -ffunction-sections  -MMD -MP -MF"startup.bad.S.d" startup.S -o startup.bad.o
riscv-none-elf-gcc main.bad.o startup.bad.o -nostartfiles -Wl,--no-relax -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 --specs=nosys.specs --specs=nano.specs -Ttest.ld   -Wl,--gc-sections -Wl,-Map=test.bad.map,--cref -o test.bad.elf
```

### Testing the DWARF
```
$ dwarfdump test.bad.elf  | grep ERROR 
ERROR: on getting fde details for fde row for address 0x00000006
ERROR: Printing fde 0 fails. Error DW_DLE_DF_FRAME_DECODING_ERROR(193)
ERROR: printing fdes fails. DW_DLE_DF_FRAME_DECODING_ERROR(193)  Attempting to continue. 
There were 3 DWARF errors reported: see ERROR above.
```

The DWARF has errors

## The test case with assembly listing generation removed

### Building
```
[andre@mortar clean_case]$ make test.nolst.elf 
riscv-none-elf-gcc -c -march=rv32imac -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 -O0 -g3 -Wall -fdata-sections -ffunction-sections -MMD -MP -MF"main.nolst.c.d" main.c -o main.nolst.o
riscv-none-elf-gcc -x assembler-with-cpp -c  -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2   -O0 -g3 -Wall -fdata-sections -ffunction-sections  -MMD -MP -MF"startup.nolst.S.d" startup.S -o startup.nolst.o
riscv-none-elf-gcc main.nolst.o startup.nolst.o -nostartfiles -Wl,--no-relax -march=rv32imac   -mabi=ilp32 -mcmodel=medlow -misa-spec=2.2 --specs=nosys.specs --specs=nano.specs -Ttest.ld   -Wl,--gc-sections -Wl,-Map=test.nolst.map,--cref -o test.nolst.elf
```

### Testing the DWARF
```
[andre@mortar clean_case]$ dwarfdump test.nolst.elf  | grep ERROR 
```

The DWARF has no errors
