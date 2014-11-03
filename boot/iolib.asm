;
; FabOS     BIOS I/O Library
;

; clears the teletype screen
clear_screen:
    pusha
    mov ax, 0x0700          ; tell BIOS video mode, scroll all lines
    mov bh, 0x07            ; white on black
    mov cx, 0x0000          ; starting col=0 row=0
    mov dx, 0x184f          ; end col=79, row=24
    int 0x10
    
    mov ah, 0x02            ; set cursor mode
    mov bh, 0x00            ; page 0
    mov dx, 0x0000          ; set cursor to 0,0
    int 0x10

    popa
    ret

; prints the string stored starting in [bx]
print_string:
    pusha
    mov ah, 0x0e            ; set teletype mode

    .loop_entry:
        mov al, [bx]        ; fetch character
        cmp al,0            ; end loop if string is finished
        je .loop_end        ; if string is finished, exit loop
        int 0x10            ; else, print the charachter
        add bx, 1           ; increment char pointer by 1
        jmp .loop_entry     ; loop
    .loop_end:

    popa
    ret    

; Loads dh sectors from drive dl, stores them at es:bx 
; halts on error
disk_load:
    push dx

    mov ah, 0x02            ; set BIOS read from disk function
    mov al, dh              ; read dh sectors
    mov ch, 0x00            ; 0 head
    mov dh, 0x00            ; 0 cylinder
    mov cl, 0x02            ; second sector (first sector is MBR -> us)
    int 0x13                ; do it

    jc .disk_error          ; check for BIOS errors

    pop dx                  ; restore dx to it's original value
    cmp dh,al               ; check if we have read all the sectors we were supposed to
    jne .disk_error         ; halt if error

    ret

                            ; prints error message and halts
    .disk_error:
        mov bx, DISK_ERROR
        add bx, 0x7c00
        call print_string
        jmp $


; DATA
DISK_ERROR:
    db 'Error reading from disk. Stopping', 0x0a, 0x0d, 0
