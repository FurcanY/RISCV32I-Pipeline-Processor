# RISC-V Pipeline Tasarımı

Bu proje, RISC-V RV32I Base Instruction Set kullanılarak tasarlanmış pipeline processor implementasyonunu içermektedir.

## RV32I Base Instruction Set

RV32I, RISC-V mimarisinin temel 32-bit integer instruction set'idir. Aşağıdaki temel instruction kategorilerini ve ekstra eklenen instruction'ları içerir:

### 1. R-type Instructions (Register-Register)
- `add rd, rs1, rs2`: rd = rs1 + rs2
- `sub rd, rs1, rs2`: rd = rs1 - rs2
- `and rd, rs1, rs2`: rd = rs1 & rs2
- `or rd, rs1, rs2`: rd = rs1 | rs2
- `xor rd, rs1, rs2`: rd = rs1 ^ rs2
- `slt rd, rs1, rs2`: rd = (rs1 < rs2) ? 1 : 0 (Signed comparison)
- `sltu rd, rs1, rs2`: rd = (rs1 < rs2) ? 1 : 0 (Unsigned comparison)
- `sll rd, rs1, rs2`: rd = rs1 << rs2 (Logical left shift)
- `srl rd, rs1, rs2`: rd = rs1 >> rs2 (Logical right shift)
- `sra rd, rs1, rs2`: rd = rs1 >>> rs2 (Arithmetic right shift)

### 2. I-type Instructions (Immediate)
- `addi rd, rs1, imm`: rd = rs1 + imm
- `andi rd, rs1, imm`: rd = rs1 & imm
- `ori rd, rs1, imm`: rd = rs1 | imm
- `xori rd, rs1, imm`: rd = rs1 ^ imm
- `slti rd, rs1, imm`: rd = (rs1 < imm) ? 1 : 0 (Signed comparison)
- `sltiu rd, rs1, imm`: rd = (rs1 < imm) ? 1 : 0 (Unsigned comparison)
- `lb rd, offset(rs1)`: Load byte
- `lh rd, offset(rs1)`: Load halfword
- `lw rd, offset(rs1)`: Load word
- `lbu rd, offset(rs1)`: Load byte unsigned
- `lhu rd, offset(rs1)`: Load halfword unsigned

### 3. S-type Instructions (Store)
- `sb rs2, offset(rs1)`: Store byte
- `sh rs2, offset(rs1)`: Store halfword
- `sw rs2, offset(rs1)`: Store word

### 4. B-type Instructions (Branch)
- `beq rs1, rs2, offset`: Branch if equal
- `bne rs1, rs2, offset`: Branch if not equal
- `blt rs1, rs2, offset`: Branch if less than (signed)
- `bge rs1, rs2, offset`: Branch if greater than or equal (signed)
- `bltu rs1, rs2, offset`: Branch if less than (unsigned)
- `bgeu rs1, rs2, offset`: Branch if greater than or equal (unsigned)


### 5. U-type Instructions (Upper Immediate)
- `lui rd, imm`: Load upper immediate
- `auipc rd, imm`: Add upper immediate to PC

### 6. J-type Instructions (Jump)
- `jal rd, offset`: Jump and link
- `jalr rd, offset(rs1)`: Jump and link register

### 7.Ekstra eklenen Instructionlar (Bit Manipulation)
- `ctz rd, rs1` : Counts the number of 0’s before the first 1, starting at the least-significant bit
- `clz rd, rs1` : Counts the number of 0’s before the first 1, starting at the most-significant bit
- `cpop rd, rs1`: Counts the number of 1’s in the source register.


---


**verilator --version:** Verilator 5.016 2023-09-16 rev v5.014-149-g57c816f90
