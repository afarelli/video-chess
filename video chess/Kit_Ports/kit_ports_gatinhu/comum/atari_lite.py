# "Atari de bolso": roda a ROM ORIGINAL do Video Chess num 6502 emulado
# com o minimo de hardware: RAM espelhada, timer RIOT, WSYNC, joystick.
# Sem video: so a logica. Serve p/ estudar o motor e validar o port.
import sys
sys.path.insert(0, '/home/claude/py65')
from py65.devices.mpu6502 import MPU

class AtariMem:
    def __init__(self, rom):
        self.rom, self.ram = rom, bytearray(128)
        self.swcha, self.inpt4, self.swchb = 0xFF, 0x80, 0x3F
        self.timer = (0, 1024, 0); self.cpu = None; self.frames = 0
    def __len__(self): return 0x10000
    def __getitem__(self, a):
        if isinstance(a, slice): return [self[i] for i in range(*a.indices(0x10000))]
        a &= 0x1FFF
        if a & 0x1000: return self.rom[a & 0xFFF]
        if a & 0x80:
            if not a & 0x200: return self.ram[a & 0x7F]
            r = a & 0x2FF
            if r == 0x280: return self.swcha
            if r == 0x282: return self.swchb
            if r in (0x284, 0x286):
                v, iv, st = self.timer; rem = v*iv - (self.cpu.processorCycles - st)
                return (rem // iv) & 0xFF if rem >= 0 else rem & 0xFF
            return 0
        if (a & 0xF) == 0xC: return self.inpt4
        return 0x80 if (a & 0xF) in (0xD,) else 0
    def __setitem__(self, a, v):
        if isinstance(a, slice): return
        a &= 0x1FFF
        if a & 0x1000: return
        if a & 0x80:
            if not a & 0x200: self.ram[a & 0x7F] = v & 0xFF; return
            r = a & 0x29F
            if r in (0x294, 0x295, 0x296, 0x297):
                self.timer = (v, {0x294:1, 0x295:8, 0x296:64, 0x297:1024}[r], self.cpu.processorCycles)
            return
        t = a & 0x3F
        if t == 0x02:                                   # WSYNC: pula ate o fim da linha
            c = self.cpu.processorCycles; self.cpu.processorCycles += (76 - c % 76) % 76
        elif t == 0x00 and v & 2: self.frames += 1      # VSYNC = novo quadro

class Atari:
    def __init__(self, rom_path):
        self.mem = AtariMem(open(rom_path, 'rb').read())
        self.cpu = MPU(memory=self.mem); self.mem.cpu = self.cpu
        self.cpu.pc = self.mem[0xFFFC] | self.mem[0xFFFD] << 8
    def run_frames(self, n, limit=50_000_000):
        target = self.mem.frames + n; steps = 0
        while self.mem.frames < target and steps < limit:
            self.cpu.step(); steps += 1
        return steps
    def board(self): return bytes(self.mem.ram[:64])
    def show(self):
        nm = '.KQBNRP?'
        for r in range(8):
            row = ''
            for c in range(8):
                v = self.mem.ram[r*8+c]; ch = nm[v & 7]
                row += (ch if v & 8 else ch.lower()) + ' '
            print(8-r, row)
        print('  a b c d e f g h')

DIRS = {'r': (0x7F, 1), 'l': (0xBF, -1), 'd': (0xDF, 8), 'u': (0xEF, -8)}
def goto(a, sq):
    r = a.mem.ram
    reg = 0x55 if r[0x73] & 1 else 0x54      # com peca na mao, o cursor e' $D5
    for _ in range(40):
        cur = r[reg]
        if cur == sq: return True
        d = ('r' if sq % 8 > cur % 8 else 'l') if sq % 8 != cur % 8 else ('d' if sq > cur else 'u')
        a.mem.swcha = DIRS[d][0]
        for _ in range(60):
            a.run_frames(1)
            if r[reg] != cur: break
        a.mem.swcha = 0xFF; a.run_frames(2)
    return False
def button(a):
    a.run_frames(40); a.mem.inpt4 = 0x00; a.run_frames(20); a.mem.inpt4 = 0x80; a.run_frames(20)
def sqn(s): return (8 - int(s[1])) * 8 + ord(s[0]) - 97
def name(i): return 'abcdefgh'[i % 8] + str(8 - i // 8)
def jogar(a, de, para, max_frames=20000):
    """faz o lance do jogador e espera o computador responder; devolve o lance dele"""
    goto(a, sqn(de)); button(a); goto(a, sqn(para)); button(a)
    antes = a.board()
    for f in range(max_frames):
        a.run_frames(1)
        b = a.board()
        if b != antes:
            ch = [i for i in range(64) if (b[i] ^ antes[i]) & 0x0F]
            if ch:
                a.run_frames(3)       # deixa terminar de escrever
                b = a.board()
                ch = [i for i in range(64) if (b[i] ^ antes[i]) & 0x0F]
                if all(not (b[i] & 8) for i in ch if b[i] & 7):   # mudou peca do computador
                    src = [i for i in ch if not b[i] & 7]; dst = [i for i in ch if b[i] & 7]
                    return [name(i) for i in src], [name(i) for i in dst], f
            antes = b
    return None
