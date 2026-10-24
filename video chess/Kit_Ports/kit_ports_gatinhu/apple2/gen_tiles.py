# Gera tiles das pecas p/ Apple II HGR a partir da ROM do Video Chess
import sys
rom = open(sys.argv[1], 'rb').read()
SQ_W, SQ_H, TOP, LEFT = 4, 22, 8, 4      # casa 4 bytes x 22 linhas
XCUR = [0b1000001, 0b0100010, 0b0011100, 0b0011100, 0b0100010, 0b1000001]
def shape(t):                             # 6 linhas uteis, 7 bits uteis
    if t == 8: return XCUR                # valor $08 no tabuleiro = cursor X do Atari
    if t >= 16:                           # 16-23: digitos 1-8 do nivel (fonte $FF46)
        d = t - 16
        return [0] + [rom[0xF46 + 5*d + 4 - r] >> 1 for r in range(5)]
    return [rom[0xF00 + t*8 + 5 - r] >> 1 for r in range(6)]   # topo primeiro
STRIPES = True        # listras horizontais na cor do fundo (estilo Atari)
def piece_pixels(t):                      # 14x18: cada pixel Atari = 2x3
    g = [[0]*14 for _ in range(18)]
    for r, b in enumerate(shape(t)):
        for c in range(7):
            if b >> (6 - c) & 1:
                for dy in ((0, 1) if STRIPES else (0, 1, 2)):   # 3a linha = fundo
                    g[r*3+dy][c*2] = g[r*3+dy][c*2+1] = 1
    return g
def tile(t, white, light_sq):
    """18 linhas x 2 bytes (bytes 1 e 2 da casa). Fundo como no Atari:
    casa clara = azul cheio; casa escura = preto (igual ao fundo)."""
    if t == 0 and white: t, white = 8, False   # $08: X laranja (como no Atari)
    g = piece_pixels(t) if t else [[0]*14 for _ in range(18)]
    out = []
    for y in range(18):                         # y tem a mesma paridade da linha na tela
        blue_line = light_sq
        # halo SO na horizontal: o artefato NTSC so funde pixels lado a lado
        halo = [any(g[y][x+dx] for dx in (-1, 1) if 0 <= x+dx < 14) for x in range(14)]
        row = []
        for bi in range(2):                     # byte 1 da casa e' sempre impar
            v = 0x80
            for bit in range(7):
                x = bi*7 + bit
                absx = (LEFT + 1 + bi) * 7 + bit
                if g[y][x]:
                    on = True if white else (absx % 2 == 1)     # laranja = impar
                elif halo[x] and blue_line:
                    on = False
                else:
                    on = blue_line and absx % 2 == 0            # azul = par
                v |= on << bit
            row.append(v)
        out.append(row)
    return out
lines = ["; gerado por gen_tiles.py - NAO EDITAR", "TILES:"]
# indice do tile = valor*2 + casa_azul
#   valor 0-15  = nibble baixo da casa no Atari (bits 0-2 tipo, bit 3 jogador)
#   valor 16-23 = digitos 1-8 do nivel (brancos)
for v in range(24):
    t, w = (v, 1) if v >= 16 else (v & 7, v >> 3)
    for b in (0, 1):
        data = [x for row in tile(t, w, b) for x in row]
        lines.append(f"  .byte {','.join(f'${x:02X}' for x in data)} ; valor {v} azul {b}")
def hgr(y): return 0x2000 + (y & 7)*0x400 + ((y >> 3) & 7)*0x80 + (y >> 6)*0x28
lines += ["LINE_LO: .byte " + ",".join(f"${hgr(y)&255:02X}" for y in range(192)),
          "LINE_HI: .byte " + ",".join(f"${hgr(y)>>8:02X}" for y in range(192)),
          "TILE_LO: .lobytes " + ",".join(f"TILES+{i*36}" for i in range(48)),
          "TILE_HI: .hibytes " + ",".join(f"TILES+{i*36}" for i in range(48)),
          "ROWY:    .byte " + ",".join(str(TOP + r*SQ_H) for r in range(8))]
open('tiles.inc', 'w').write("\n".join(lines) + "\n")
print("tiles: 48 x 36 bytes")
