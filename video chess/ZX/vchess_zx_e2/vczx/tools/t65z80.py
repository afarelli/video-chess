"""Tradutor 6502 -> Z80 (adaptado do kit do Keystone Kapers para o Video Chess).
Cada instrução do 6502 vira uma sequência Z80 que mantém A, X, Y, a RAM e as flags do 6502
que forem usadas depois (análise de vivacidade das flags N, Z, C, V no grafo do programa).
Convenções no Z80:
  A = A; X = IXL e Y = IYL (IX = IY = $FB00 + registrador): zp,X com zp >= $80 vira (ix+zp-256).
  RAM do 2600 ($80-$FF) em ZP = $FA00 + endereço; ROM do 2600 em ROM2 = $E000 + (endereço - $F000).
  Carry do Z80 = carry do 6502 sempre (depois de CMP/SBC entra um CCF).
  Registradores HL, DE e BC são temporários.
TIA: escritas em AUDC0/AUDF0/AUDV0 vão para sombras (T_AUDC0...); as demais somem.
Entradas: inSWCHA, inSWCHB, inINPT4 (lidos onde o 6502 lê SWCHA, SWCHB, INPT4/$3C).
Uso: python3 t65z80.py saida.asm Rotulo:inicio:fim [...]   (fim = endereço onde vira RET)"""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from op6502 import OPS, MODES
H = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.join(H, '..')
CFG = json.load(open(os.environ.get('T65CFG', os.path.join(ROOT, 'rom', 'jogo.json'))))
ROM = open(os.path.join(ROOT, 'rom', CFG['rom']), 'rb').read()
NAMES = json.load(open(os.path.join(ROOT, 'rom', CFG['nomes']))) if CFG.get('nomes') else {'ram': {}, 'labels': {}}
RAMN = {int(k, 16): v for k, v in NAMES['ram'].items()}
LABN = {int(k, 16): v for k, v in NAMES['labels'].items()}
def rb(a): return ROM[a - 0xF000]
ZP, ROM2, IXH = 0xFA00, 0xE000, 0xFB
def decode(a):
    op = rb(a)
    m, mode = OPS[op]; n = MODES[mode][0]
    v = None
    if n == 2: v = rb(a + 1)
    if n == 3: v = rb(a + 1) | rb(a + 2) << 8
    if mode == 'rel': v = (a + 2 + (v - 256 if v > 127 else v)) & 0xFFFF
    return m, mode, v, n
# instruções do truque BIT $2C (o byte $2C só pula os 2 seguintes)
SKIP2 = {int(a, 16) for a in CFG.get('skip2', [])}
DECS = [range(int(a, 16), int(b, 16)) for a, b in CFG.get('decimal', [])]   # trechos SED ... CLD
FRAME_END = {int(a, 16) for a in CFG.get('frame_end', [])}                  # JMP para estes = fim do passo (ret)
DROP2 = {int(a, 16) for a in CFG.get('drop2', [])}                          # PLA PLA que descartam um retorno
PLP_OF = {int(a, 16): int(b, 16) for a, b in CFG.get('php_plp', {}).items()}
def zpname(n): return 'Z_%02X' % n
def rom2(a): return a - 0xF000 + ROM2
TIA_AUD = {0x15: 'T_AUDC0', 0x17: 'T_AUDF0', 0x19: 'T_AUDV0', 0x16: 'T_AUDC1', 0x18: 'T_AUDF1', 0x1A: 'T_AUDV1'}
def is_tia(v, mode):
    return mode in ('zp', 'zpx', 'zpy', 'abs', 'abx', 'aby') and v < 0x80 and not (mode in ('abs',) and v >= 0x280)

