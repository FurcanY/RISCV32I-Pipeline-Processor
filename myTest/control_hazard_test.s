.section .text
.globl _start
_start:
    lui  x31, 0xDe
    addi x31, x31, 0xAD     # x31 = 0xDEAD

    # === Block 1: Basit Branch (taken / not taken) ===
    addi x1, x0, 5
    addi x2, x0, 5
    addi x3, x0, 6

    beq  x1, x2, branch1_taken    # taken
    addi x4, x0, 11               # flush
branch1_taken:
    addi x4, x0, 22

    bne  x1, x3, branch2_taken    # taken
    addi x5, x0, 44               # flush
branch2_taken:
    addi x5, x0, 55

    bne  x1, x2, branch2_nt       # not taken
    addi x6, x0, 66               # work
branch2_nt:
    addi x7, x0, 77

    beq  x3, x3, branch3_taken    # taken
    addi x8, x0, 88               # flush
branch3_taken:
    addi x8, x0, 99

    # === Block 2: Farklı Branch Türleri ===
    addi x9, x0, 1
    addi x10, x0, 2
    addi x11, x0, 2

    blt x9, x10, blt_taken
    addi x12, x0, 11              # flush
blt_taken:
    addi x12, x0, 22

    bge x10, x11, bge_taken
    addi x13, x0, 33              # flush
bge_taken:
    addi x13, x0, 44

    bltu x9, x10, bltu_taken
    addi x14, x0, 55              # flush
bltu_taken:
    addi x14, x0, 66

    bgeu x10, x9, bgeu_taken
    addi x15, x0, 77              # flush
bgeu_taken:
    addi x15, x0, 88

    # === Block 3: Ardışık ve İç İçe Branchler ===
    addi x16, x0, 7
    addi x17, x0, 7
    addi x18, x0, 3

    beq x16, x17, nest1
    addi x19, x0, 100             # flush
nest1:
    bne x18, x16, nest2
    addi x20, x0, 101             # flush
nest2:
    blt x18, x16, nest3
    addi x21, x0, 102             # flush
nest3:
    bge x17, x18, nest4
    addi x22, x0, 103             # flush
nest4:
    bltu x18, x16, nest5
    addi x23, x0, 104             # flush
nest5:
    bgeu x17, x18, nest6
    addi x24, x0, 105             # flush
nest6:
    addi x25, x0, 106

    # === Block 4: Ardışık Branch Flush Testi ===
    addi x26, x0, 50
    addi x27, x0, 50
    addi x28, x0, 60

    beq x26, x27, flush1
    beq x27, x28, flush2         
    addi x29, x0, 200            
flush1:
    addi x30, x0, 201
flush2:
    addi x31, x0, 202

    # === Block 5: Branch Chain & Loop Test ===
    addi x5, x0, 0
    addi x6, x0, 10

loop_test:
    addi x5, x5, 1
    blt  x5, x6, loop_test
    lui  x7, 0xA
    addi x7, x7, 0xAA

    # === Block 6: Branch ve Jump Zinciri, Register Check ===
    addi x8, x0, 1
    addi x9, x0, 1
    addi x10, x0, 2
    beq  x8, x9, multi1
    lui  x11, 0x1
    addi x11, x11, 0x10
multi1:
    bne  x8, x10, multi2
    lui  x12, 0x2
    addi x12, x12, 0x20
multi2:
    beq  x9, x10, multi3
    lui  x13, 0x3
    addi x13, x13, 0x30
multi3:
    bne  x9, x9, multi4
    lui  x14, 0x4
    addi x14, x14, 0x40
multi4:
    addi x15, x0, 50

    # === Block 7: Jump (jal) Zinciri ===
    jal  x16, jump1
    lui  x17, 0x2
    addi x17, x17, 0x00F
jump1:
    jal  x18, jump2
    lui  x19, 0x2
    addi x19, x19, 0x01F 
jump2:
    jal  x20, jump3
    lui  x21, 0x2
    addi x21, x21, 0x02F
jump3:
    addi x22, x0, 203

done:
    nop
    j done
