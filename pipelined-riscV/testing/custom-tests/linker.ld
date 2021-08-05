    SECTIONS {
       .text 0x00001000 :{
            *(.text)
       }
       textEnd = .;
       .data :{
            *(.data)
            *(.rodata)
       }
       dataEnd = .;
       .bss :{
            *(.common)
            *(.bss)
       }
       bssEnd = .;
    }
