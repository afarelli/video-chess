# Cria .dsk bootavel (ordem DOS 3.3) com o binario na trilha 0
import sys
data = open(sys.argv[1], 'rb').read()
n = data[0]; assert len(data) <= n * 256 <= 16 * 256
DOS2PHYS = [0, 13, 11, 9, 7, 5, 3, 1, 14, 12, 10, 8, 6, 4, 2, 15]
disk = bytearray(35 * 16 * 256)
data += bytes(n * 256 - len(data))
for p in range(n):                         # setor FISICO p -> posicao logica no .dsk
    L = DOS2PHYS.index(p)
    disk[L*256:(L+1)*256] = data[p*256:(p+1)*256]
open(sys.argv[2], 'wb').write(disk)
print(f"{n} setores, {len(disk)} bytes")
