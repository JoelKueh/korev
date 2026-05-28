ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 32K
}

SECTIONS
{
    .text : {
        *(.text*)
    } > RAM

    .rodata : {
        *(.rodata*)
    } > RAM

    . = ALIGN(4);
    .data : {
        *(.data*)
    } > RAM

    . = ALIGN(4);
    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM

    . = ALIGN(4);
    _end = .;
}
