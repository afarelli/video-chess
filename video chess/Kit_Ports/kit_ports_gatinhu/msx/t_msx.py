"""MSX: titulo, tecla, lance pelo teclado, resposta do computador, pausa e som (log do PSG)."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run_msx import Run
OUT = sys.argv[1]
r = Run(); gif = []
for i in range(70): r.step()
r.image(2).save(OUT + '_titulo.png')
for i in range(4): r.step({'5'})
for i in range(60): r.step()
print('apos a tecla: $D3 = %02X, cursor $D4 = %02X, estado $F3 = %02X' % (r.ram(0xD3), r.ram(0xD4), r.ram(0xF3)))
r.image(2).save(OUT + '_inicio.png')
def name(i): return 'abcdefgh'[i % 8] + str(8 - i // 8)
def anda(tecla, reg):
    c = r.ram(reg)
    for _ in range(70):
        r.step({tecla})
        if r.frame % 4 == 0: gif.append(r.image(1))
        if r.ram(reg) != c: break
    for _ in range(3): r.step()
def vai(sq):
    reg = 0xDA if r.ram(0xF3) & 1 else 0xD4     # com a peca na mao, o cursor e' $DA
    for _ in range(30):
        c = r.ram(reg)
        if c == sq: return
        anda(('l' if sq % 8 > c % 8 else 'j') if sq % 8 != c % 8 else ('k' if sq > c else 'i'), reg)
def botao():
    for _ in range(40): r.step()
    for _ in range(15): r.step({' '})
    for _ in range(15): r.step()
vai(0x39); botao(); vai(0x2A); botao()        # Cb1-c3
n = 0
while r.ram(0xF3) != 0x80 and n < 3000:
    r.step(); n += 1
    if n % 20 == 0: gif.append(r.image(1))
print('computador respondeu %s-%s em %d quadros (%.1f s a 60 Hz)' % (name(r.ram(0xD9)), name(r.ram(0xDA)), n, n / 60))
for i in range(60):
    r.step()
    if i % 4 == 0: gif.append(r.image(1))
r.image(2).save(OUT + '_resposta.png')
f = r.ram(0xD3)
for i in range(4): r.step({'h'})
for i in range(40): r.step()
print('pausa: $D3 %02X -> %02X' % (f, r.ram(0xD3)))
for i in range(4): r.step({'h'})
regs = {}
for fr, reg, v in r.psglog: regs.setdefault(reg, set()).add(v)
print('PSG: registradores escritos', {k: sorted(v)[:8] for k, v in sorted(regs.items())})
gif[0].save(OUT + '.gif', save_all=True, append_images=gif[1:], duration=66, loop=0)
import pickle; pickle.dump(r.psglog, open(OUT + '_psg.pkl', 'wb'))
