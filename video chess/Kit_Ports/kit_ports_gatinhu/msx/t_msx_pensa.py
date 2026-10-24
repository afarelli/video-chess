"""MSX: confere o pisca da tela inteira enquanto o computador pensa e a volta do tabuleiro."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run_msx import Run, TMS
OUT = sys.argv[1]
r = Run(); gif = []
for i in range(70): r.step()
for i in range(4): r.step({'5'})
for i in range(60): r.step()
def anda(tecla, reg):
    c = r.ram(reg)
    for _ in range(70):
        r.step({tecla})
        if r.ram(reg) != c: break
    for _ in range(3): r.step()
def vai(sq):
    reg = 0xDA if r.ram(0xF3) & 1 else 0xD4
    for _ in range(30):
        c = r.ram(reg)
        if c == sq: return
        anda(('l' if sq % 8 > c % 8 else 'j') if sq % 8 != c % 8 else ('k' if sq > c else 'i'), reg)
def botao():
    for _ in range(40): r.step()
    for _ in range(15): r.step({' '})
    for _ in range(15): r.step()
vai(0x34); botao(); vai(0x24); botao()
cores = []; apagada = 0; n = 0
while r.ram(0xF3) != 0x80 and n < 3000:
    r.step(); n += 1
    if not r.reg[1] & 0x40: apagada += 1; cores.append(r.reg[7] & 15)
    if n % 3 == 0: gif.append(r.image(1))
for i in range(40):
    r.step()
    if i % 3 == 0: gif.append(r.image(1))
print('quadros pensando com a tela inteira colorida: %d; cores usadas %s' % (apagada, sorted(set(cores))))
print('depois: imagem ligada %s, fundo %d' % (bool(r.reg[1] & 0x40), r.reg[7] & 15))
gif[0].save(OUT + '.gif', save_all=True, append_images=gif[1:], duration=50, loop=0)
r.image(2).save(OUT + '_depois.png')
