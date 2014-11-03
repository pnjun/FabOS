;
; Sets up a basic GDT before switching to protected mode
;

gdt_start:

gdt_null:               ; mandatory null descriptor
    dd 0x0
    dd 0x0

gdt_code:               ; span 4GB of memory ( all we have )
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:               ; span 4GB of memorty ( all we have )
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:


gdt_descriptor:
    dw gdt_end - gdt_start - 1 
    dd gdt_start 


CODE_SEG: equ gdt_code-gdt_start
DATA_SEG: equ gdt_data-gdt_start
