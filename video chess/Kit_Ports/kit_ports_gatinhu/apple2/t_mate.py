# Monta posicoes de mate em 1 e observa o que o Atari faz ($EE, cores, AUDC0)
from apple_sim import *
import re, sys
lst = open('vchess.lst').read()
tick = LOAD + int(re.search(r'\n([0-9A-F]{6})r 1\s+(?:[0-9A-F]{2} ?)*\s*TICK:', lst).group(1), 16)
def sq(s): return (8 - int(s[1])) * 8 + ord(s[0]) - 97
def setpos(mem, pecas):
    for i in range(64): mem[0x80+i] &= 0xF0          # so o nibble baixo (os altos sao flags!)
    for s, v in pecas.items(): mem[0x80+sq(s)] = (mem[0x80+sq(s)] & 0xF0) | v
def goto(m, mem, alvo):
    reg = 0xD5 if mem[0xF3] & 1 else 0xD4
    for _ in range(30):
        c = mem[reg]
        if c == alvo: return
        k = ('r' if alvo % 8 > c % 8 else 'l') if alvo % 8 != c % 8 else ('d' if alvo > c else 'u')
        roteiro(m, mem, tick, k)
def lance(m, mem, a, b):
    goto(m, mem, sq(a)); roteiro(m, mem, tick, ' ', 80)
    goto(m, mem, sq(b)); roteiro(m, mem, tick, ' ', 80)
def estado(mem, t): print(t, 'F3=%02X EE=%02X DE..E1=%s AUDC0=%02X E2=%02X' % (mem[0xF3], mem[0xEE], ' '.join('%02X'%mem[a] for a in range(0xDE,0xE2)), mem[0x15], mem[0xE2]))
caso = sys.argv[1]
m, mem = boot('vchess.bin', tick); run(m, mem, tick, 40)
if caso == 'eu':      # jogador da mate: Ta1-a8#
    setpos(mem, {'h8': 1, 'g7': 6, 'h7': 6, 'e1': 9, 'a1': 0xD})
    run(m, mem, tick, 5); estado(mem, 'inicio'); lance(m, mem, 'a1', 'a8')
else:                 # computador da mate: ...Ta8-a1#
    setpos(mem, {'h1': 9, 'g2': 0xE, 'h2': 0xE, 'b2': 0xE, 'a8': 5, 'e8': 1})
    run(m, mem, tick, 5); estado(mem, 'inicio'); lance(m, mem, 'b2', 'b3')
for i in range(12):
    run(m, mem, tick, 60); estado(mem, 'q+60')
tab(mem); print('F7=%02X F6=%02X DD=%02X D9=%02X' % (mem[0xF7], mem[0xF6], mem[0xDD], mem[0xD9]))
R.render(mem, '/tmp/claude-0/-home-claude/d1c3068d-9b1b-557e-b7d8-faca50b4576f/scratchpad/mate_%s.png' % caso)
