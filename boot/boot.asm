;
; FabOS boot sector
;

[org 0x7c00]
[bits 16]

mov [BOOT_DRIVE] , dl       ; safely store boot drive number

                            ; set up screen and show welcome message
call clear_screen           ; Clear screen

mov bx, WELCOME             ; print out welcome message
call print_string

                            ; load kernel code from disk
mov dh, 0x04                ; read 2k of data (4 sectors)
mov bx, KERNEL_OFFSET       ; store them at KERNEL_OFFSET
mov dl, [BOOT_DRIVE]        ; read from disk BOOT_DRIVE
call disk_load              ; go for it.

mov bx, KERNEL_LOAD         ; print that loading was succesful, we will now enter pmode
call print_string

jmp switch_to_pm            ; We never return from this

jmp $


%include"iolib.asm"         ; simple functions used above
%include"gdt_setup.asm"     ; GDT declaration that we will load


switch_to_pm:               ; Set up basic GDT and switch to 32-bit
    cli                     ; switch off interrupts
    lgdt [gdt_descriptor]   ; load GDT

    push ax                 ; enable A20 gate 
    mov ax, 0x2400
    int 0x15
    pop ax

    mov eax,cr0             ; Switch to protected
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_pm    ; go for 32 bit! (far jump just to flush exectuion cache)

[bits 32]
init_pm:
    mov ax, DATA_SEG        ; Point all segments to DATA_SEG
    mov ds, ax     
    mov ss, ax     
    mov es, ax     
    mov fs, ax     
    mov gs, ax     

    mov ebp, 0x7c00 - 1     ; set up stack just below BIOS AREA
    mov esp, ebp
    jmp BEGIN_PM

BEGIN_PM:
    call KERNEL_OFFSET      ; give control to the loaded kernel
    jmp $                   ; Hang. Kernel never returns.



; ------GLOBAL DATA-------
BOOT_DRIVE: db 0            ; used to store boot drive

KERNEL_OFFSET: equ 0x7e00   ; store the kernel just above the loaded MBR

; ------MESSAGE STRINGS-------
WELCOME:                    ; welcome string + load kernel string
db 'Welcome to FabOS!', 0x0a, 0x0d, 'Loading kernel from disk...',0x0a, 0x0d, 0
KERNEL_LOAD:
db 'Kernel loaded to RAM.', 0x0a, 0x0d, 'Switching to protected mode...',0x0a, 0x0d, 0


; ------FINAL PADDING--------
                            ; 0-Padding and magic number

times 510-($-$$) db 0       ; Pad with zeros till 510th byte
dw 0xaa55                   ; Magic number
