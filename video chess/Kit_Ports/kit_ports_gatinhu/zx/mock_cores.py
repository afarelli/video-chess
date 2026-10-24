"""Previa de paletas: o mesmo tabuleiro com 3 combinacoes de atributos (A, B, C)."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run_zx import Run, PAL
from PIL import Image, ImageDraw
r = Run()
for _ in range(60): r.step()
def pinta(clara, escura, ink_pc, ink_eu, borda):
    mem = r.m.memory
    for sq in range(64):
        row, col = divmod(sq, 8); v = r.ram(0x80 + sq) & 15
        luz = (row + col) % 2 == 0
        pap, br = (clara if luz else escura)
        ink = ink_pc if (v & 8 == 0 or v == 8) else ink_eu
        at = (br << 6) | (pap << 3) | ink
        for dy in range(3):
            for dx in range(3): mem[0x5800 + (3*row + dy)*32 + 4 + 3*col + dx] = at
    r.border = borda
    return r.image(1)
ops = [('A: preto e azul (como no Apple)', pinta((1, 1), (0, 1), 6, 7, 0)),
       ('B: azuis do Atari (escura = fundo)', pinta((1, 1), (1, 0), 6, 7, 1)),
       ('C: como A, computador vermelho', pinta((1, 1), (0, 1), 2, 7, 0))]
W = ops[0][1].width
img = Image.new('RGB', (3 * W + 40, ops[0][1].height + 30), (60, 60, 60)); d = ImageDraw.Draw(img)
for i, (t, im) in enumerate(ops):
    img.paste(im, (10 + i * (W + 10), 25)); d.text((14 + i * (W + 10), 6), t, fill=(255, 255, 255))
img.save(sys.argv[1]); print('ok')
