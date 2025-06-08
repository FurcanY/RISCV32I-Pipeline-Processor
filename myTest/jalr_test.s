.section .text
.globl _start
_start:


    la   x1, target   

    addi x2, x0, 123        
    addi x3, x0, 0         

    jalr x4, x1, 0          
    addi x3, x0, 999        

target:
    addi x5, x0, 555        
    add  x6, x2, x5         


    jalr x0, x4, 0         


    addi x7, x0, 77    

done:
    nop
    j done
