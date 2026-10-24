"""Gera src/tiles.asm: pecas da ROM do Video Chess em blocos de 24x24 px (3x3 caracteres),
com listras horizontais como no Atari (2 linhas de peca + 1 de fundo), e a tabela de linhas da tela.
Indice do bloco = nibble baixo da casa (0-15); 16-23 = digitos 1-8 do nivel (fonte $FF46 da ROM)."""
import os
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
rom = open(os.path.join(ROOT, 'rom', 'Vidchess.bin'), 'rb').read()
XCUR = [0b1000001, 0b0100010, 0b0011100, 0b0011100, 0b0100010, 0b1000001]   # X do cursor (7 bits)
def shape(v):
    if v >= 16:                                   # digito: 5 linhas de 6 bits, de baixo para cima
        d = v - 16
        return [0] + [rom[0xF46 + 5*d + 4 - r] >> 1 for r in range(5)]
    t = v & 7
    if v == 8: return XCUR                        # $08 = cursor numa casa vazia
    if t == 0: return [0]*6
    return [rom[0xF00 + t*8 + 5 - r] >> 1 for r in range(6)]   # 7 bits uteis, topo primeiro
def tile(v):
    rows = []
    sh = shape(v)
    for y in range(24):
        r, k = divmod(y - 3, 3)                   # 3 linhas de margem em cima
        bits = 0
        if 0 <= r < 6 and k < 2:                  # k == 2: listra na cor do fundo
            b = sh[r]
            for c in range(7):
                if b >> (6 - c) & 1: bits |= 0b111 << (20 - 3*c)   # 3 px por pixel, 1 px de margem a esquerda
        rows.append([(bits >> 16) & 255, (bits >> 8) & 255, bits & 255])
    return rows
L = ['; gerado por tools/make_tiles.py - nao editar', 'Tiles:']
for v in range(24):
    L.append('        DB ' + ','.join('$%02X' % b for row in tile(v) for b in row) + '   ; %d' % v)
def scr(y): return 0x4000 | ((y & 0xC0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2)
L.append('Lines:')
for i in range(0, 192, 16): L.append('        DW ' + ','.join('$%04X' % scr(y) for y in range(i, i + 16)))
open(os.path.join(ROOT, 'src', 'tiles.asm'), 'w').write('\n'.join(L) + '\n')
print('24 blocos de 72 bytes')
