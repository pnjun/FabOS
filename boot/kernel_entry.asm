[bits 32]
[extern main]

call main           ; call extern main function (inside C kernel source)
jmp $               ; hang forever when kernel exits
