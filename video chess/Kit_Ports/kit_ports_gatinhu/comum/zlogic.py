"""Roda a logica traduzida (build/bench.bin) no Z80 do pacote z80, sem tela.
Z80Logic().vbl() / .over() chamam LogicVbl / LogicOver e voltam no Sentinel."""
import os, sys
sys.path.insert(0, '/home/claude/z80src')
import z80
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
def syms(p):
    s = {}
    for l in open(p):
        p2 = l.split(':', 1)
        if len(p2) == 2 and 'EQU' in p2[1]:
            s[p2[0].strip()] = int(p2[1].split('EQU')[1].split()[0].replace('0x', '').replace('$', ''), 16)
    return s
ZP = 0xFA00
class Z80Logic:
    def __init__(s, name='bench'):
        s.m = m = z80.Z80Machine()
        m.set_memory_block(0x8000, open(os.path.join(ROOT, 'build', name + '.bin'), 'rb').read())
        m.set_memory_block(0xE000, open(os.path.join(ROOT, 'rom', 'Vidchess.bin'), 'rb').read())
        s.s = syms(os.path.join(ROOT, 'build', name + '.sym'))
        s.sent = s.s['Sentinel']; m.set_breakpoint(s.sent)
        m.ix = 0xFB00; m.iy = 0xFB00; m.sp = 0xFDF0
        s.ticks = 0
    def call(s, label, limit=2_000_000_000):
        m = s.m
        m.sp = 0xFDF0 - 2
        m.memory[m.sp] = s.sent & 255; m.memory[m.sp + 1] = s.sent >> 8
        m.pc = s.s[label]; t = 0
        while True:
            m.ticks_to_stop = 1_000_000
            m.run()
            t += 1_000_000 - max(0, m.ticks_to_stop)
            if m.pc == s.sent: break
            if t > limit: raise RuntimeError('passou do limite em %s, pc=%04X' % (label, m.pc))
        s.ticks += t
        return t
    def vbl(s): return s.call('LogicVbl')
    def over(s): return s.call('LogicOver')
    def ram(s, a): return s.m.memory[ZP + a]
    def setram(s, a, v): s.m.memory[ZP + a] = v
    def inputs(s, swcha, swchb, inpt4):
        mm = s.m.memory
        mm[s.s['inSWCHA']] = swcha; mm[s.s['inSWCHB']] = swchb; mm[s.s['inINPT4']] = inpt4; mm[s.s['inINTIM']] = 0
    @property
    def x(s): return s.m.ixl
    @property
    def y(s): return s.m.iyl
