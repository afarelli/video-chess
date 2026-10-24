"""Emulador mínimo do 2600 para estudar a ROM do Keystone Kapers: 6502 (py65), RIOT com
timer, WSYNC, TIA de mentira (escritas gravadas com o ciclo, leituras configuráveis).
Serve para cobertura de código (PCs executados), traço de quadros e oráculo de rotinas."""
from py65.devices.mpu6502 import MPU
import os, random
HERE = os.path.dirname(os.path.abspath(__file__))
ROMF = os.path.join(HERE, '..', 'rom', 'keystone_kapers.bin')

class Mem(list):
    def __init__(self, emu):
        super().__init__([0] * 65536); self.e = emu
    def __getitem__(self, a):
        if isinstance(a, slice): return [self[i] for i in range(*a.indices(65536))]
        e = self.e; a &= 0x1FFF
        if a & 0x1000:
            e.reads.add(a | 0xE000) if e.track else None
            return e.rom[a & 0xFFF]
        if a & 0x80 and not a & 0x200: return e.ram[a & 0x7F]
        if a & 0x280 == 0x280:
            r = a & 0x287
            if r == 0x280: return e.swcha
            if r == 0x282: return e.swchb
            if r in (0x284, 0x286): return e.intim()
            if r == 0x285: return 0
            return 0xFF
        r = a & 0x0F
        if r == 0x0C: return 0x00 if e.fire else 0x80
        if r == 0x0D: return 0x80
        if r == 7 and e.cq: return e.cq.pop(0)
        if r < 8: return e.coll(r) | (a & 0x3F)  # bits 0-5: barramento aberto (byte do operando)
        return 0
    def __setitem__(self, a, v):
        e = self.e; a &= 0x1FFF; v &= 255
        if a & 0x1000: return
        if a & 0x80 and not a & 0x200: e.ram[a & 0x7F] = v; return
        if a & 0x280 == 0x280:
            r = a & 0x297
            if r & 0x14 == 0x14:
                e.tim_set(v, {0: 1, 1: 8, 2: 64, 3: 1024}[a & 3])
            return
        r = a & 0x3F
        e.tia_write(r, v)

class Emu:
    def __init__(self, rom=None, seed=0):
        self.rom = rom or open(ROMF, 'rb').read()
        self.ram = [0] * 128; self.track = False; self.reads = set()
        self.swcha = 0xFF; self.swchb = 0x0B; self.fire = False
        self.rng = random.Random(seed); self.collmode = 0  # 0: zero, 1: aleatório
        self.m = MPU(); self.m.memory = Mem(self)
        self.m.pc = self.rom[0xFFC] | self.rom[0xFFD] << 8
        self.tim_c = 0; self.tim_v = 0; self.tim_i = 1024
        self.pcs = set(); self.writes = []; self.vsync_hit = False; self.frame_c0 = 0
        self.line_c0 = 0; self.cq = []
    def cyc(self): return self.m.processorCycles
    def tim_set(self, v, i):
        self.tim_c = self.cyc(); self.tim_v = v; self.tim_i = i
    def intim(self):
        d = self.cyc() - self.tim_c
        n = d // self.tim_i
        if n <= self.tim_v: return (self.tim_v - n) & 255
        return (- (d - self.tim_v * self.tim_i) ) & 255  # depois de zerar conta de 1 em 1
    def coll(self, r):
        return self.rng.choice((0, 0x40, 0x80, 0xC0)) if self.collmode else 0
    def tia_write(self, r, v):
        c = self.cyc()
        if r == 0x02:  # WSYNC
            rel = (c - self.frame_c0) % 76
            if rel: self.m.processorCycles += 76 - rel
        if r == 0x00 and v & 2 and not self.vsync_on:
            self.vsync_hit = True
        if r == 0x00: self.vsync_on = bool(v & 2)
        if self.logw: self.writes.append((c - self.frame_c0, r, v))
    vsync_on = False; logw = False
    def step(self):
        self.pcs.add(self.m.pc); self.m.step()
    def frame(self, maxsteps=100000):
        """Roda até o próximo início de VSYNC. Devolve o PC onde parou."""
        self.vsync_hit = False; self.writes = []
        for _ in range(maxsteps):
            self.step()
            if self.vsync_hit:
                self.frame_c0 = self.cyc(); return self.m.pc
        raise RuntimeError('sem VSYNC; PC=$%04X' % self.m.pc)
