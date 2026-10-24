"""Compara a busca (F574 -> FA63) passo a passo: os dois partem do mesmo estado e param em
pontos de controle (inicio de blocos basicos); acusa o primeiro ponto em que a RAM difere."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import atari_lite as AL
from zlogic import Z80Logic
ROM = os.path.join(os.path.dirname(__file__), '..', 'rom', 'Vidchess.bin')
a = AL.Atari(ROM); a.run_frames(30)
AL.goto(a, AL.sqn('b1')); AL.button(a); AL.goto(a, AL.sqn('c3')); AL.button(a)
c = a.cpu
while c.pc != 0xF574: c.step()
z = Z80Logic()
for i in range(128): z.setram(0x80 + i, a.mem.ram[i])
z.m.a = c.a; z.m.ixl = c.x; z.m.iyl = c.y; z.m.f = (c.p & 1) | ((c.p & 2) << 5) | (c.p & 0x80); z.m.d = 0x40 if c.p & 0x40 else 0
# pontos de controle: todos os rotulos L_xxxx que existem no Z80, na faixa da busca
pts = {int(k[2:], 16): v for k, v in z.s.items() if k.startswith('L_') and len(k) == 6 and 0xF574 <= int(k[2:], 16) <= 0xFA63}
for v in pts.values(): z.m.set_breakpoint(v)
inv = {}
for k, v in pts.items(): inv.setdefault(v, set()).add(k)
m = z.m
m.sp = 0xFDF0 - 2; m.memory[m.sp] = z.sent & 255; m.memory[m.sp + 1] = z.sent >> 8
m.pc = z.s['L_F574']
n = 0; prev = None
while True:
    zp = c.pc
    if c.pc not in inv.get(m.pc, ()):
        print('ponto %d: caminhos diferentes 6502 %04X x Z80 %s (anterior %s)' % (n, c.pc, ' '.join('%04X' % q for q in inv.get(m.pc, ())), prev)); break
    bad = [i for i in range(0x80, 0xF8) if a.mem.ram[i - 0x80] != z.ram(i)]
    regs = [r for r, ok in (('A', c.a == m.a), ('X', c.x == m.ixl), ('Y', c.y == m.iyl)) if not ok]
    if bad or regs:
        print('ponto %d em %04X (anterior %s): RAM %s regs %s' % (n, zp, prev, ' '.join('%02X:%02X/%02X' % (i, a.mem.ram[i-0x80], z.ram(i)) for i in bad[:8]), regs))
        print('  A %02X/%02X X %02X/%02X Y %02X/%02X P %02X' % (c.a, m.a, c.x, m.ixl, c.y, m.iyl, c.p))
        break
    prev = '%04X' % zp; n += 1
    m.step_over_breakpoint()
    while True:
        m.ticks_to_stop = 10_000_000; m.run()
        if m.pc in inv or m.pc == z.sent: break
    if m.pc == z.sent: print('Z80 terminou a busca, ponto', n); break
    alvo = inv[m.pc]; k = 0
    while True:
        c.step(); k += 1
        if c.pc in alvo or k > 200000 or c.pc == 0xFA63: break
    if c.pc not in alvo:
        print('ponto %d: o 6502 nao chegou a %s (esta em %04X; anterior %s)' % (n, ' '.join('%04X' % q for q in alvo), c.pc, prev)); break
print('pontos conferidos:', n)
