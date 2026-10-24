; Mini-BIOS SO PARA TESTES (emulador em Python): as entradas da BIOS do MSX que o
; jogo usa, feitas direto nas portas. Nao vai para o cartucho.
        DEVICE NOSLOT64K
        ORG $0000
        di
        jp $0000
        ORG $0024               ; ENASLT: no teste tudo ja esta mapeado
        ret
        ORG $0038               ; interrupcao do VDP: como a BIOS, le o status e chama H.TIMI
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        in a,($99)
        call $FD9F
        ld a,1                  ; "varre o teclado": o Python marca tecla no buffer
        out ($FF),a
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ei
        ret
        ORG $0056               ; FILVRM: HL = VRAM, BC = tamanho, A = valor
        jp Filvrm
        ORG $005C               ; LDIRVM: HL = RAM, DE = VRAM, BC = tamanho
        jp Ldirvm
        ORG $0072               ; INIGRP: SCREEN 2 com as tabelas padrao
        jp Inigrp
        ORG $0090               ; GICINI
        ret
        ORG $0093               ; WRTPSG: A = registrador, E = valor
        out ($A0),a
        push af
        ld a,e
        out ($A1),a
        pop af
        ret
        ORG $009C               ; CHSNS: NZ se ha tecla no buffer
        in a,($FE)
        or a
        ret
        ORG $00D5               ; GTSTCK
        in a,($FD)
        ret
        ORG $00D8               ; GTTRIG
        in a,($FC)
        ret
        ORG $0138               ; RSLREG
        xor a
        ret
        ORG $0141               ; SNSMAT: A = fileira -> A = bits (0 = apertada)
        out ($AA),a
        in a,($A9)
        ret
        ORG $0156               ; KILBUF
        xor a
        out ($FE),a
        ret
        ORG $0200
Filvrm: ld d,a
        di
        ld a,l
        out ($99),a
        ld a,h
        or $40
        out ($99),a
.l:     ld a,d
        out ($98),a
        dec bc
        ld a,b
        or c
        jr nz,.l
        ei
        ret
Ldirvm: di
        ld a,e
        out ($99),a
        ld a,d
        or $40
        out ($99),a
.l:     ld a,(hl)
        out ($98),a
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,.l
        ei
        ret
Inigrp: ld hl,Regs
        ld b,0
.r:     ld a,(hl)
        out ($99),a
        ld a,b
        or $80
        out ($99),a
        inc hl
        inc b
        ld a,b
        cp 8
        jr nz,.r
        ld a,0                  ; tabela de nomes $1800: 0..255 tres vezes
        out ($99),a
        ld a,$18|$40
        out ($99),a
        ld c,3
.t:     ld b,0
.n:     ld a,b
        out ($98),a
        inc b
        jr nz,.n
        dec c
        jr nz,.t
        ret
Regs:   DB $02, $E0, $06, $FF, $03, $36, $07, $F4      ; SCREEN 2, cores $2000, padroes $0000
        SAVEBIN "../build/msx/minibios.bin", $0000, $0300
