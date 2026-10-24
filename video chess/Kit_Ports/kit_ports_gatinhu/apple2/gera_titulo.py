# Gera a tela de apresentacao em formato HGR (8 KB) + a faixa que pisca
# uso: python3 gera_titulo.py Vidchess.bin
import sys
from fonte import glifo
rom = open(sys.argv[1], 'rb').read()
W, H = 280, 192
cv = [[0]*W for _ in range(H)]          # 0 preto, 'W','G','V','O','B'
def px(x, y, c):
    if 0 <= x < W and 0 <= y < H:
        if c == 'Y': c = 'G' if y % 2 == 0 else 'O'   # amarelo = verde/laranja alternados
        if c == 'M': c = 'O' if y % 2 == 0 else 'V'   # magenta = laranja/violeta alternados
        cv[y][x] = c
def rect(x, y, w, h, c):
    for yy in range(y, y+h):
        for xx in range(x, x+w): px(xx, yy, c)
def texto(s, x, y, c, sx=2, sy=1, listra=False, gap=2):
    """listra: deixa a ultima linha de cada pixel na cor do fundo (estilo Atari)"""
    for ch in s:
        g = glifo(ch)
        for r, row in enumerate(g):
            for k, on in enumerate(row):
                if on:
                    for dy in range(sy):
                        if listra and dy == sy - 1: continue
                        for dx in range(sx): px(x + k*sx + dx, y + r*sy + dy, c)
        x += 5*sx + gap
def tecla(s, x, y, c):
    """texto preto dentro de uma caixa colorida: cor solida sem franjas"""
    rect(x - 4, y + 1, larg(s) + 8, 9, c)
    texto(s, x, y, 0)
def larg(s, sx=2, gap=2): return len(s)*(5*sx + gap) - gap
def centro(s, y, c, sx=2, sy=1, listra=False, gap=2):
    texto(s, (W - larg(s, sx, gap)) // 2, y, c, sx, sy, listra, gap)
def peca(t, x, y, c, s):
    for r in range(6):
        b = rom[0xF00 + t*8 + 5 - r] >> 1
        for k in range(7):
            if b >> (6 - k) & 1:
                for dy in range(s):
                    if dy >= s - 2: continue                # listra de 2 linhas
                    for dx in range(s): px(x + k*s + dx, y + r*s + dy, c)
def faixa(y):                                               # "pedaco de tabuleiro"
    for i in range(18):
        if i % 2 == 0: rect(14 + i*14, y, 14, 4, 'B')
# ---------------- layout ----------------
# Texto pequeno com pixels de 2 de largura: traco de 1 pixel no HGR vira
# franja colorida; com 2 pixels o branco fica branco de verdade.
peca(1, 20, 14, 'W', 6)          # rei (branco = jogador)
peca(2, 218, 14, 'O', 6)         # dama (laranja = computador)
centro("VIDEO", 6, 'W', 4, 3, True, 4)     # titulo: fonte 5x7 ampliada, listrada
centro("CHESS", 34, 'O', 4, 3, True, 4)
faixa(60)
centro("(C) 1979 ATARI", 66, 'O', 2, 2)
centro("VERSÃO APPLE II 2026", 88, 'W')
centro("GATINHUGAMES+CLAUDE AI", 99, 'W')
faixa(112)
tecla("COMANDOS", 18, 117, 'B')
for i, (k, d) in enumerate([("1", "NÍVEL"), ("2", "INÍCIO"), ("IJKL", "CURSOR"), ("ESPAÇO", "AÇÃO")]):
    y = 131 + i*12
    tecla(k, 18, y, 'G')
    texto(d, 96, y, 'W')
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
GX, GY, CW, CH = 175, 127, 6, 4        # celula 6x4: "emagrece" o gato (era 28x16)
for r, row in enumerate(GATO):
    for k, c in enumerate(row):
        if c != '.': rect(GX + k*CW, GY + r*CH, CW, CH, c)
BLINK_Y = 180
pisca = [row[:] for row in cv]          # copia sem o "APERTE UMA TECLA"
tecla("APERTE UMA TECLA", (W - larg("APERTE UMA TECLA")) // 2, BLINK_Y, 'O')
# ---------------- codificacao HGR ----------------
def linha_bytes(row):
    out = []
    for b in range(40):
        cs = [row[b*7 + i] for i in range(7)]
        pal = 1 if any(c in ('O', 'B') for c in cs) else 0
        v = pal << 7
        for i, c in enumerate(cs):
            x = b*7 + i
            on = c == 'W' or (c in ('V', 'B') and x % 2 == 0) or (c in ('G', 'O') and x % 2 == 1)
            v |= on << i
        out.append(v)
    return out
def hgr(y): return (y & 7)*0x400 + ((y >> 3) & 7)*0x80 + (y >> 6)*0x28
tela = bytearray(8192)
for y in range(H): tela[hgr(y):hgr(y)+40] = bytes(linha_bytes(cv[y]))
open('titulo.hgr', 'wb').write(tela)
bl = []
for y in range(BLINK_Y + 1, BLINK_Y + 11): bl += linha_bytes(cv[y])
open('pisca.inc', 'w').write("; gerado por gera_titulo.py: linhas do APERTE UMA TECLA\nBLINK_Y = %d\nBLINKDATA:\n" % (BLINK_Y + 1) +
    "\n".join("  .byte " + ",".join("$%02X" % v for v in bl[i:i+40]) for i in range(0, 400, 40)) + "\n")
print("titulo.hgr: 8192 bytes; pisca.inc: 400 bytes")
