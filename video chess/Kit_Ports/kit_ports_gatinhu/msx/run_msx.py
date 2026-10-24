"""Emulador de testes do cartucho MSX1 (z80 + mini-BIOS de testes + modelo simples do TMS9918
e do PSG). Sem tempos exatos do VDP: serve para logica, desenho e som, nao para timing fino.
Uso em Python: r = Run(); r.step(keys); r.image(); r.ram(0xF3)"""
import os, sys
sys.path.insert(0, '/home/claude/z80src')
import z80
from PIL import Image
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
TMS = [(0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120), (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
       (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128), (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255)]
KEYS = {}
for i, k in enumerate('01234567'): KEYS[k] = (0, i)
KEYS.update({'8': (1, 0), '9': (1, 1), 'a': (2, 6), 'b': (2, 7)})
for i, k in enumerate('cdefghij'): KEYS[k] = (3, i)
for i, k in enumerate('klmnopqr'): KEYS[k] = (4, i)
for i, k in enumerate('stuvwxyz'): KEYS[k] = (5, i)
KEYS.update({' ': (8, 0), 'LEFT': (8, 4), 'UP': (8, 5), 'DOWN': (8, 6), 'RIGHT': (8, 7)})
TICKS = 59659                                     # 3.579.545 Hz / 60
class Run:
    def __init__(s, rom='vchess.rom'):
        s.m = m = z80.Z80Machine()
        m.set_memory_block(0, open(os.path.join(ROOT, 'build', 'msx', 'minibios.bin'), 'rb').read())
        cart = open(os.path.join(ROOT, 'build', 'msx', rom), 'rb').read()
        m.set_memory_block(0x4000, cart)
        for a in range(0xFD9F, 0xFDA4): m.memory[a] = 0xC9
        m.memory[0xF3E0] = 0xE0                     # RG1SAV, como a BIOS deixaria no SCREEN 2
        m.pc = cart[2] | cart[3] << 8; m.sp = 0xF380; m.int_mode = 1
        s.vram = bytearray(16384); s.reg = [0] * 8; s.latch = None; s.addr = 0
        s.psg = [0] * 16; s.psgsel = 0; s.psglog = []
        s.row = 0; s.keys = set(); s.buf = 0; s.stick = 0; s.trig = 0; s.frame = 0
        m.set_input_callback(s.inp); m.set_output_callback(s.out)
    def inp(s, port):
        p = port & 0xFF
        if p == 0x99: s.latch = None; return 0x80
        if p == 0x98: v = s.vram[s.addr]; s.addr = (s.addr + 1) & 0x3FFF; return v
        if p == 0xA9:
            v = 0xFF
            for k in s.keys:
                r, b = KEYS[k]
                if r == s.row: v &= ~(1 << b)
            return v
        if p == 0xFE: return s.buf
        if p == 0xFD: return s.stick
        if p == 0xFC: return s.trig
        return 0xFF
    def out(s, port, v):
        p = port & 0xFF
        if p == 0x99:
            if s.latch is None: s.latch = v
            else:
                if v & 0x80: s.reg[v & 7] = s.latch
                else: s.addr = ((v & 0x3F) << 8) | s.latch
                s.latch = None
        elif p == 0x98: s.vram[s.addr] = v; s.addr = (s.addr + 1) & 0x3FFF; s.latch = None
        elif p == 0xA0: s.psgsel = v & 15
        elif p == 0xA1: s.psg[s.psgsel] = v; s.psglog.append((s.frame, s.psgsel, v))
        elif p == 0xAA: s.row = v & 15
        elif p == 0xFE:
            if v == 0: s.buf = 0
            elif s.keys: s.buf = 1
    def step(s, keys=(), stick=0, trig=0):
        s.keys = set(keys); s.stick = stick; s.trig = trig; m = s.m
        if s.keys: s.buf = 1                      # a BIOS poria a tecla no buffer
        m.ticks_to_stop = TICKS
        while m.ticks_to_stop > 0: m.run()
        for _ in range(8):
            if m.iff1: m.on_handle_active_int(); break
            m.ticks_to_stop = 4
            while m.ticks_to_stop > 0: m.run()
        s.frame += 1
    def ram(s, a): return s.m.memory[0xE000 + a]
    def image(s, scale=2):
        img = Image.new('RGB', (256 + 32, 192 + 32), TMS[s.reg[7] & 15]); px = img.load(); v = s.vram
        if not s.reg[1] & 0x40:                       # imagem desligada: so a cor de fundo
            return img.resize((img.width * scale, img.height * scale), Image.NEAREST)
        for y in range(192):
            for cx in range(32):
                n = v[0x1800 + (y >> 3) * 32 + cx] + (y >> 6) * 256
                pb = v[n * 8 + (y & 7)]; cb = v[0x2000 + n * 8 + (y & 7)]
                for b in range(8):
                    c = (cb >> 4) if pb & (0x80 >> b) else (cb & 15)
                    px[16 + cx * 8 + b, 16 + y] = TMS[c] if c else TMS[s.reg[7] & 15]
        return img.resize((img.width * scale, img.height * scale), Image.NEAREST)
