"""Malha fechada: a mesma partida no 6502 (atari_lite, ROM original) e na logica traduzida (Z80),
quadro a quadro. Compara a RAM $80-$F7 depois do Vbl (no ponto do kernel) e depois do Over.
Uso: closed.py [--kern] lances...   ex.: closed.py b1c3 e2e4
  --kern: copia para o Z80 os bytes que o kernel do 2600 escreveu (como o --col do KK)."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import atari_lite as AL
from zlogic import Z80Logic
KERN = range(0xF0F2, 0xF27B)
CMP = range(0x80, 0xF8)
class Lock:
    """Faz o papel do Atari para as funcoes goto/button do atari_lite: cada quadro roda nos dois."""
    def __init__(s, rom, kern=False):
        s.a = AL.Atari(rom); s.mem = s.a.mem; s.kern = kern
        s.z = Z80Logic(); s.frames = 0; s.diffs = []; s.kwrites = set(); s.searches = 0
        s.cpu = s.a.cpu
        s.until({0xF00F})                     # depois do RESET e do setup, no inicio de um quadro
        for i in range(0x80, 0x100): s.z.setram(i, s.mem.ram[i - 0x80])
        s.z.m.ixl = s.cpu.x; s.z.m.iyl = s.cpu.y; s.z.m.a = s.cpu.a
    def until(s, pcs, track=False):
        c = s.cpu; mem = s.mem
        while True:
            c.step()
            if c.pc in pcs: return c.pc
    def compare(s, where):
        bad = [(i, s.mem.ram[i - 0x80], s.z.ram(i)) for i in CMP if s.mem.ram[i - 0x80] != s.z.ram(i)]
        if bad: s.diffs.append((s.frames, where, bad))
        return bad
    def frame(s):
        z = s.z; c = s.cpu
        z.inputs(s.mem.swcha, s.mem.swchb, s.mem.inpt4)
        s.until({0xF0F2}); z.vbl(); s.compare('vbl')
        # kernel no 6502: grava quem ele escreve
        before = bytes(s.mem.ram)
        s.until({0xF27B})
        if s.kern:
            for i in range(128):
                if s.mem.ram[i] != before[i]: z.setram(0x80 + i, s.mem.ram[i]); s.kwrites.add(0x80 + i)
            z.m.ixl = c.x; z.m.iyl = c.y
        else:
            for i in range(128):
                if s.mem.ram[i] != before[i]: s.kwrites.add(0x80 + i)
        st = s.mem.ram[0x73]
        pc = s.until({0xF2A2, 0xFA63})
        if pc == 0xFA63: s.searches += 1
        t = z.over(); s.compare('over' + (' (busca %d T)' % t if pc == 0xFA63 else ''))
        s.until({0xF00F})
        s.frames += 1; s.mem.frames += 1
    def run_frames(s, n, limit=None):
        for _ in range(n): s.frame()
        return n
    def board(s): return bytes(s.mem.ram[:64])
if __name__ == '__main__':
    args = sys.argv[1:]; kern = '--kern' in args; args = [x for x in args if x != '--kern']
    L = Lock(os.path.join(os.path.dirname(__file__), '..', 'rom', 'Vidchess.bin'), kern)
    L.run_frames(30)
    for mv in args:
        AL.goto(L, AL.sqn(mv[:2])); AL.button(L); AL.goto(L, AL.sqn(mv[2:])); AL.button(L)
        n = 0
        while L.mem.ram[0x73] != 0x80 and n < 3000: L.frame(); n += 1      # computador pensa
        L.run_frames(10)
        r = L.mem.ram
        print('%s -> computador %s-%s  (quadros %d, buscas %d, quadros com diferenca %d)' % (
            mv, AL.name(r[0x59]), AL.name(r[0x5A]), L.frames, L.searches, len(L.diffs)))
    print('bytes escritos pelo kernel:', ' '.join('%02X' % a for a in sorted(L.kwrites)))
    for f, w, bad in L.diffs[:12]:
        print('quadro %d %s: %s' % (f, w, ' '.join('%02X:%02X/%02X' % b for b in bad[:10])))
    outros = [(f, w, [b for b in bad if b[0] not in L.kwrites]) for f, w, bad in L.diffs]
    outros = [o for o in outros if o[2]]
    print('quadros com diferenca FORA dos bytes do kernel:', len(outros))
    for f, w, bad in outros[:12]:
        print('  quadro %d %s: %s' % (f, w, ' '.join('%02X:%02X/%02X' % b for b in bad[:10])))
    print('tabuleiro igual no fim:', all(L.mem.ram[i] == L.z.ram(0x80 + i) for i in range(64)))
