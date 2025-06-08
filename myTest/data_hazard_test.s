.section .text
.globl _start
_start:

# ==== Data Hazard Test Block 1 ====
# Zincirleme RAW (forwarding test)
addi x1, x0, 1
add  x2, x1, x1
add  x3, x2, x1
add  x4, x3, x2
add  x5, x4, x3
add  x6, x5, x4
add  x7, x6, x5
add  x8, x7, x6
add  x9, x8, x7
add  x10, x9, x8
add  x11, x10, x9
add  x12, x11, x10
add  x13, x12, x11
add  x14, x13, x12
add  x15, x14, x13
add  x16, x15, x14
add  x17, x16, x15
add  x18, x17, x16
add  x19, x18, x17
add  x20, x19, x18



# ==== Data Hazard Test Block 2 ====
# rs2 bağımlılığı (ikili zincirleme)
addi x21, x0, 2
addi x22, x0, 3
add  x23, x21, x22
add  x24, x22, x23
add  x25, x23, x24
add  x26, x24, x25
add  x27, x25, x26
add  x28, x26, x27
add  x29, x27, x28
add  x30, x28, x29
add  x31, x29, x30

# ==== Data Hazard Test Block 3 ====
addi x1, x0, 10
addi x2, x1, 5
addi x3, x2, 3
addi x4, x3, 7
addi x5, x4, 2
addi x6, x5, 8
addi x7, x6, 9
addi x8, x7, 4
addi x9, x8, 6
addi x10, x9, 1
addi x11, x10, 2
addi x12, x11, 4
addi x13, x12, 7
addi x14, x13, 5
addi x15, x14, 3
addi x16, x15, 2
addi x17, x16, 6
addi x18, x17, 8
addi x19, x18, 1
addi x20, x19, 9

# ==== Data Hazard Test Block 4 ====

add  x21, x1, x2
sub  x22, x21, x3
and  x23, x22, x4
or   x24, x23, x5
xor  x25, x24, x6
slt  x26, x25, x7
sltu x27, x26, x8
add  x28, x27, x9
sub  x29, x28, x10
and  x30, x29, x11
or   x31, x30, x12
xor  x1, x31, x13
slt  x2, x1, x14
sltu x3, x2, x15
add  x4, x3, x16
sub  x5, x4, x17
and  x6, x5, x18
or   x7, x6, x19
xor  x8, x7, x20

# ==== Data Hazard Test Block 5 ====

addi x9, x0, 111
add  x10, x9, x1
add  x11, x10, x2
add  x12, x11, x3
add  x13, x12, x4
add  x14, x13, x5
add  x15, x14, x6
add  x16, x15, x7
add  x17, x16, x8
add  x18, x17, x9
add  x19, x18, x10
add  x20, x19, x11
add  x21, x20, x12
add  x22, x21, x13
add  x23, x22, x14
add  x24, x23, x15
add  x25, x24, x16
add  x26, x25, x17
add  x27, x26, x18
add  x28, x27, x19
add  x29, x28, x20

# ==== Data Hazard Test Block 6 ====

addi x5, x0, 1
add  x5, x5, x5      
add  x5, x5, x5      
add  x5, x5, x5      
add  x5, x5, x5      
add  x5, x5, x5      
add  x6, x5, x5      
add  x7, x6, x5      
add  x8, x7, x6      

# ==== Data Hazard Test Block 7 ====
addi x10, x0, 10
addi x11, x0, 11
add  x12, x10, x11
add  x13, x12, x10
add  x14, x13, x12
add  x15, x14, x11
add  x16, x15, x13
add  x17, x16, x14
add  x18, x17, x15
add  x19, x18, x16
add  x20, x19, x17
add  x21, x20, x18
add  x22, x21, x19

# ==== Data Hazard Test Block 8 ====
addi x9, x0, 2
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9
add  x9, x9, x9

# ==== Data Hazard Test Block 9 ====
addi x3, x0, 3
addi x4, x0, 4
add  x5, x3, x4
add  x6, x4, x5
add  x7, x5, x6
add  x8, x6, x7
add  x9, x7, x8
add  x10, x8, x9
add  x11, x9, x10
add  x12, x10, x11
add  x13, x11, x12
add  x14, x12, x13
add  x15, x13, x14
add  x16, x14, x15
add  x17, x15, x16
add  x18, x16, x17
add  x19, x17, x18
add  x20, x18, x19

# ==== Data Hazard Test Block 10 ====
addi x6, x0, 6
addi x7, x0, 7
add  x8, x6, x7
add  x9, x7, x8
add  x10, x8, x9
add  x11, x9, x10
add  x12, x10, x11
add  x13, x11, x12
add  x14, x12, x13
add  x15, x13, x14
add  x16, x14, x15
add  x17, x15, x16
add  x18, x16, x17
add  x19, x17, x18
add  x20, x18, x19



done:
    nop
    j done

