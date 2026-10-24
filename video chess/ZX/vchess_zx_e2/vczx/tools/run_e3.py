"""Roda o kk_e3 no emulador de testes (z80, ROM do 48K) com teclas roteirizadas; grava PNGs,
GIF e um registro das variáveis da Kelly por quadro. A fileira 3 com cor por linha é desenhada
com os valores das trocas (o emulador não tem o feixe exato).
Uso: run_e3.py roteiro.json saida   (roteiro: {"frames": n, "events": [{"from","to","keys"}],
     "snap": [...], "gif": [de, até, passo], "log": true})"""
import os, sys, json, z80, skoolkit
from PIL import Image
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
sys.path.insert(0, '/home/claude/kit/enduro/tools')
from run_game import PAL, PALB, ROWS
KEYPOS = {k: (r, b) for r, row in enumerate(ROWS) for b, k in enumerate(row)}
ROW3 = {24: 0x4F, 25: 0x1F, 26: 0x1F, 27: 0x1F, 28: 0x5F, 29: 0x5F, 30: 0x17, 31: 0x17}
def syms(p):
    s = {}
    for l in open(p):
        if ':' in l and 'EQU' in l:
            n, r = l.split(':', 1); s[n.strip()] = int(r.split('EQU')[1].split()[0].replace('0x', ''), 16)
    return s
class Run:
    def __init__(s, name='kk_e3'):
        s.m = z80.Z80Machine(); s.keys = set()
        s.m.set_memory_block(0, open(os.path.join(os.path.dirname(skoolkit.__file__), 'resources', '48.rom'), 'rb').read())
        s.m.set_memory_block(0x8000, open(os.path.join(ROOT, 'build', name + '.bin'), 'rb').read())
        s.m.set_memory_block(0xE000, open(os.path.join(ROOT, 'build', name + '_rom.bin'), 'rb').read())
        dp = os.path.join(ROOT, 'build', name + '_data.bin')
        if os.path.exists(dp): s.m.set_memory_block(0x6000, open(dp, 'rb').read())
        s.m.pc = 0x8000; s.s = syms(os.path.join(ROOT, 'build', name + '.sym'))
        if 'autoStart' in s.s and not os.environ.get('MENU'): s.m.memory[s.s['autoStart']] = 1   # etapa 7: testes sem menu
        s.m.set_input_callback(s.inp); s.m.set_output_callback(lambda p, v: None)
        s.late = 0; s.frame = 0
    def inp(s, port):
        if port & 0xFF == 0xFE:
            hi = port >> 8; v = 0x1F
            for k in s.keys:
                r, b = KEYPOS[k]
                if not hi & (1 << r): v &= ~(1 << b)
            return 0xE0 | v
        return 0xFF
    def step(s, keys=()):
        s.keys = set(keys); m = s.m
        m.ticks_to_stop = 69888 - s.late
        while m.ticks_to_stop > 0: m.run()
        late = 0
        if m.iff1:
            m.on_handle_active_int()
        s.late = late; s.frame += 1
    def ram(s, a): return s.m.memory[0xFA00 + a]
    def image(s, scale=2, border=1):
        mem = s.m.memory; lc = mem[s.s['lineColor']]
        img = Image.new('RGB', (256 + 32, 192 + 32), PAL[border]); px = img.load()
        for y in range(192):
            for cx in range(32):
                b = mem[0x4000 | ((y & 0xC0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2) | cx]
                at = mem[0x5800 + (y >> 3) * 32 + cx]
                if lc and y in ROW3: at = ROW3[y]
                pal = PALB if at & 0x40 else PAL
                for bit in range(8):
                    px[16 + cx * 8 + bit, 16 + y] = pal[at & 7] if b & (0x80 >> bit) else pal[(at >> 3) & 7]
        return img.resize((img.width * scale, img.height * scale), Image.NEAREST)
if __name__ == '__main__':
    sc = json.load(open(sys.argv[1])); out = sys.argv[2]
    r = Run(sc.get('name', 'kk_e3')); gif = []; log = []
    g0, g1, gs = sc.get('gif', [0, 0, 1])
    for f in range(sc['frames']):
        keys = set()
        for e in sc.get('events', []):
            if e['from'] <= f < e['to']: keys |= set(e['keys'])
        r.step(keys)
        if f in sc.get('snap', []): r.image(3).save('%s_f%04d.png' % (out, f))
        if g0 <= f < g1 and (f - g0) % gs == 0: gif.append(r.image(2).convert('P', palette=Image.ADAPTIVE, colors=32))
        if sc.get('log'):
            log.append('%d %s' % (f, ' '.join('%02X' % r.ram(a) for a in (0x80, 0x88, 0x8D, 0x91, 0x92, 0x93, 0x95, 0xA0, 0xA1, 0xA2, 0xA3, 0x9D, 0xF0, 0xF2))))
    if gif: gif[0].save(out + '.gif', save_all=True, append_images=gif[1:], duration=20 * gs, loop=0, optimize=True)
    if log: open(out + '_log.txt', 'w').write('quadro kFlags gameOn jump kellyY kPos kSec anim A0 A1 A2 A3 timer elevHi elevLo\n' + '\n'.join(log) + '\n')
    print('ok', r.frame)
