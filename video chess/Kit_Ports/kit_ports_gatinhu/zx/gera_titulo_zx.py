"""Tela de apresentacao do Video Chess para o Spectrum (build/titulo.scr, 6912 bytes),
adaptada da tela do Apple II: titulo listrado, rei e dama da ROM, creditos, comandos em
"teclas" e o gato da GatinhuGames. Confere que nenhuma celula 8x8 tem duas cores de tinta.
Uso: gera_titulo_zx.py [previa.png]"""
import os, sys
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
sys.path.insert(0, H)
from fonte import glifo
rom = open(os.path.join(ROOT, 'rom', 'Vidchess.bin'), 'rb').read()
COR = {'K': 0, 'B': 1, 'R': 2, 'M': 3, 'G': 4, 'C': 5, 'Y': 6, 'W': 7}
W, Hh = 256, 192
ink = [[None] * W for _ in range(Hh)]                 # cor da tinta por pixel (None = papel)
paper = [[('B', True, False)] * 32 for _ in range(24)]    # (cor, brilho, flash): fundo azul brilhante
def px(x, y, c):
    if 0 <= x < W and 0 <= y < Hh: ink[y][x] = c
def texto(s, x, y, c, sx=1, sy=1, listra=False, gap=2, negrito=True):
    for ch in s:
        for r, row in enumerate(glifo(ch)):
            for k, on in enumerate(row):
                if not on: continue
                for dy in range(sy):
                    if listra and dy == sy - 1: continue
                    for dx in range(sx + (1 if negrito else 0)):
                        px(x + k * sx + dx, y + r * sy + dy, c)
        x += 5 * sx + (1 if negrito else 0) + gap
