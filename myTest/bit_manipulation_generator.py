import random

def clz(val):
    return 32 - len(bin(val)[2:]) if val != 0 else 32

def ctz(val):
    if val == 0:
        return 32
    count = 0
    while (val & 1) == 0:
        val >>= 1
        count += 1
    return count

def cpop(val):
    return bin(val & 0xFFFFFFFF).count('1')

def to_hex32(val):
    return f"{val & 0xFFFFFFFF:08x}"

def sign_extend12(x):
    return x if x < 0x800 else x - 0x1000

def lui_hex(rd, imm):
    opcode = 0b0110111
    imm20 = (imm & 0xFFFFF)
    instr = (imm20 << 12) | (rd << 7) | opcode
    return to_hex32(instr)

def addi_hex(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b000
    imm12 = imm & 0xFFF  # 12 bit signed immediate
    instr = (imm12 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return to_hex32(instr)

def instr_hex(mnemonic, rd, rs1):
    funct7 = 0b0110000
    funct3 = 0b001
    opcode = 0b0010011  # OP-IMM (I-type format) - Doğru opcode
    rs2_table = {'clz': 0b00000, 'ctz': 0b00001, 'cpop': 0b00010}
    rs2 = rs2_table[mnemonic]
    
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return to_hex32(instr)

N = 50  # Satır sayısı
pc_start = 0x80000000
mnemonics = ['clz', 'ctz', 'cpop']
regfile = [0]*32
program = []
log = []
pc = pc_start

# --- Başlangıç: Rastgele register doldurma (x1-x31) ---
for reg_num in range(1, 32):
    value = random.randint(0, 0xFFFFFFFF)
    lo12 = value & 0xFFF
    se_lo12 = sign_extend12(lo12)
    hi20 = (value - se_lo12) >> 12
    
    regfile[reg_num] = (hi20 << 12) + se_lo12
    
    asm_lui = f"lui x{reg_num}, 0x{hi20:x}"
    asm_addi = f"addi x{reg_num}, x{reg_num}, {se_lo12}"
    
    hex_lui = lui_hex(reg_num, hi20)
    hex_addi = addi_hex(reg_num, reg_num, se_lo12)
    
    program.append((pc, hex_lui, asm_lui, reg_num, hi20 << 12))
    log.append(f"0x{pc:08x} (0x{hex_lui}) x{reg_num} 0x{(hi20 << 12):08x}")
    pc += 4
    
    program.append((pc, hex_addi, asm_addi, reg_num, regfile[reg_num]))
    log.append(f"0x{pc:08x} (0x{hex_addi}) x{reg_num} 0x{regfile[reg_num]:08x}")
    pc += 4

# --- Ana döngü ---
for i in range(N):
    mnemonic = random.choice(mnemonics)
    rd = random.randint(10, 17)
    rs1 = random.randint(1, 31)
    rs1_val = regfile[rs1]
    
    asm = f"{mnemonic} x{rd}, x{rs1}"
    hex_instr = instr_hex(mnemonic, rd, rs1)
    
    if mnemonic == 'clz':
        result = clz(rs1_val)
    elif mnemonic == 'ctz':
        result = ctz(rs1_val)
    elif mnemonic == 'cpop':
        result = cpop(rs1_val)
    else:
        result = 0
    
    regfile[rd] = result
    program.append((pc, hex_instr, asm, rd, result))
    log.append(f"0x{pc:08x} (0x{hex_instr}) x{rd} 0x{result:08x}")
    pc += 4

# --- Sonuçları yazdır ---
print("Assembly ve Hex Kodları:")
for pc, hex_instr, asm, rd, result in program:
    print(f"{asm:<35} // {hex_instr}")

print("\nLog Çıktısı:")
for line in log:
    print(line)

# --- Encoding doğrulaması ---
print("\nEncoding Doğrulaması:")
print("clz x10, x1 örneği:")
example_hex = instr_hex('clz', 10, 1)
print(f"Hex: {example_hex}")
binary_str = bin(int(example_hex, 16))[2:].zfill(32)
print(f"Binary (32-bit): {binary_str}")
print(f"Binary uzunluk: {len(binary_str)} bit")
print("Beklenen format: funct7[7] rs2[5] rs1[5] funct3[3] rd[5] opcode[7]")
print("                 0110000 00000 00001 001   01010 0110011")

# Test için hex 60139693 kontrol et
test_hex = "60139693"
test_binary = bin(int(test_hex, 16))[2:].zfill(32)
print(f"\nTest - Hex: {test_hex}")
print(f"Test - Binary: {test_binary}")
print(f"Bit alanları:")
print(f"  funct7 (31:25): {test_binary[0:7]} = {int(test_binary[0:7], 2)}")
print(f"  rs2 (24:20):    {test_binary[7:12]} = {int(test_binary[7:12], 2)}")  
print(f"  rs1 (19:15):    {test_binary[12:17]} = {int(test_binary[12:17], 2)}")
print(f"  funct3 (14:12): {test_binary[17:20]} = {int(test_binary[17:20], 2)}")
print(f"  rd (11:7):      {test_binary[20:25]} = {int(test_binary[20:25], 2)}")
print(f"  opcode (6:0):   {test_binary[25:32]} = {int(test_binary[25:32], 2)}")