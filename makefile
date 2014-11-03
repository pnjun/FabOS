all: boot kernel
    

boot:
    nasm ./boot/boot.asm -f bin -o ./boot/boot.bin

kernel: 