def larg(s, sx=1, gap=2, negrito=True): return len(s) * (5 * sx + (1 if negrito else 0) + gap) - gap
def centro(s, y, c, **kw): texto(s, (W - larg(s, kw.get('sx', 1), kw.get('gap', 2))) // 2, y, c, **kw)
def celulas(c0, r0, c1, r1, cor, brilho=True, flash=False):
    for r in range(r0, r1 + 1):
        for c in range(c0, c1 + 1): paper[r][c] = (cor, brilho, flash)
def tecla(s, col, row, cor, flash=False):
    """texto preto dentro de uma caixa colorida de 2 fileiras (como as teclas do Apple)"""
    n = (larg(s) + 7) // 8 + 1
    celulas(col, row, col + n - 1, row + 1, cor, True, flash)
    texto(s, col * 8 + (n * 8 - larg(s)) // 2, row * 8 + 3, 'K')
    return col + n
def peca(t, x, y, c, s):
    for r in range(6):
        b = rom[0xF00 + t * 8 + 5 - r] >> 1
        for k in range(7):
            if b >> (6 - k) & 1:
                for dy in range(s - 1):              # listra: a ultima linha fica no fundo
                    for dx in range(s): px(x + k * s + dx, y + r * s + dy, c)
def faixa(row):                                      # pedaco de tabuleiro (casas no azul escuro)
    for i in range(0, 32, 4): celulas(i, row, i + 1, row, 'B', False)
# ---------------- layout (fileiras de 8 px) ----------------
peca(1, 12, 9, 'W', 5)                               # rei (jogador)
peca(2, 209, 9, 'Y', 5)                              # dama (computador)
centro("VIDEO", 2, 'W', sx=4, sy=3, listra=True, gap=4)
centro("CHESS", 26, 'Y', sx=4, sy=3, listra=True, gap=4)
faixa(6)
centro("(C) 1979 ATARI", 57, 'Y', sx=2)
centro("VERSÃO ZX SPECTRUM 2026", 72, 'W')
centro("GATINHUGAMES+CLAUDE AI", 84, 'W')
faixa(12)
tecla("COMANDOS", 1, 13, 'C')
c = tecla("1", 1, 15, 'G'); texto("NÍVEL", c * 8 + 4, 15 * 8 + 3, 'W')
c = tecla("2", 10, 15, 'G'); texto("INÍCIO", c * 8 + 4, 15 * 8 + 3, 'W')
c = tecla("IJKL", 1, 17, 'G'); texto("CURSOR", c * 8 + 4, 17 * 8 + 3, 'W')
c = tecla("ESPAÇO", 1, 19, 'G'); texto("AÇÃO", c * 8 + 4, 19 * 8 + 3, 'W')
c = tecla("H", 1, 21, 'G'); texto("PAUSA", c * 8 + 4, 21 * 8 + 3, 'W')
# gato: grade 16x13 da imagem original, celulas de 6x4 px (2 linhas da grade por fileira).
# Cada fileira de caracteres precisa de uma cor so: a linha 10 (violeta) virou ciano.
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
...CCCCCCCCCCC..
....CCCCCCCCCC..
...CCCC.CCCC.CC.""".split()
CORGATO = {'G': 'G', 'Y': 'Y', 'O': 'R', 'M': 'M', 'V': 'M', 'C': 'C'}
GX, GY = 152, 120
for r, row in enumerate(GATO):
    for k, ch in enumerate(row):
        if ch != '.':
            for dy in range(4):
                for dx in range(6): px(GX + k * 6 + dx, GY + r * 4 + dy, CORGATO[ch])
celulas(7, 23, 24, 23, 'R', True, True)               # 1 fileira so: as letras nao tem acento
texto("APERTE UMA TECLA", (W - larg("APERTE UMA TECLA")) // 2, 182, 'W')
# texto da tecla piscante em branco (o FLASH troca tinta e papel)
for y in range(176, 192):
    for x in range(W):
        pass
# ---------------- conversao para o formato da tela ----------------
scr = bytearray(6912); conflitos = []
for r in range(24):
    for c in range(32):
        cores = {ink[y][x] for y in range(r * 8, r * 8 + 8) for x in range(c * 8, c * 8 + 8)} - {None}
        if len(cores) > 1: conflitos.append((r, c, cores))
        pcor, br, fl = paper[r][c]
        tinta = COR[sorted(cores)[0]] if cores else 7
        bright = br
        scr[6144 + r * 32 + c] = (0x80 if fl else 0) | (0x40 if bright else 0) | (COR[pcor] << 3) | tinta
for y in range(Hh):
    a = ((y & 0xC0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2)
    for c in range(32):
        b = 0
        for bit in range(8):
            if ink[y][c * 8 + bit] is not None: b |= 0x80 >> bit
        scr[a + c] = b
open(os.path.join(ROOT, 'build', 'titulo.scr'), 'wb').write(scr)
print('titulo.scr: 6912 bytes; celulas com duas tintas:', len(conflitos), conflitos[:5])
if len(sys.argv) > 1:
    from PIL import Image
    from run_zx import PAL, PALB
    img = Image.new('RGB', (288, 224), PAL[1]); p = img.load()
    for y in range(192):
        for x in range(256):
            at = scr[6144 + (y >> 3) * 32 + (x >> 3)]; pal = PALB if at & 0x40 else PAL
            on = scr[((y & 0xC0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2) | (x >> 3)] & (0x80 >> (x & 7))
            p[16 + x, 16 + y] = pal[at & 7] if on else pal[(at >> 3) & 7]
    img.resize((576, 448), Image.NEAREST).save(sys.argv[1])
# fileiras 22-23 (pixels e atributos) tambem dentro do programa: a ROM pode apagar a parte de
# baixo da tela depois da carga; o jogo as devolve antes de esperar a tecla
L = ['; gerado por gera_titulo_zx.py: fileiras 22-23 da tela de titulo', 'Rodape:']
for n in range(8):
    a = 0x10C0 + n * 256
    L.append('        DB ' + ','.join('$%02X' % b for b in scr[a:a + 64]))
L.append('RodapeAt:')
L.append('        DB ' + ','.join('$%02X' % b for b in scr[6144 + 22 * 32:6144 + 24 * 32]))
open(os.path.join(ROOT, 'src', 'rodape.asm'), 'w').write('\n'.join(L) + '\n')
