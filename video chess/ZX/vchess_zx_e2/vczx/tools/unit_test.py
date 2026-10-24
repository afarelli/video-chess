"""Testa cada sub-rotina traduzida contra o 6502, com estados reais gravados durante a busca.
Uso: unit_test.py [amostras_por_rotina]"""
import sys, os, collections, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import atari_lite as AL
from zlogic import Z80Logic
from py65.devices.mpu6502 import MPU
ROM = os.path.join(os.path.dirname(__file__), '..', 'rom', 'Vidchess.bin')
N = int(sys.argv[1]) if len(sys.argv) > 1 else 20
a = AL.Atari(ROM); a.run_frames(30)
AL.goto(a, AL.sqn('b1')); AL.button(a); AL.goto(a, AL.sqn('c3')); AL.button(a)
c = a.cpu
while c.pc != 0xF574: c.step()
samples = collections.defaultdict(list); steps = 0
while a.mem.ram[0x73] != 0x80 and steps < 3_000_000:
    if a.mem[c.pc] == 0x20:
        t = a.mem[c.pc + 1] | a.mem[c.pc + 2] << 8
        if len(samples[t]) < N or random.random() < 0.01:
            samples[t].append((bytes(a.mem.ram), c.a, c.x, c.y, c.p, c.sp))
    c.step(); steps += 1
print('rotinas chamadas na busca:', ' '.join('%04X(%d)' % (k, len(v)) for k, v in sorted(samples.items())))
z = Z80Logic()
def run6502(t, st):
    ram, A, X, Y, P, SP = st
    m = AL.AtariMem(open(ROM, 'rb').read()); m.ram[:] = ram
    cpu = MPU(memory=m); m.cpu = cpu
    cpu.a, cpu.x, cpu.y, cpu.p, cpu.sp = A, X, Y, P, SP
    ret = 0xCFFF                           # RTS volta em $D000 (espelho da ROM, nunca executado)
    m[0x100 + cpu.sp] = ret >> 8; cpu.sp = (cpu.sp - 1) & 255
    m[0x100 + cpu.sp] = ret & 255; cpu.sp = (cpu.sp - 1) & 255
    cpu.pc = t; n = 0
    while cpu.pc != 0xD000 and n < 2_000_000: cpu.step(); n += 1
    return bytes(m.ram), cpu.a, cpu.x, cpu.y, cpu.p
falhas = collections.Counter(); total = 0
for t, sts in sorted(samples.items()):
    lab = 'L_%04X' % t
    if lab not in z.s: print('sem rotulo', lab); continue
    for st in sts:
        ram, A, X, Y, P, SP = st
        for i in range(128): z.setram(0x80 + i, ram[i])
        z.m.a = A; z.m.ixl = X; z.m.iyl = Y
        f = (P & 1) | ((P & 2) << 5) | (P & 0x80)
        z.m.f = f; z.m.d = 0x40 if P & 0x40 else 0
        z.call(lab)
        r6, a6, x6, y6, p6 = run6502(t, st)
        bad = [i for i in range(0x80, 0xF8) if r6[i - 0x80] != z.ram(i)]
        regs = (a6 == z.m.a, x6 == z.m.ixl, y6 == z.m.iyl, (p6 & 1) == (z.m.f & 1))
        total += 1
        if bad or not all(regs):
            falhas[t] += 1
            if falhas[t] <= 2:
                print('%s: RAM %s  regs A%s X%s Y%s C%s' % (lab, ' '.join('%02X:%02X/%02X' % (i, r6[i - 0x80], z.ram(i)) for i in bad[:8]),
                      *['ok' if q else 'ERRO' for q in regs]))
print('testes %d, rotinas com falha: %s' % (total, ' '.join('%04X(%d)' % kv for kv in sorted(falhas.items())) or 'nenhuma'))
