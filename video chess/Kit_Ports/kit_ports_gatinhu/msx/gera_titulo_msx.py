"""Tela de apresentacao do Video Chess para MSX1 (SCREEN 2): build/msx/titulo_pat.bin e
titulo_col.bin (6144 bytes cada, ja na ordem da VRAM). Mesmo layout do Spectrum, com a
regra do TMS9918: no maximo 2 cores em cada segmento de 8x1 pixels.
Uso: gera_titulo_msx.py [previa.png]"""
import os, sys
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
sys.path.insert(0, H)
from fonte import glifo
rom = open(os.path.join(ROOT, 'rom', 'Vidchess.bin'), 'rb').read()
# paleta do TMS9918
TMS = [(0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120), (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
       (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128), (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255)]
FUNDO = 4                                          # azul escuro (o fundo do Atari)
W, Hh = 256, 192
cv = [[FUNDO] * W for _ in range(Hh)]
def px(x, y, c):
    if 0 <= x < W and 0 <= y < Hh: cv[y][x] = c
def rect(x, y, w, h, c):
    for yy in range(y, y + h):
        for xx in range(x, x + w): px(xx, yy, c)
def texto(s, x, y, c, sx=1, sy=1, listra=False, gap=2):
    for ch in s:
        for r, row in enumerate(glifo(ch)):
            for k, on in enumerate(row):
                if not on: continue
                for dy in range(sy):
                    if listra and dy == sy - 1: continue
                    for dx in range(sx + 1): px(x + k * sx + dx, y + r * sy + dy, c)   # negrito
        x += 5 * sx + 1 + gap
def larg(s, sx=1, gap=2): return len(s) * (5 * sx + 1 + gap) - gap
def centro(s, y, c, sx=1, sy=1, listra=False, gap=2): texto(s, (W - larg(s, sx, gap)) // 2, y, c, sx, sy, listra, gap)
def tecla(s, col, row, cor):
    n = (larg(s) + 7) // 8 + 1
    rect(col * 8, row * 8, n * 8, 16, cor)
    texto(s, col * 8 + (n * 8 - larg(s)) // 2, row * 8 + 3, 1)
    return col + n
def peca(t, x, y, c, s):
    for r in range(6):
        b = rom[0xF00 + t * 8 + 5 - r] >> 1
        for k in range(7):
            if b >> (6 - k) & 1: rect(x + k * s, y + r * s, s, s - 1, c)    # listra
def faixa(row):
    for i in range(0, 32, 4): rect(i * 8, row * 8, 16, 8, 5)
peca(1, 12, 9, 15, 5)                              # rei (jogador, branco)
peca(2, 209, 9, 11, 5)                             # dama (computador, amarelo)
centro("VIDEO", -4, 15, sx=4, sy=3, listra=True, gap=4)
centro("CHESS", 20, 11, sx=4, sy=3, listra=True, gap=4)
faixa(6)
centro("(C) 1979 ATARI", 57, 11, sx=2)
centro("VERSÃO MSX 2026", 72, 15)
centro("GATINHUGAMES+CLAUDE AI", 84, 15)
faixa(12)
tecla("COMANDOS", 1, 13, 7)
c = tecla("1", 1, 15, 3); texto("NÍVEL", c * 8 + 4, 15 * 8 + 3, 15)
c = tecla("2", 10, 15, 3); texto("INÍCIO", c * 8 + 4, 15 * 8 + 3, 15)
c = tecla("IJKL", 1, 17, 3); texto("CURSOR", c * 8 + 4, 17 * 8 + 3, 15)
c = tecla("ESPAÇO", 1, 19, 3); texto("AÇÃO", c * 8 + 4, 19 * 8 + 3, 15)
c = tecla("H", 1, 21, 3); texto("PAUSA", c * 8 + 4, 21 * 8 + 3, 15)
# gato: a grade original de 16x13, celulas de 6x4 px; no TMS cada linha pode ter sua cor
GATO = """.......GG...G...
.......GGGGGG...
.....YYY.YYY.Y..
....YYYYYYYYYYY.
.....OOOOOOOOOO.
......OOOOOOOO..
.......MMMMM....
..MM..MMMMMMM...
MMMMMMMMMMMMMM..
VV.VVVVVVVVVVV..
...VVVVVVVVVVV..
....BBBBBBBBBB..
...BBBB.BBBB.BB.""".split()
CORGATO = {'G': 3, 'Y': 11, 'O': 9, 'M': 13, 'V': 5, 'B': 7}
for r, row in enumerate(GATO):
    for k, ch in enumerate(row):
        if ch != '.': rect(152 + k * 6, 120 + r * 4, 6, 4, CORGATO[ch])   # x de 152 a 242, dentro da tela
rect(7 * 8, 23 * 8, 18 * 8, 8, 8)                  # APERTE UMA TECLA: caixa vermelha (pisca no programa)
texto("APERTE UMA TECLA", (W - larg("APERTE UMA TECLA")) // 2, 182, 15)
# ---------------- conversao: padroes e cores por segmento 8x1 ----------------
pat = bytearray(6144); col = bytearray(6144); conflitos = []
for y in range(Hh):
    for cx in range(32):
        seg = cv[y][cx * 8:cx * 8 + 8]
        cores = sorted(set(seg), key=lambda c: -seg.count(c))
        if len(cores) > 2: conflitos.append((cx, y, cores))
        bg = FUNDO if FUNDO in cores else cores[0]
        fg = ([c for c in cores if c != bg] + [bg])[0]
        b = 0
        for i, c in enumerate(seg):
            if c == fg and fg != bg: b |= 0x80 >> i
        a = (y >> 3) * 256 + cx * 8 + (y & 7)          # tabela sequencial do SCREEN 2
        pat[a] = b; col[a] = (fg << 4) | bg
os.makedirs(os.path.join(ROOT, 'build', 'msx'), exist_ok=True)
open(os.path.join(ROOT, 'build', 'msx', 'titulo_pat.bin'), 'wb').write(pat)
open(os.path.join(ROOT, 'build', 'msx', 'titulo_col.bin'), 'wb').write(col)
print('titulo MSX: segmentos com mais de 2 cores:', len(conflitos), conflitos[:4])
if len(sys.argv) > 1:
    from PIL import Image
    img = Image.new('RGB', (W + 32, Hh + 32), TMS[FUNDO]); p = img.load()
    for y in range(Hh):
        for x in range(W):
            a = (y >> 3) * 256 + (x >> 3) * 8 + (y & 7)
            on = pat[a] & (0x80 >> (x & 7)); c = col[a]
            p[16 + x, 16 + y] = TMS[(c >> 4) if on else (c & 15)]
    img.resize((img.width * 2, img.height * 2), Image.NEAREST).save(sys.argv[1])
