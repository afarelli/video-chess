# Demonstracao: a ROM ORIGINAL do Video Chess jogando dentro do Python.
# Faz 1.Cc3 pelo "joystick" e mostra o lance que o motor de 1979 escolheu.
from atari_lite import *
a = Atari('Vidchess.bin'); a.run_frames(30); r = a.mem.ram
goto(a, sqn('b1')); button(a); goto(a, sqn('c3')); button(a)
c0 = a.cpu.processorCycles
while r[0x73] != 0x80: a.cpu.step()          # $F3 = $80: busca terminou ($FA57)
print('Motor pensou %.1f s (tempo de Atari)' % ((a.cpu.processorCycles - c0) / 1.19e6))
print('Lance escolhido: %s-%s  (origem $D9=%02X, destino $DA=%02X)' %
      (name(r[0x59]), name(r[0x5A]), r[0x59], r[0x5A]))