# ---------------- grafo e vivacidade das flags ----------------
class Prog:
    def __init__(s, units):
        s.units = units; s.ins = {}; s.succ = {}; s.calls = {}
        work = [st for _, st, _ in units]; stops = {en for _, _, en in units}
        starts = {st for _, st, _ in units}
        s.stops = stops; s.callers = {}
        while work:
            a = work.pop()
            if a in s.ins or (a in stops and a not in starts): continue
            if a in SKIP2:
                s.ins[a] = ('SKIP2', 'imp', None, 3); s.succ[a] = [a + 3]; work.append(a + 3); continue
            d = decode(a); s.ins[a] = d; m, mode, v, n = d
            nx = a + n
            if m in ('RTS',): s.succ[a] = []
            elif m == 'JMP':
                if v in FRAME_END: s.succ[a] = []
                else: s.succ[a] = [v]; work.append(v)
            elif mode == 'rel': s.succ[a] = [nx, v]; work += [nx, v]
            elif m == 'JSR':
                s.succ[a] = [v]; work += [v, nx]; s.callers.setdefault(v, []).append(nx)
            else: s.succ[a] = [nx]; work.append(nx)
        # RTS -> pontos de retorno de quem chamou (todas as chamadas que alcançam esse RTS)
        s.rts_ret = {}
        for entry, rets in s.callers.items():
            seen = set(); st = [entry]
            while st:
                a = st.pop()
                if a in seen or a not in s.ins: continue
                seen.add(a)
                m = s.ins[a][0]
                if m == 'RTS': s.rts_ret.setdefault(a, set()).update(rets); continue
                if m == 'JSR': st.append(s.ins[a][3] + a); continue
                st += s.succ[a]
        s.live()
    def uses_defs(s, a):
        m, mode, v, n = s.ins[a]
        U, D = set(), set()
        if m == 'SKIP2': return set(), {'N', 'Z', 'V'}
        if m in ('BEQ', 'BNE'): U = {'Z'}
        elif m in ('BMI', 'BPL'): U = {'N'}
        elif m in ('BCC', 'BCS'): U = {'C'}
        elif m in ('BVC', 'BVS'): U = {'V'}
        if m in ('ADC', 'SBC'): U = {'C'}; D = {'N', 'Z', 'C', 'V'}
        if m in ('ROL', 'ROR'): U = {'C'}; D = {'N', 'Z', 'C'}
        if m in ('ASL', 'LSR', 'CMP', 'CPX', 'CPY'): D = {'N', 'Z', 'C'}
        if m in ('LDA', 'LDX', 'LDY', 'TAX', 'TXA', 'TAY', 'TYA', 'INX', 'INY', 'DEX', 'DEY', 'INC', 'DEC', 'AND', 'ORA', 'EOR', 'TSX'):
            D = {'N', 'Z'}
        if m == 'BIT': D = {'N', 'Z', 'V'}
        if m in ('CLC', 'SEC'): D = {'C'}
        if m == 'CLV': D = {'V'}
        if m == 'PHP': U = {'N', 'Z', 'C', 'V'}
        if m == 'PLP': D = {'N', 'Z', 'C', 'V'}
        if m == 'PLA': D = {'N', 'Z'}
        return U, D
    def nexts(s, a):
        m = s.ins[a][0]
        if m == 'RTS': return list(s.rts_ret.get(a, []))
        if m == 'JSR': return [s.ins[a][2]]
        return [x for x in s.succ[a]]
    def live(s):
        s.lin = {a: set() for a in s.ins}; s.lout = {a: set() for a in s.ins}
        ch = True
        while ch:
            ch = False
            for a in s.ins:
                out = set()
                for b in s.nexts(a):
                    if b in s.lin: out |= s.lin[b]
                U, D = s.uses_defs(a)
                inn = U | (out - D)
                if out != s.lout[a] or inn != s.lin[a]: s.lout[a] = out; s.lin[a] = inn; ch = True

