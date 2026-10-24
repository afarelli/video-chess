# Gera tiles das pecas p/ Apple II HGR a partir da ROM do Video Chess
import sys
rom = open(sys.argv[1], 'rb').read()
SQ_W, SQ_H, TOP, LEFT = 4, 22, 8, 4      # casa 4 bytes x 22 linhas
def shape(t):                             # 6 linhas uteis, 7 bits uteis
    return [rom[0xF00 + t*8 + 5 - r] >> 1 for r in range(6)]   # topo primeiro
def piece_pixels(t):                      # 14x18: cada pixel Atari = 2x3
    g = [[0]*14 for _ in range(18)]
    for r, b in enumerate(shape(t)):
        for c in range(7):
            if b >> (6 - c) & 1:
                for dy in range(3):
                    g[r*3+dy][c*2] = g[r*3+dy][c*2+1] = 1
    return g
def tile(t, white, blue_sq):
    """retorna 18 linhas x 2 bytes (bytes 1 e 2 da casa: colunas pares/impares)"""
    g = piece_pixels(t) if t else [[0]*14 for _ in range(18)]
    halo = [[any(g[y+dy][x+dx] for dy in (-1,0,1) for dx in (-1,0,1)
             if 0 <= y+dy < 18 and 0 <= x+dx < 14) for x in range(14)] for y in range(18)]
    out = []
    for y in range(18):
        row = []
        for bi in range(2):                 # byte 1 da casa e' sempre impar (LEFT+4c+1)
            v = 0x80
            for bit in range(7):
                x = bi*7 + bit
                absx = (LEFT + 1 + bi) * 7 + bit
                if g[y][x]:
                    on = True if white else (absx % 2 == 1)     # laranja = impar
                elif halo[y][x] and blue_sq:
                    on = False
                else:
                    on = blue_sq and absx % 2 == 0              # azul = par
                v |= on << bit
            row.append(v)
        out.append(row)
    return out
lines = ["; gerado por gen_tiles.py - NAO EDITAR", "TILES:"]
# indice = (tipo*2 + branca)*2 + casa_azul ; tipo 0..6
for t in range(7):
    for w in (0, 1):
        for b in (0, 1):
            data = [v for row in tile(t, w, b) for v in row]
            lines.append(f"  .byte {','.join(f'${v:02X}' for v in data)} ; t{t} w{w} b{b}")
# tabela de enderecos das linhas HGR
def hgr(y): return 0x2000 + (y & 7)*0x400 + ((y >> 3) & 7)*0x80 + (y >> 6)*0x28
lines.append("LINE_LO: .byte " + ",".join(f"${hgr(y)&255:02X}" for y in range(192)))
lines.append("LINE_HI: .byte " + ",".join(f"${hgr(y)>>8:02X}" for y in range(192)))
open('tiles.inc', 'w').write("\n".join(lines) + "\n")
print("tiles:", 7*2*2, "x 36 bytes")
extra = ["TILE_LO: .lobytes " + ",".join(f"TILES+{i*36}" for i in range(28)),
         "TILE_HI: .hibytes " + ",".join(f"TILES+{i*36}" for i in range(28)),
         "ROWY:    .byte " + ",".join(str(TOP + r*SQ_H) for r in range(8))]
open('tiles.inc', 'a').write("\n".join(extra) + "\n")
