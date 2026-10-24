"""Renderiza o log de registradores do PSG (AY-3-8910) gravado pelo run_msx em WAV.
O PSG e' deterministico: isto e' o que o jogo toca. Uso: psg_wav.py log.pkl saida.wav [hz]"""
import sys, pickle, wave, math
log = pickle.load(open(sys.argv[1], 'rb')); out = sys.argv[2]; HZ = float(sys.argv[3]) if len(sys.argv) > 3 else 60
RATE = 44100; CLK = 1789772.5 / 16
VOL = [0] + [10 ** ((v - 15) * 1.5 / 10) for v in range(1, 16)]
nfr = max(f for f, _, _ in log) + 30
by = {}
for f, r, v in log: by.setdefault(f, []).append((r, v))
reg = [0] * 16; reg[7] = 0xBF
ph = [0.0, 0.0, 0.0]; st = [0, 0, 0]; nph = 0.0; lfsr = 1; nout = 0
buf = bytearray(); spf = RATE / HZ; t = 0.0
for f in range(nfr):
    for r, v in by.get(f, []): reg[r] = v
    n = int(round((f + 1) * spf)) - int(round(f * spf))
    for _ in range(n):
        s = 0.0
        np_ = max(1, reg[6] & 31); nph += CLK / np_ / RATE
        while nph >= 1: nph -= 1; bit = (lfsr ^ (lfsr >> 3)) & 1; lfsr = (lfsr >> 1) | (bit << 16); nout = lfsr & 1
        for c in range(3):
            tp = max(1, reg[c * 2] | (reg[c * 2 + 1] & 15) << 8)
            ph[c] += CLK / tp / RATE * 2
            while ph[c] >= 1: ph[c] -= 1; st[c] ^= 1
            ton = (reg[7] >> c) & 1; non = (reg[7] >> (c + 3)) & 1
            o = (st[c] | ton) & (nout | non)
            s += o * VOL[reg[8 + c] & 15]
        buf.append(int(128 + 40 * s))
w = wave.open(out, 'wb'); w.setnchannels(1); w.setsampwidth(1); w.setframerate(RATE); w.writeframes(bytes(buf)); w.close()
print('%s: %.1f s' % (out, len(buf) / RATE))
