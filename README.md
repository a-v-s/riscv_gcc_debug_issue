# RISCV DEBUGGING ISSUE

When building a firmware with gcc 12 I an into issues with debugging. GDB 
acted like the stack was corrupt, but the firmware appeared to function
without problems. The same firmware built with gcc 8 did not have this issue. 

The issue seems to be triggered when
* assembly listing is enabled when compiling a C file
* a function is passed a pointer as parameter


## Building
``` 
make
riscv-none-elf-gcc -c main.c -o main.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3
riscv-none-elf-gcc -c startup.S -o startup.good.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3
riscv-none-elf-gcc main.good.o startup.good.o -o test.good.elf -T test.ld  --specs=nosys.specs --specs=nano.specs -nostartfiles -Wl,--no-relax -Wl,--gc-sections -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wl,-Map=test.good.map
riscv-none-elf-gcc -c main.c -o main.bad.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wa,-a=main.bad.lst
riscv-none-elf-gcc -c startup.S -o startup.bad.o -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3
riscv-none-elf-gcc main.bad.o startup.bad.o -o test.bad.elf -T test.ld  --specs=nosys.specs --specs=nano.specs -nostartfiles -Wl,--no-relax -Wl,--gc-sections -march=rv32imac -mabi=ilp32 -mcmodel=medlow  -fdata-sections -ffunction-sections  -misa-spec=2.2 -O0 -g3 -Wl,-Map=test.bad.map
```

## Testing
```
$ dwarfdump test.good.elf  | grep ERROR 
```
No ERROR for the good elf file, which had no assembly listed generated during the build


```
$ dwarfdump test.bad.elf | grep ERROR
ERROR: on getting fde details for fde row for address 0x00000006
ERROR: Printing fde 0 fails. Error DW_DLE_DF_FRAME_DECODING_ERROR(193)
ERROR: printing fdes fails. DW_DLE_DF_FRAME_DECODING_ERROR(193)  Attempting to continue. 
There were 3 DWARF errors reported: see ERROR above.
```
ERRORs show up for the bad elf file, which has assembly listing generated during the build

## Versions 

These tests have been taken with the following versions

```
$ riscv-none-elf-gcc --version 
riscv-none-elf-gcc (xPack GNU RISC-V Embedded GCC x86_64) 12.2.0
Copyright (C) 2022 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

$ riscv-none-elf-as --version 
GNU assembler (xPack GNU RISC-V Embedded GCC x86_64) 2.38
Copyright (C) 2022 Free Software Foundation, Inc.
This program is free software; you may redistribute it under the terms of
the GNU General Public License version 3 or later.
This program has absolutely no warranty.
This assembler was configured for a target of `riscv-none-elf'.
```
