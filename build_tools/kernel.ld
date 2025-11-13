/* src/kernel.ld - Linker script for a 16-bit kernel/game */

OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)

/* Define the entry point function for the kernel/game */
ENTRY(_start)

/* Define the memory layout of the final binary */
SECTIONS
{
    /* Set the starting address (load address) for the kernel.
       0x1000 is a common convention for the first 4KB after the bootloader/BIOS data.
       This must match the address your boot.asm loads the kernel to. */
    . = 0x1000;

    /* .text section: Executable code */
    .text :
    {
        *(.text) /* Place all .text sections from all input files here */
    }

    /* .data section: Initialized data (variables with values) */
    .data :
    {
        *(.data) /* Place all .data sections from all input files here */
    }

    /* .bss section: Uninitialized data (variables reserved memory, set to 0 by the kernel) */
    .bss :
    {
        *(.bss) /* Place all .bss sections from all input files here */
    }

    /* End of all linked sections */
    /DISCARD/ :
    {
        *(.eh_frame) /* Discard debugging/unnecessary sections */
    }
}