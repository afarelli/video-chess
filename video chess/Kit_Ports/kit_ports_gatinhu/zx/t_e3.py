"""Etapa 3: carga simulada do TAP, titulo, tecla, um lance; grava PNGs e o som do beeper (WAV)."""
import sys, os, wave; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import run_zx
OUT = sys.argv[2]
r = run_zx.from_snapshot(sys.argv[1])
# alto-falante: guarda (tick, nivel) a cada OUT na porta $FE
spk = []; t = [0]
def out(port, v):
    if port & 0xFF == 0xFE:
        r.border = v & 7; spk.append((r.frame * 69888 + (69888 - r.m.ticks_to_stop), (v >> 4) & 1))
r.m.set_output_callback(out)
scr0 = None
for i in range(50): r.step()
r.image(2).save(OUT + '_titulo.png')
for i in range(5): r.step({'5'})                 # aperta uma tecla
for i in range(60): r.step()
r.image(2).save(OUT + '_jogo.png')
print('apos a tecla: $D3 = %02X (semente), cursor $D4 = %02X' % (r.ram(0xD3), r.ram(0xD4)))
def name(i): return 'abcdefgh'[i % 8] + str(8 - i // 8)
def anda(tecla, reg):
    c = r.ram(reg)
    for _ in range(60):
        r.step({tecla})
        if r.ram(reg) != c: break
    for _ in range(3): r.step()
def vai(sq):
    reg = 0xD5 if r.ram(0xF3) & 1 else 0xD4
    for _ in range(30):
        c = r.ram(reg)
        if c == sq: return
        anda(('l' if sq % 8 > c % 8 else 'j') if sq % 8 != c % 8 else ('k' if sq > c else 'i'), reg)
def botao():
    for _ in range(40): r.step()
    for _ in range(15): r.step({' '})
    for _ in range(15): r.step()
vai(0x34); botao()                          # e2
vai(0x24); botao()                          # e4
n = 0
while r.ram(0xF3) != 0x80 and n < 2000: r.step(); n += 1
print('computador respondeu %s-%s em %d quadros; bordas %s' % (name(r.ram(0xD9)), name(r.ram(0xDA)), n, sorted(set(r.borders))))
vai(0x33); botao(); vai(0x3B); botao()      # lance ilegal: peao d2 para d1 (buzina)
for i in range(60): r.step()
r.image(2).save(OUT + '_fim.png')
# H: pausa
f = r.ram(0xD3)
for i in range(4): r.step({'h'})
for i in range(50): r.step()
print('pausa: $D3 antes %02X depois %02X (igual = parado)' % (f, r.ram(0xD3)))
for i in range(4): r.step({'h'})
for i in range(10): r.step()
# WAV do beeper
RATE = 22050; T = 3_500_000
fim = r.frame * 69888; n = int(fim / T * RATE); buf = bytearray(n); lvl = 0; k = 0
spk.sort()
for i in range(n):
    tt = i / RATE * T
    while k < len(spk) and spk[k][0] <= tt: lvl = spk[k][1]; k += 1
    buf[i] = 160 if lvl else 96
w = wave.open(OUT + '_som.wav', 'wb'); w.setnchannels(1); w.setsampwidth(1); w.setframerate(RATE); w.writeframes(bytes(buf)); w.close()
print('trocas do alto-falante:', sum(1 for i in range(1, len(spk)) if spk[i][1] != spk[i - 1][1]), 'em', r.frame, 'quadros')
