ENTRY( Reset_Handler )

MEMORY
{
	FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 64K  
	RAM (xrw)  : ORIGIN = 0x20000000, LENGTH = 20K
}

__STACK_SIZE = 0x00000400;

PROVIDE( _stack_size = __STACK_SIZE );

SECTIONS
{

	.startup : 
	{
		KEEP(*(.startup))
	} > FLASH
	

  .text :
  {
    *(.rodata .rodata.*)  
    *(.srodata .srodata.*)
    *(.text .text.*)
  } >FLASH


/* BSS section: Uninitialised data, will be zeroed on start */
    .bss (NOLOAD) :
    {
        PROVIDE ( __bss_start__ = . );
		*(.sbss*)
		*(.bss .bss.*)
        *(COMMON)
        PROVIDE ( __bss_end__ = . );
    } > RAM


	  .lalign :
	  {
	    . = ALIGN(4);
	    PROVIDE( __data_lma__ = . );
	  } >FLASH AT>FLASH 

/* Memory alignment and provide _data_vma for the initialisation 
   The initialised data, where to write the data
*/	
	  .dalign :
	  {
	    . = ALIGN(4);
        PROVIDE( __data_vma__ = . );	    
	  } >RAM AT >FLASH 





    .data :
    {
		PROVIDE( __global_pointer$ = . + 0x800 );
		PROVIDE( __data_start__ = . );
		*(.rdata) 
		*(.data .data.*)
		*(.sdata .sdata.*)
        PROVIDE( __data_end__ = . );
    } > RAM AT >FLASH




	.stack (ORIGIN(RAM) + LENGTH(RAM) - __STACK_SIZE ) (COPY) :
	{
		. = ALIGN(8);
        PROVIDE( __stack_start__ = . );
		__StackLimit = .;
		. = . + __STACK_SIZE;
		. = ALIGN(8);
		__StackTop = .;
		PROVIDE( __stack_end__ = . );
	} > RAM
	
}
