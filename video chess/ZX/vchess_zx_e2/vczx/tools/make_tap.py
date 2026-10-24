"""Monta o TAP: loader BASIC (BORDER 0: PAPER 0: INK 7: CLEAR 32767: 2 x LOAD "" CODE: RANDOMIZE USR 32768),
bloco do programa ($8000) e copia da ROM do 2600 ($E000). Uso: make_tap.py saida.tap"""
import os, sys, struct
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
def num(n):                                   # numero do BASIC: digitos + $0E + forma curta de inteiro
    return str(n).encode() + bytes([0x0E, 0, 0, n & 255, n >> 8, 0])
BORDER, PAPER, INK, CLEAR, LOAD, CODE, RAND, USR, POKE = 0xE7, 0xDA, 0xD9, 0xFD, 0xEF, 0xAF, 0xF9, 0xC0, 0xF4
def line(n, body): return struct.pack('>H', n) + struct.pack('<H', len(body) + 1) + body + b'\r'
prog = (line(10, bytes([BORDER]) + num(0) + b':' + bytes([PAPER]) + num(0) + b':' + bytes([INK]) + num(7)
             + b':' + bytes([CLEAR]) + num(32767))
        + line(20, bytes([POKE]) + num(23739) + b',' + num(111))          # esconde o "Bytes:" na carga
        + line(30, bytes([LOAD]) + b'""' + bytes([CODE]) + b':' + bytes([LOAD]) + b'""' + bytes([CODE]))
        + line(40, bytes([RAND, USR]) + num(32768)))
def block(flag, data):
    b = bytes([flag]) + data; x = 0
    for c in b: x ^= c
    b += bytes([x]); return struct.pack('<H', len(b)) + b
def header(typ, name, length, p1, p2):
    return block(0x00, bytes([typ]) + name.ljust(10)[:10].encode() + struct.pack('<HHH', length, p1, p2))
code = open(os.path.join(ROOT, 'build', 'vchess.bin'), 'rb').read()
rom = open(os.path.join(ROOT, 'rom', 'Vidchess.bin'), 'rb').read()
tap = (header(0, 'VIDEOCHESS', len(prog), 10, len(prog)) + block(0xFF, prog)
       + header(3, 'vchess', len(code), 0x8000, 32768) + block(0xFF, code)
       + header(3, 'rom2600', len(rom), 0xE000, 32768) + block(0xFF, rom))
open(sys.argv[1], 'wb').write(tap)
print('%s: %d bytes (programa %d bytes em $8000, ROM %d bytes em $E000)' % (sys.argv[1], len(tap), len(code), len(rom)))