# ---------------- emissão ----------------
def label(a): return 'L_%04X' % a
def emit(prog):
    L = []
    E = L.append
    for unit, st, en in prog.units:
        E('%s:' % unit)
        E('        jp %s' % label(st))
    state = {'Nd': False, 'Sok': False}     # N do último BIT está em D; S do Z80 ainda vale
    for a in sorted(prog.ins):
        m, mode, v, n = prog.ins[a]
        nm = LABN.get(a, '')
        E('%s:%s' % (label(a), ('  ; ' + nm) if nm else ''))
        lo = prog.lout[a]; li = prog.lin[a]
        dec = any(a in r for r in DECS)
        def nz(reg='a'):
            """6502 seta N e Z do resultado: no Z80, só se forem usados depois"""
            if not ({'N', 'Z'} & lo): return
            if reg == 'a': E('        inc a\n        dec a' if 'C' in lo else '        or a')
            else: E('        inc %s\n        dec %s' % (reg, reg))
        def follow():
            nx = a + n
            if nx in prog.stops: E('        ret')
            elif nx not in prog.ins: raise SystemExit('fluxo sai do código traduzido em %04X' % nx)
        def target(t): return 'ret' if t in prog.stops else label(t)
        def jumpcc(cc, t):
            if t in prog.stops: E('        ret %s' % cc)
            else: E('        jp %s,%s' % (cc, label(t)))
        if m not in ('BMI', 'BPL', 'BVC', 'BVS', 'BEQ', 'BNE', 'BCC', 'BCS'):
            U, D = prog.uses_defs(a)
            if 'N' in D and m != 'BIT': state['Nd'] = False
        if m == 'SKIP2':
            if {'N', 'Z', 'V'} & lo: raise SystemExit('flags vivas depois do BIT $2C em %04X' % a)
            E(('        ret' if a + 3 in prog.stops else '        jp %s' % label(a + 3)) + '   ; .byte $2C: pula os 2 bytes seguintes'); continue
        if m in ('SEI', 'CLD', 'SED', 'NOP'): follow(); continue
        if m == 'CLV': E('        res 6,d          ; V do 6502 mora no bit 6 de D'); follow(); continue
        nxt = prog.ins.get(a + 1, (None,))[0]
        if m == 'PHP' and nxt == 'PLA':          # PHP / PLA = ler o registrador P em A
            E('        call GetP        ; PHP+PLA: A = P do 6502 (N V 1 B D I Z C)'); state['skip'] = a + 1; follow(); continue
        if m == 'PLA' and state.get('skip') == a: follow(); continue
        if m == 'PHP':
            if 'V' in prog.lout.get(PLP_OF.get(a, -1), set()): raise SystemExit('V vivo depois do PLP de %04X' % a)
            E('        push af          ; PHP (C, Z e N ficam no F do Z80)'); follow(); continue
        if m == 'PLP': E('        ld e,a\n        pop af           ; PLP\n        ld a,e'); follow(); continue
        if m == 'PHA': E('        push af          ; PHA'); follow(); continue
        if m == 'PLA' and a in DROP2:
            E('        pop hl           ; PLA PLA: descarta o endereco de retorno (sai da sub-rotina)'); state['skip'] = a + 1; follow(); continue
        if m == 'PLA':
            E('        pop hl           ; PLA\n        ld a,h'); nz(); follow(); continue
        if m == 'TXS': raise SystemExit('TXS na logica em %04X' % a)
        if m == 'CLC':
            E('        scf\n        ccf' if {'N', 'Z'} & lo else '        or a'); follow(); continue
        if m == 'SEC': E('        scf'); follow(); continue
        if m == 'RTS': E('        ret'); continue
        if m == 'JSR': E('        call %s' % label(v)); follow(); continue
        if m == 'JMP':
            E('        ret' if (v in prog.stops or v in FRAME_END) else '        jp %s' % label(v)); continue
        if mode == 'rel':
            if m in ('BVC', 'BVS') and ({'N', 'Z', 'C'} & lo):
                # BIT 6,D do Z80 estraga S e Z: preserva as flags do 6502 que ainda vao ser usadas
                lb = 'LB_%04X' % a
                E('        push af\n        bit 6,d\n        jr %s,%s\n        pop af\n        %s\n%s:\n        pop af' % (
                    'nz' if m == 'BVC' else 'z', lb, 'ret' if v in prog.stops else 'jp %s' % label(v), lb))
            elif m in ('BVC', 'BVS'):
                E('        bit 6,d'); state['Sok'] = False
                jumpcc('z' if m == 'BVC' else 'nz', v)
            elif m in ('BMI', 'BPL') and state['Nd'] and not state['Sok']:
                E('        bit 7,d'); jumpcc('nz' if m == 'BMI' else 'z', v)
            else:
                jumpcc({'BEQ': 'z', 'BNE': 'nz', 'BCC': 'nc', 'BCS': 'c', 'BMI': 'm', 'BPL': 'p'}[m], v)
            follow(); continue
        if m in ('TAX', 'TAY', 'TXA', 'TYA'):
            dst, srcr = {'TAX': ('ixl', 'a'), 'TAY': ('iyl', 'a'), 'TXA': ('a', 'ixl'), 'TYA': ('a', 'iyl')}[m]
            E('        ld %s,%s' % (dst, srcr)); nz(dst); follow(); continue
        if m in ('INX', 'INY', 'DEX', 'DEY'):
            E('        %s %s' % ('inc' if m[0] == 'I' else 'dec', 'ixl' if m[2] == 'X' else 'iyl')); follow(); continue
        if mode == 'acc':
            if {'N', 'Z'} & lo: zop = {'ASL': 'sla a', 'LSR': 'srl a', 'ROL': 'rl a', 'ROR': 'rr a'}[m]
            else: zop = {'ASL': 'add a,a', 'LSR': 'srl a', 'ROL': 'rla', 'ROR': 'rra'}[m]
            E('        ' + zop); follow(); continue
        # ---------- operando ----------
        reg = {'LDA': 'a', 'LDX': 'ixl', 'LDY': 'iyl', 'STA': 'a', 'STX': 'ixl', 'STY': 'iyl',
               'CPX': 'ixl', 'CPY': 'iyl'}.get(m)
        opnd = None; direct = None          # direct = endereço absoluto para LD A,(nn)
        if mode == 'imm':
            opnd = '$%02X' % v
        elif mode in ('zp', 'abs') and v < 0x80:
            r6 = v & 0x3F
            if m in ('STA', 'STX', 'STY'):
                if r6 in TIA_AUD and v < 0x40:
                    if reg == 'a': E('        ld (%s),a' % TIA_AUD[r6])
                    else: E('        ld e,%s\n        ld hl,%s\n        ld (hl),e' % (reg, TIA_AUD[r6]))
                follow(); continue
            if (v & 0x0F) == 0x0C: direct = 'inINPT4'
            else: raise SystemExit('leitura do TIA em %04X' % a)
        elif mode == 'abs' and v in (0x280, 0x282):
            direct = 'inSWCHA' if v == 0x280 else 'inSWCHB'
        elif mode == 'abs' and v in (0x284, 0x285):
            direct = 'inINTIM'
        elif mode == 'abs' and v in (0x294, 0x295, 0x296, 0x297):
            follow(); continue                # timer do RIOT: some
        elif mode in ('zp', 'abs') and 0x80 <= v < 0x100:
            direct = zpname(v)
        elif mode == 'abs' and v >= 0xF000:
            direct = '$%04X' % rom2(v)
        elif mode in ('zpx', 'abx') and 0x80 <= v < 0x100:
            opnd = '(ix-%d)' % (256 - v)
        elif mode in ('zpy', 'aby') and 0x80 <= v < 0x100:
            opnd = '(iy-%d)' % (256 - v)
        elif mode == 'zpx' and v < 0x80 and m != 'STA':
            # leitura $7F,X etc.: com X >= 1 cai na RAM (pagina zero do 2600 em ZP)
            E('        push af\n        ld a,ixl\n        add a,$%02X\n        ld l,a\n        ld h,$%02X\n        pop af' % (v, ZP >> 8))
            opnd = '(hl)'
        elif mode == 'zpx' and v < 0x80:
            E('        ld e,a\n        ld a,ixl\n        add a,$%02X\n        ld l,a\n        ld h,$%02X\n        ld (hl),e\n        ld a,e' % (v, ZP >> 8))
            follow(); continue
        elif mode in ('abx', 'aby') and v >= 0xF000:
            ir = 'ixl' if mode == 'abx' else 'iyl'
            keep = not (m in ('LDA',) and not ({'C', 'V'} & li))
            if keep: E('        push af')
            t = rom2(v)
            E('        ld a,%s\n        add a,$%02X\n        ld l,a\n        adc a,$%02X\n        sub l\n        ld h,a' % (ir, t & 255, t >> 8))
            if keep: E('        pop af')
            opnd = '(hl)'
        elif mode == 'izy':
            keep = not (m == 'LDA' and not ({'C', 'V'} & li))
            if keep: E('        push af')
            E('        ld hl,(%s)\n        ld a,h\n        sub $10\n        ld h,a\n        ld e,iyl\n        ld d,0\n        add hl,de' % zpname(v))
            if keep: E('        pop af')
            opnd = '(hl)'
        else:
            raise SystemExit('modo %s %s em %04X' % (m, mode, a))
        def via_hl():
            """operando para ALU: '(hl)' (carregando HL se for absoluto), imediato ou indexado"""
            if direct: E('        ld hl,%s' % direct); return '(hl)'
            return opnd
        # ---------- operações ----------
        if m in ('LDA', 'LDX', 'LDY'):
            if reg == 'a':
                E('        ld a,(%s)' % direct if direct else '        ld a,%s' % opnd)
            else:
                o = via_hl()
                if o.startswith('('): E('        ld e,%s\n        ld %s,e' % (o, reg))
                else: E('        ld %s,%s' % (reg, o))
            nz(reg); follow(); continue
        if m in ('STA', 'STX', 'STY'):
            if reg == 'a':
                E('        ld (%s),a' % direct if direct else '        ld %s,a' % opnd)
            else:
                o = via_hl()
                E('        ld e,%s\n        ld %s,e' % (reg, o))
            follow(); continue
        if m in ('AND', 'ORA', 'EOR'):
            zop = {'AND': 'and', 'ORA': 'or', 'EOR': 'xor'}[m]; o = via_hl()
            if 'C' in lo:
                lb = 'LC_%04X' % a
                E('        jr nc,%s_0\n        %s %s\n        scf\n        jr %s_1\n%s_0:\n        %s %s\n%s_1:' % (lb, zop, o, lb, lb, zop, o, lb))
            else: E('        %s %s' % (zop, o))
            follow(); continue
        def vflag():
            """6502 V = overflow do Z80 (flag P/V): copiado para o bit 6 de D, se for usado"""
            if 'V' in lo:
                lb = 'LV_%04X' % a
                E('        jp pe,%s_1\n        res 6,d\n        jr %s_2\n%s_1:\n        set 6,d\n%s_2:' % (lb, lb, lb, lb))
        if m == 'ADC':
            o = via_hl(); E('        adc a,%s' % o)
            if dec: E('        daa')
            vflag(); follow(); continue
        if m == 'SBC':
            o = via_hl(); E('        ccf\n        sbc a,%s' % o)
            if dec: E('        daa')
            E('        ccf'); vflag(); follow(); continue
        if m == 'CMP':
            o = via_hl(); E('        cp %s' % o)
            if 'C' in lo: E('        ccf')
            follow(); continue
        if m in ('CPX', 'CPY'):
            o = via_hl()
            if o.startswith('('): E('        ld e,%s' % o); o = 'e'
            E('        ld b,a\n        ld a,%s\n        cp %s\n        ld a,b' % (reg, o))
            if 'C' in lo: E('        ccf')
            follow(); continue
        if m == 'BIT':
            o = via_hl(); E('        ld d,%s' % o)
            if 'Z' in lo and 'N' in lo: raise SystemExit('BIT com N e Z vivos em %04X' % a)
            if 'Z' in lo: E('        ld e,a\n        and d\n        ld a,e')
            if 'N' in lo: E('        ld e,a\n        ld a,d\n        inc a\n        dec a\n        ld a,e')
            state['Nd'] = True; state['Sok'] = 'N' in lo
            follow(); continue
        if m in ('ASL', 'LSR', 'ROL', 'ROR', 'INC', 'DEC'):
            if mode == 'acc':
                if {'N', 'Z'} & lo: zop = {'ASL': 'sla a', 'LSR': 'srl a', 'ROL': 'rl a', 'ROR': 'rr a'}[m]
                else: zop = {'ASL': 'add a,a', 'LSR': 'srl a', 'ROL': 'rla', 'ROR': 'rra'}[m]
                E('        ' + zop)
            else:
                zop = {'ASL': 'sla', 'LSR': 'srl', 'ROL': 'rl', 'ROR': 'rr', 'INC': 'inc', 'DEC': 'dec'}[m]
                if direct in ('inSWCHB', 'inSWCHA'):   # o RIOT ignora a escrita
                    E('        ld hl,%s\n        ld e,(hl)\n        %s e' % (direct, zop))
                else:
                    o = via_hl(); E('        %s %s' % (zop, o))
            follow(); continue
        raise SystemExit('instrução %s em %04X' % (m, a))
    return L
if __name__ == '__main__':
    out = sys.argv[1]
    units = []
    for u in sys.argv[2:]:
        nm, st, en = u.split(':'); units.append((nm, int(st, 16), int(en, 16)))
    p = Prog(units)
    # BMI/BPL logo depois de um BIT (sem outra instrução que mexa em N): testam o bit 7 de D
    L = emit(p)
    print('instruções traduzidas', len(p.ins))
    open(out, 'w').write('\n'.join(L) + '\n')
