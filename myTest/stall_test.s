.text
.globl _start
_start:


    addi x1, x0, 0xff
    lui  x2, 0x80000         
    addi x2, x2, 0x200           
    sw   x1, 0(x2)           
    lw   x3, 0(x2)           
    add  x4, x3, x1          

  
    lui  x5, 0x80000
    addi x5, x5, 0x204           
    addi x6, x0, 20
    sw   x6, 0(x5)           
    lw   x7, 0(x5)           
    add  x8, x7, x6
    add  x9, x8, x7

 
    addi x10, x0, 100
    addi x11, x0, 100
    beq  x10, x11, brstall
    addi x12, x0, 42         
brstall:
    addi x13, x10, 7
    add  x14, x13, x10

   
    lui  x15, 0x80000
    addi x15, x15, 0x208       
    addi x16, x0, 0
    addi x17, x0, 8
memloop:
    sw   x17, 0(x15)
    lw   x18, 0(x15)
    add  x19, x18, x17
    addi x16, x16, 1
    blt  x16, x17, memloop


    addi x20, x0, 7
    add  x21, x20, x20   
    add  x22, x21, x20   
    add  x23, x22, x20  
    add  x24, x23, x21   

    lui  x25, 0x80000
    addi x25, x25, 0x20c      
    addi x26, x0, 33
    sw   x26, 0(x25)         
    lw   x27, 0(x25)         
    add  x28, x27, x26
    addi x25, x25, 4         
    sw   x28, 0(x25)         
    lw   x29, 0(x25)         
    add  x30, x29, x28


    lui  x31, 0x80000
    addi x31, x31, 0x210      
    addi x2, x0, 1
    sw   x2, 0(x31)
    lw   x3, 0(x31)
    addi x31, x31, 4         
    sw   x3, 0(x31)
    lw   x4, 0(x31)
    add  x5, x4, x3     
    addi x31, x31, 4         
    sw   x5, 0(x31)
    lw   x6, 0(x31)
    add  x7, x6, x5
    addi x31, x31, 4         
    sw   x7, 0(x31)
    lw   x8, 0(x31)
    add  x9, x8, x7


    addi x10, x0, 5
    addi x11, x0, 0
brloop:
    addi x11, x11, 1
    beq  x11, x10, brend
    add  x12, x11, x10
    add  x13, x12, x10
    add  x14, x13, x11
    j brloop
brend:

done_stall:
    nop
    j done_stall
