"""Etapa 2: liga, mostra o tabuleiro, faz Cb1-c3 pelo teclado e espera a resposta."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run_zx import Run
import time
OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/e2'
r = Run(); gif = []
def run(n, keys=(), every=0):
    for i in range(n):
        r.step(keys)
        if every and r.frame % every == 0: gif.append(r.image(1).convert('P', palette=0, colors=16) if False else r.image(1))
def name(i): return 'abcdefgh'[i % 8] + str(8 - i // 8)
run(60, every=6); r.image(2).save(OUT + '_inicio.png')
print('cursor $D4 = %s, estado $F3 = %02X, nivel $EA = %d' % (name(r.ram(0xD4)), r.ram(0xF3), r.ram(0xEA)))
def anda(tecla, alvo_fn):
    for _ in range(40):
        if alvo_fn(): return True
        reg = 0xD5 if r.ram(0xF3) & 1 else 0xD4; c = r.ram(reg)
        for _ in range(60):
            r.step({tecla});
            if r.frame % 3 == 0: gif.append(r.image(1))
            if r.ram(reg) != c: break
        run(2, every=3)
    return alvo_fn()
def vai(sq):
    reg = lambda: 0xD5 if r.ram(0xF3) & 1 else 0xD4
    while r.ram(reg()) % 8 != sq % 8:
        anda('l' if sq % 8 > r.ram(reg()) % 8 else 'j', lambda: r.ram(reg()) % 8 == sq % 8)
    while r.ram(reg()) != sq:
        anda('k' if sq > r.ram(reg()) else 'i', lambda: r.ram(reg()) == sq)
def botao():
    run(40, every=3); run(20, {' '}, every=3); run(20, every=3)
t0 = time.time()
vai(0x39); botao(); vai(0x2A); botao()
print('lance do jogador feito no quadro', r.frame, 'estado', hex(r.ram(0xF3)))
n = 0
while r.ram(0xF3) != 0x80 and n < 2000: r.step(); n += 1; (gif.append(r.image(1)) if n % 25 == 0 else None)
print('computador pensou %d quadros (%.1f s a 50 Hz); lance %s-%s; bordas usadas %s' % (n, n / 50, name(r.ram(0xD9)), name(r.ram(0xDA)), sorted(set(r.borders))))
run(60, every=3)
r.image(2).save(OUT + '_resposta.png')
gif[0].save(OUT + '.gif', save_all=True, append_images=gif[1:], duration=60, loop=0)
print('tempo de emulacao %.0f s, %d quadros' % (time.time() - t0, r.frame))
