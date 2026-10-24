"""Emulador de testes do port (z80 + ROM do 48K): roda o vchess.bin com teclas roteirizadas,
grava PNGs e GIF da tela. Sem contencao e sem feixe exato (veja a skill, secao 6).
Uso em Python: r = Run(); r.step(keys); r.image(); r.ram(0xF3)"""
import os, sys
sys.path.insert(0, '/home/claude/z80src'); sys.path.insert(0, '/home/claude/skoolkit')
import z80
from PIL import Image
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
ROWS = ['^zxcv', 'asdfg', 'qwert', '12345', '09876', 'poiuy', '\nlkjh', ' $mnb']   # ^ = CAPS, $ = SYM
KEYPOS = {k: (r, b) for r, row in enumerate(ROWS) for b, k in enumerate(row)}
PAL = [(0, 0, 0), (0, 0, 205), (205, 0, 0), (205, 0, 205), (0, 205, 0), (0, 205, 205), (205, 205, 0), (205, 205, 205)]
PALB = [(0, 0, 0), (0, 0, 255), (255, 0, 0), (255, 0, 255), (0, 255, 0), (0, 255, 255), (255, 255, 0), (255, 255, 255)]
class Run:
    def __init__(s, name='vchess'):
        s.m = m = z80.Z80Machine(); s.keys = set(); s.border = 0
        m.set_memory_block(0, open('/home/claude/skoolkit/skoolkit/resources/48.rom', 'rb').read())
        m.set_memory_block(0x8000, open(os.path.join(ROOT, 'build', name + '.bin'), 'rb').read())
        m.set_memory_block(0xE000, open(os.path.join(ROOT, 'rom', 'Vidchess.bin'), 'rb').read())
        m.pc = 0x8000; s.frame = 0; s.borders = []
        m.set_input_callback(s.inp); m.set_output_callback(s.out)
    def inp(s, port):
        if port & 0xFF == 0xFE:
            hi = port >> 8; v = 0x1F
            for k in s.keys:
                r, b = KEYPOS[k]
                if not hi & (1 << r): v &= ~(1 << b)
            return 0xE0 | v
        return 0xFF
    def out(s, port, v):
        if port & 0xFF == 0xFE: s.border = v & 7
    def step(s, keys=()):
        s.keys = set(keys); m = s.m
        m.ticks_to_stop = 69888
        while m.ticks_to_stop > 0: m.run()
        for _ in range(8):                       # o INT dura 32 T: tenta de novo apos EI/prefixo
            if m.iff1: m.on_handle_active_int(); break
            m.ticks_to_stop = 4
            while m.ticks_to_stop > 0: m.run()
        s.frame += 1; s.borders.append(s.border)
    def ram(s, a): return s.m.memory[0xFA00 + a]
    def image(s, scale=2):
        mem = s.m.memory
        img = Image.new('RGB', (256 + 32, 192 + 32), PAL[s.border]); px = img.load()
        for y in range(192):
            for cx in range(32):
                b = mem[0x4000 | ((y & 0xC0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2) | cx]
                at = mem[0x5800 + (y >> 3) * 32 + cx]
                pal = PALB if at & 0x40 else PAL
                for bit in range(8):
                    px[16 + cx * 8 + bit, 16 + y] = pal[at & 7] if b & (0x80 >> bit) else pal[(at >> 3) & 7]
        return img.resize((img.width * scale, img.height * scale), Image.NEAREST)
