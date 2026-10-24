# Simula um Apple II 64K (so o necessario) rodando vchess.bin, com teclas roteirizadas
import sys
sys.path.insert(0, '/home/claude/py65'); sys.path.insert(0, '.')
from py65.devices.mpu6502 import MPU
import testa_hgr_lib as R

class AppleMem(bytearray):
    def __init__(s): super().__init__(0x10000); s.key = 0; s.kreads = 0
    def __getitem__(s, a):
        if isinstance(a, int) and 0xC000 <= a <= 0xC0FF:
            if a == 0xC000: s.kreads += 1; return s.key
            if a == 0xC010: s.key &= 0x7F
            return 0
        return bytearray.__getitem__(s, a)
    def __setitem__(s, a, v):
        if isinstance(a, int) and 0xC000 <= a <= 0xC0FF:
            if a == 0xC010: s.key &= 0x7F
            return
        bytearray.__setitem__(s, a, v)

LOAD = 0x3FFD
def boot(binfile, tick=None, titulo=True):
    mem = AppleMem(); m = MPU(memory=mem)
    b = open(binfile, 'rb').read(); mem[LOAD:LOAD + len(b)] = b
    m.pc = LOAD
    if titulo:                      # passa pela tela de titulo: espera ela pedir tecla
        while mem.kreads < 3000: m.step()
        mem.key = 0xA0 | 0x80
    return m, mem
def tick_de(lst):                   # endereco do TICK a partir da listagem do ca65
    import re
    off = int(re.search(r'\n([0-9A-F]{6})r 1\s+(?:[0-9A-F]{2} ?)*\s*TICK:', lst).group(1), 16)
    return LOAD + off

KEYS = {'u': 0xC9, 'd': 0xCB, 'l': 0xCA, 'r': 0xCC, ' ': 0xA0, 'R': 0xD2, '1': 0xB1, '2': 0xB2}
def run(m, mem, tick, frames):
    n = 0
    while n < frames:
        if m.pc == tick: n += 1
        m.step()
def roteiro(m, mem, tick, s, gap=70):
    for c in s:                       # ~ uma tecla por segundo, como uma pessoa
        mem.key = KEYS[c] | 0x80
        run(m, mem, tick, gap)
def tab(mem):
    nm = '.KQBNRP?'
    for r in range(8):
        print(8 - r, ' '.join((lambda v: ('x' if v & 15 == 8 else (nm[v & 7] if v & 8 else nm[v & 7].lower())))(mem[0x80 + r*8 + c]) for c in range(8)))
