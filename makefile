all: boot kernel
	cat boot.bin kernel.bin > FabOS.bin

boot:       
	nasm ./boot/boot.asm -f bin -o ./boot.bin

kernel: kernel_entry 
	g++ -ffreestanding -c ./kernel/main.cpp -o ./kernel/kernel.o
	ld -o ./kernel.bin -Ttext 0x7e00 kernel_entry.o kernel.o --oformat binary

kernel_entry:
	nasm ./boot/kernel_entry.asm -f elf -o ./boot/kernel_entry.o
