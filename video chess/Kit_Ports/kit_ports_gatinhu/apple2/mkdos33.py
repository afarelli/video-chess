# Cria um disco DOS 3.3 (.dsk, dados - nao bootavel) com um arquivo binario (tipo B)
# uso: mkdos33.py arquivo.bin NOME ender_hex saida.dsk
import sys
data, nome, ender, saida = open(sys.argv[1], 'rb').read(), sys.argv[2], int(sys.argv[3], 16), sys.argv[4]
disk = bytearray(35 * 16 * 256)
def sec(t, s): return (t * 16 + s) * 256          # .dsk ja esta na ordem logica do DOS
payload = bytes([ender & 255, ender >> 8, len(data) & 255, len(data) >> 8]) + data
nsec = (len(payload) + 255) // 256
livres = [(t, s) for t in range(18, 35) for s in range(15, -1, -1)]   # aloca da trilha 18 em diante
ts_list, dados = livres[0], livres[1:1 + nsec]
usados = {ts_list, *dados}
for i, (t, s) in enumerate(dados):
    chunk = payload[i*256:(i+1)*256]; disk[sec(t, s):sec(t, s) + len(chunk)] = chunk
o = sec(*ts_list)                                   # lista trilha/setor do arquivo
for i, (t, s) in enumerate(dados): disk[o + 0x0C + 2*i] = t; disk[o + 0x0D + 2*i] = s
v = sec(17, 0)                                      # VTOC
disk[v+1], disk[v+2], disk[v+3], disk[v+6], disk[v+0x27] = 17, 15, 3, 254, 122
disk[v+0x30], disk[v+0x31], disk[v+0x34], disk[v+0x35], disk[v+0x36], disk[v+0x37] = 18, 1, 35, 16, 0, 1
for t in range(35):
    if t in (0, 1, 2, 17): continue                 # DOS e catalogo: ocupados
    bits = 0
    for s in range(16):
        if (t, s) not in usados: bits |= 1 << s
    disk[v + 0x38 + 4*t] = bits >> 8; disk[v + 0x39 + 4*t] = bits & 255
for s in range(15, 0, -1):                          # catalogo: T17 S15 -> S1
    c = sec(17, s)
    if s > 1: disk[c+1], disk[c+2] = 17, s - 1
e = sec(17, 15) + 0x0B                              # 1a entrada
disk[e], disk[e+1], disk[e+2] = ts_list[0], ts_list[1], 0x04
nm = nome.upper().ljust(30)[:30]
for i, ch in enumerate(nm): disk[e + 3 + i] = ord(ch) | 0x80
disk[e+33], disk[e+34] = (nsec + 1) & 255, (nsec + 1) >> 8
open(saida, 'wb').write(disk)
print(f"{nome}: {len(data)} bytes em ${ender:04X}, {nsec+1} setores")
