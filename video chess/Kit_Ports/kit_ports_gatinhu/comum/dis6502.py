# Disassembler 6502 (recursive descent) - para ROMs 4K do Atari 2600
import sys
OPS = {}
def add(m, modes):
    for code, mode in modes: OPS[code] = (m, mode)
T = """ADC 69i 65z 75zx 6Da 7Dax 79ay 61ix 71iy|AND 29i 25z 35zx 2Da 3Dax 39ay 21ix 31iy|ASL 0Aacc 06z 16zx 0Ea 1Eax|
BCC 90r|BCS B0r|BEQ F0r|BIT 24z 2Ca|BMI 30r|BNE D0r|BPL 10r|BRK 00imp|BVC 50r|BVS 70r|CLC 18imp|CLD D8imp|CLI 58imp|CLV B8imp|
CMP C9i C5z D5zx CDa DDax D9ay C1ix D1iy|CPX E0i E4z ECa|CPY C0i C4z CCa|DEC C6z D6zx CEa DEax|DEX CAimp|DEY 88imp|
EOR 49i 45z 55zx 4Da 5Dax 59ay 41ix 51iy|INC E6z F6zx EEa FEax|INX E8imp|INY C8imp|JMP 4Ca 6Cind|JSR 20a|
LDA A9i A5z B5zx ADa BDax B9ay A1ix B1iy|LDX A2i A6z B6zy AEa BEay|LDY A0i A4z B4zx ACa BCax|LSR 4Aacc 46z 56zx 4Ea 5Eax|NOP EAimp|
ORA 09i 05z 15zx 0Da 1Dax 19ay 01ix 11iy|PHA 48imp|PHP 08imp|PLA 68imp|PLP 28imp|ROL 2Aacc 26z 36zx 2Ea 3Eax|ROR 6Aacc 66z 76zx 6Ea 7Eax|
RTI 40imp|RTS 60imp|SBC E9i E5z F5zx EDa FDax F9ay E1ix F1iy|SEC 38imp|SED F8imp|SEI 78imp|STA 85z 95zx 8Da 9Dax 99ay 81ix 91iy|
STX 86z 96zy 8Ea|STY 84z 94zx 8Ca|TAX AAimp|TAY A8imp|TSX BAimp|TXA 8Aimp|TXS 9Aimp|TYA 98imp"""
import re
for grp in T.replace("\n","").split("|"):
    p = grp.split(); m = p[0]
    add(m, [(int(x[:2],16), x[2:]) for x in p[1:]])
SIZE = {'i':2,'z':2,'zx':2,'zy':2,'a':3,'ax':3,'ay':3,'ix':2,'iy':2,'r':2,'imp':1,'acc':1,'ind':3}
# Registradores TIA/RIOT (escrita/leitura)
TIAW = "VSYNC VBLANK WSYNC RSYNC NUSIZ0 NUSIZ1 COLUP0 COLUP1 COLUPF COLUBK CTRLPF REFP0 REFP1 PF0 PF1 PF2 RESP0 RESP1 RESM0 RESM1 RESBL AUDC0 AUDC1 AUDF0 AUDF1 AUDV0 AUDV1 GRP0 GRP1 ENAM0 ENAM1 ENABL HMP0 HMP1 HMM0 HMM1 HMBL VDELP0 VDELP1 VDELBL RESMP0 RESMP1 HMOVE HMCLR CXCLR".split()
TIAR = "CXM0P CXM1P CXP0FB CXP1FB CXM0FB CXM1FB CXBLPF CXPPMM INPT0 INPT1 INPT2 INPT3 INPT4 INPT5".split()
RIOT = {0x280:'SWCHA',0x281:'SWACNT',0x282:'SWCHB',0x283:'SWBCNT',0x284:'INTIM',0x294:'TIM1T',0x295:'TIM8T',0x296:'TIM64T',0x297:'T1024T'}
WRITES = {'STA','STX','STY','INC','DEC','ASL','LSR','ROL','ROR'}
def sym(addr, m):
    if addr < 0x80:
        if m in WRITES and addr < len(TIAW): return TIAW[addr]
        if m not in WRITES and (addr & 0xF) < len(TIAR): return TIAR[addr & 0xF]
    if addr in RIOT: return RIOT[addr]
    return None
rom = open(sys.argv[1],'rb').read()
BASE = 0xF000
def rd(a): return rom[(a - BASE) & 0xFFF]
def norm(a): return BASE | (a & 0xFFF)
reset = norm(rd(0xFFFC) | rd(0xFFFD)<<8); irq = norm(rd(0xFFFE)|rd(0xFFFF)<<8)
code, labels, xrefs = set(), {}, {}
todo = [reset, irq]; labels[reset]='RESET'
while todo:
    pc = todo.pop()
    while True:
        pc = norm(pc)
        if pc in code: break
        op = rd(pc)
        if op not in OPS: break
        m, mode = OPS[op]; n = SIZE[mode]
        for k in range(n): code.add(norm(pc+k))
        if mode == 'r':
            off = rd(pc+1); t = pc+2+(off-256 if off>127 else off)
            labels.setdefault(norm(t), None); todo.append(t)
        if m in ('JSR','JMP') and mode == 'a':
            t = rd(pc+1)|rd(pc+2)<<8
            if t >= 0x1000 or True:
                if (t & 0x1000):
                    labels.setdefault(norm(t), None); todo.append(t)
                    xrefs.setdefault(norm(t), []).append((pc, m))
        if m in ('RTS','RTI','BRK') or (m=='JMP'): break
        pc += n
# nomeia labels
for a in sorted(labels):
    if labels[a] is None:
        labels[a] = ('SUB_%04X' if any(x[1]=='JSR' for x in xrefs.get(a,[])) else 'L%04X') % a
out = []
pc = BASE
while pc <= 0xFFFF:
    if pc in labels: out.append(f"\n{labels[pc]}:")
    if pc in code and rd(pc) in OPS:
        op = rd(pc); m, mode = OPS[op]; n = SIZE[mode]
        b = [rd(pc+k) for k in range(n)]
        v = b[1] if n==2 else (b[1]|b[2]<<8 if n==3 else 0)
        if mode=='r':
            t = norm(pc+2+(v-256 if v>127 else v)); arg = labels.get(t, f"${t:04X}")
        else:
            s = sym(v, m) if mode in ('z','a','zx','ax','ay','zy') else None
            name = s or (labels.get(norm(v)) if mode=='a' and v & 0x1000 else None)
            vv = name or (f"${v:02X}" if n==2 else f"${v:04X}")
            arg = {'i':f"#${v:02X}",'z':vv,'zx':vv+",X",'zy':vv+",Y",'a':vv,'ax':vv+",X",'ay':vv+",Y",
                   'ix':f"(${v:02X},X)",'iy':f"(${v:02X}),Y",'imp':'','acc':'A','ind':f"(${v:04X})"}[mode]
        out.append(f"  {pc:04X}  {' '.join(f'{x:02X}' for x in b):9} {m} {arg}")
        pc += n
    else:
        # bloco de dados
        start = pc; chunk=[]
        while pc<=0xFFFF and pc not in code and len(chunk)<8 and (pc==start or pc not in labels):
            chunk.append(rd(pc)); pc+=1
        out.append(f"  {start:04X}  .byte " + ",".join(f"${x:02X}" for x in chunk))
open(sys.argv[2],'w').write("\n".join(out))
print(f"RESET=${reset:04X} IRQ=${irq:04X} code={len(code)} bytes, data={4096-len(code)} bytes, labels={len(labels)}")
print("subrotinas:", len([a for a in labels.values() if a and a.startswith('SUB')]))
