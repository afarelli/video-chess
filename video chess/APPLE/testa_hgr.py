# Roda o binario num 6502 emulado e renderiza a HGR com cores por artefato
import sys
sys.path.insert(0, '/home/claude/py65')
from py65.devices.mpu6502 import MPU
from PIL import Image
bin_ = open(sys.argv[1], 'rb').read()
m = MPU(); m.memory[0x800:0x800 + len(bin_)] = list(bin_); m.pc = 0x801
for _ in range(3_000_000):
    m.step()
    if m.memory[m.pc] == 0x4C and (m.memory[m.pc+1] | m.memory[m.pc+2] << 8) == m.pc: break
print(f"parou em ${m.pc:04X}, ciclos={m.processorCycles}")
def hgr(y): return 0x2000 + (y & 7)*0x400 + ((y >> 3) & 7)*0x80 + (y >> 6)*0x28
COL = {(0,0):(200,60,255),(0,1):(40,220,40),(1,0):(40,120,255),(1,1):(255,120,20)}
img = Image.new('RGB', (560, 384))
for y in range(192):
    bits, pal = [], []
    for b in range(40):
        v = m.memory[hgr(y) + b]
        for k in range(7): bits.append(v >> k & 1); pal.append(v >> 7)
    for x in range(280):
        on = bits[x]; L = x > 0 and bits[x-1]; R = x < 279 and bits[x+1]
        if on and (L or R): c = (255,255,255)
        elif on: c = COL[(pal[x], x & 1)]
        elif L and R: c = COL[(pal[x], (x+1) & 1)]   # preenchimento NTSC
        else: c = (0,0,0)
        for dx in (0,1):
            for dy in (0,1): img.putpixel((2*x+dx, 2*y+dy), c)
img.save(sys.argv[2])
