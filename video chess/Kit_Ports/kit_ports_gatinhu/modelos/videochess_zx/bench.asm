; Banco de teste da logica traduzida: so a logica, sem tela.
; As ferramentas em Python chamam LogicVbl / LogicOver e comparam a RAM com o 6502.
        DEVICE ZXSPECTRUM48
        INCLUDE "zp.asm"
inSWCHA  EQU $FA60      ; entradas que o port preenche
inSWCHB  EQU $FA61
inINPT4  EQU $FA62
inINTIM  EQU $FA63      ; sempre 0: sem esperas do timer
T_AUDC0  EQU $FA68      ; sombras do som do TIA
T_AUDF0  EQU $FA69
T_AUDV0  EQU $FA6A
T_AUDC1  EQU $FA6B
T_AUDF1  EQU $FA6C
T_AUDV1  EQU $FA6D
        ORG $8000
Sentinel:
        halt                    ; o Python devolve o controle aqui
        jr Sentinel
; GetP: A = registrador P do 6502 (PHP + PLA), a partir das flags do Z80
; N = S, Z = Z, C = C, V = bit 6 de D; bits fixos: B (4), 5 e I (2) ligados.
; Saida como o PLA: N e Z de A, C preservado.
GetP:   push af
        pop hl                  ; L = flags do Z80
        ld a,$34
        bit 7,l
        jr z,.n
        or $80
.n:     bit 6,l
        jr z,.z
        or $02
.z:     bit 0,l
        jr z,.c
        or $01
.c:     bit 6,d
        jr z,.v
        or $40
.v:     ld h,a
        ld a,l
        rra                     ; carry original de volta
        ld a,h
        inc a
        dec a                   ; N e Z do valor, sem mexer no carry
        ret
        INCLUDE "logic_gen.asm"
LogicEnd:
        SAVEBIN "../build/bench.bin", $8000, LogicEnd - $8000
