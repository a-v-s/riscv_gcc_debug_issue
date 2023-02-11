.extern main


/*
	Minimal startup file without interrupt support
	Placing the Reset Handler in the .vtor section makes it to be placed
	at the beginning of flash. This will work out for RISCV MCUs, 
	as they start executing at the beginning of flash, and as we keep
	interrupts disabled, further instructions won't cause a problem.

*/
.section	.vtor,"ax",@progbits
.global Reset_Handler
.type Reset_Handler,@function
Reset_Handler:
.option push
.option	norelax
	csrs mstatus, 0
	la gp, __global_pointer$
.option	pop
1:
	la sp, __stack_end__
2:
	/* Load data section from flash to RAM */
	la a0, __data_lma__
	la a1, __data_vma__
	la a2, __data_end__
	bgeu a1, a2, 2f
1:
	lw t0, (a0)
	sw t0, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b
2:
	/* clear bss section */
	la a0, __bss_start__
	la a1, __bss_end__
	bgeu a0, a1, 2f
1:
	sw zero, (a0)
	addi a0, a0, 4
	bltu a0, a1, 1b
2:
	j main



# As required for the gcc8 build
.global _exit
_exit:
	j _exit
