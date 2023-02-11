# RISCV DEBUGGING ISSUE

When building a firmware with gcc 12 I an into issues with debugging. GDB 
acted like the stack was corrupt, but the firmware appeared to function
without problems. The same firmware built with gcc 8 did not have this issue. 

Investigating the problem, it looks like gcc 12 emits bad DWARF when a
function is called with a pointer as parameter, when certain parameters
are passed during compilation.

I am still in the process of determining the exact parameter that triggers
this issue. For now, there is a Makefile with known good and known bad results.
