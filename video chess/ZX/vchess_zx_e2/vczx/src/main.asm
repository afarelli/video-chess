; =====================================================================
; VIDEO CHESS - port para ZX Spectrum 48K / TK90X (etapa 2: jogavel)
; A logica e' o codigo original do Atari 2600 (1979) traduzido para Z80
; (tools/t65z80.py -> logic_gen.asm). Aqui ficam so: interrupcao,
; teclado -> joystick/chaves do console, e o desenho do tabuleiro.
; =====================================================================
        DEVICE ZXSPECTRUM48
        INCLUDE "zp.asm"
inSWCHA  EQU $FA60      ; entradas que a logica le no lugar do RIOT/TIA
inSWCHB  EQU $FA61
inINPT4  EQU $FA62
inINTIM  EQU $FA63      ; sempre 0
T_AUDC0  EQU $FA68      ; sombras do som do TIA (etapa de som)
T_AUDF0  EQU $FA69
T_AUDV0  EQU $FA6A
T_AUDC1  EQU $FA6B
T_AUDF1  EQU $FA6C
T_AUDV1  EQU $FA6D
ROM2600  EQU $E000      ; copia da ROM do Atari (tabelas lidas pela logica)
BORDA    EQU 0          ; borda preta
; cores (atributos): tudo BRIGHT, como o Apple aprovado: fundo e casas
; escuras pretas, casas claras azuis, computador amarelo, jogador branco
PAP_CLARA EQU 1<<3      ; papel azul
PAP_ESCURA EQU 0<<3     ; papel preto
INK_PC   EQU 6          ; amarelo
INK_EU   EQU 7          ; branco
BRIGHT   EQU $40
autoStart EQU 1         ; (etapas futuras: menu)

        ORG $8000
Start:  di
        ld sp,$FDF0
        ; IM 2 propria: tabela $FE00-$FF00 com $FD, JP Isr em $FDFD
        ld hl,$FE00
        ld de,$FE01
        ld bc,256
        ld (hl),$FD
        ldir
        ld a,$C3
        ld ($FDFD),a
        ld hl,Isr
        ld ($FDFE),hl
        ld a,$FE
        ld i,a
        im 2
        ; tela: tudo preto
        xor a
        out ($FE),a
        ld hl,$4000
        ld de,$4001
        ld bc,6143
        ld (hl),a
        ldir
        ld hl,$5800
        ld de,$5801
        ld bc,767
        ld (hl),BRIGHT
        ldir
        ; RAM do 2600 zerada, como o RESET dele ($F000)
        ld hl,$FA00
        ld de,$FA01
        ld bc,255
        ld (hl),0
        ldir
        ld ix,$FB00
        ld iy,$FB00
        ld hl,Shadow            ; forca desenhar tudo
        ld de,Shadow+1
        ld bc,63+2
        ld (hl),$FF
        ldir
        ld a,2                  ; 2 quadros com o RESET apertado: monta o tabuleiro
        ld (rstCnt),a
        ei
; ---------------- laco principal: um passo do 2600 por quadro ----------------
Main:   ld hl,isrFrames
        ld a,(hl)
.w:     cp (hl)                 ; espera a interrupcao (sem HALT)
        jr z,.w
        call ReadKeys
        call LogicVbl           ; inicio do quadro do Atari (aplica cursor e pisca)
        call DrawBoard          ; o que o kernel desenharia: so as casas que mudaram
        call DrawPanel
        ld a,1
        ld (inOver),a
        call LogicOver          ; fim do quadro: joystick, regras e, as vezes, a busca da IA
        xor a
        ld (inOver),a
        ld (isrOver),a
        ld a,BORDA
        out ($FE),a
        jr Main

; ---------------- interrupcao: conta quadros e pisca a borda enquanto a IA pensa
Isr:    push af
        push hl
        ld hl,isrFrames
        inc (hl)
        ld a,(inOver)
        or a
        jr z,.fim
        ld hl,isrOver           ; o Over ja passou de um quadro: e' a busca
        inc (hl)
        ld a,(hl)
        cp 2
        jr c,.fim
        ld a,(rnd)              ; borda com cor sorteada (o "embaralhado" do Atari)
        add a,a
        jr nc,.r
        xor $1D
.r:     ld (rnd),a
        and 7
        out ($FE),a
.fim:   pop hl
        pop af
        ei
        reti

; ---------------- teclado -> joystick e chaves do console do 2600 ----------------
; I/K/J/L = cima/baixo/esquerda/direita, ESPACO = botao, 1 = GAME SELECT, 2 = GAME RESET
ReadKeys:
        ld c,$FF                ; SWCHA: bits 7..4 = direita, esquerda, baixo, cima (0 = apertado)
        ld a,$DF                ; P O I U Y
        in a,($FE)
        bit 2,a                 ; I
        jr nz,.k1
        res 4,c
.k1:    ld a,$BF                ; ENTER L K J H
        in a,($FE)
        ld b,a
        bit 2,b                 ; K
        jr nz,.k2
        res 5,c
.k2:    bit 3,b                 ; J
        jr nz,.k3
        res 6,c
.k3:    bit 1,b                 ; L
        jr nz,.k4
        res 7,c
.k4:    ld a,c
        ld (inSWCHA),a
        ld a,$7F                ; SPACE SYM M N B
        in a,($FE)
        rrca                    ; bit 0 = espaco -> carry
        ld a,$80
        jr c,.b
        xor a                   ; INPT4 bit 7 = 0: botao apertado
.b:     ld (inINPT4),a
        ld c,$3F                ; SWCHB: chaves B/B, cor, select e reset soltos
        ld a,$F7                ; 1 2 3 4 5
        in a,($FE)
        bit 0,a                 ; 1 = select
        jr nz,.s
        res 1,c
.s:     bit 1,a                 ; 2 = reset
        jr nz,.r
        res 0,c
.r:     ld a,(rstCnt)
        or a
        jr z,.r2
        dec a
        ld (rstCnt),a
        res 0,c
.r2:    ld a,c
        ld (inSWCHB),a
        xor a
        ld (inINTIM),a
        ret

; ---------------- desenho ----------------
; DrawBoard: as 64 casas ($80-$BF da RAM do 2600, nibble baixo) contra a sombra
DrawBoard:
        ld b,0                  ; casa
.l:     ld hl,Z_80
        ld a,l
        add a,b
        ld l,a
        ld a,(hl)
        and $0F
        ld hl,Shadow
        ld e,b
        ld d,0
        add hl,de
        cp (hl)
        jr z,.n
        ld (hl),a
        push bc
        ld c,a                  ; C = valor, B = casa
        ld a,b
        and 7
        ld e,a
        add a,a
        add a,e
        add a,4                 ; coluna de caractere = 4 + 3*coluna
        ld e,a
        ld a,b
        rrca
        rrca
        rrca
        and 7
        ld d,a
        add a,a
        add a,d                 ; fileira de caractere = 3*linha
        ld d,a
        ld a,b                  ; casa clara se linha+coluna par
        rrca
        rrca
        rrca
        xor b
        and 1
        ld a,PAP_CLARA|BRIGHT
        jr z,.cl
        ld a,PAP_ESCURA|BRIGHT
.cl:    call DrawTile           ; D = fileira, E = coluna, C = valor, A = papel
        pop bc
.n:     inc b
        ld a,b
        cp 64
        jr nz,.l
        ret

; DrawPanel: rei tombado (quem levou mate, $EE) a esquerda e nivel ($EA) a direita
DrawPanel:
        ld a,(Z_EE)             ; 0 = computador perdeu, 1 = jogador perdeu, 3 = jogando
        ld c,0
        or a
        jr nz,.p1
        ld c,7                  ; rei tombado do computador
.p1:    dec a
        jr nz,.p2
        ld c,$0F                ; rei tombado do jogador
.p2:    ld hl,Shadow+64
        ld a,c
        cp (hl)
        jr z,.p3
        ld (hl),a
        ld de,$0000             ; fileira 0, coluna 0
        ld a,BRIGHT
        call DrawTile
.p3:    ld a,(Z_EA)             ; nivel 0-7 -> digito 1-8 (blocos 16-23)
        and 7
        add a,16
        ld hl,Shadow+65
        cp (hl)
        ret z
        ld (hl),a
        ld c,a
        ld de,$001D             ; fileira 0, coluna 29
        ld a,BRIGHT
        jp DrawTile

; DrawTile: bloco C (0-23) em 3x3 caracteres na fileira D, coluna E, com papel A
DrawTile:
        ld (.pap+1),a
        ld a,e
        ld (tcol),a
        ld a,d
        ld (trow),a
        add a,a
        add a,a
        add a,a
        ld (ty),a               ; linha de pixel inicial = 8*fileira
        ; tinta: jogador (bit 3) branco; computador e cursor X amarelos; digitos brancos
        ld a,c
        ld b,INK_EU
        cp 16
        jr nc,.ik
        ld b,INK_PC
        cp 8
        jr z,.ik
        bit 3,a
        jr z,.ik
        ld b,INK_EU
.ik:    ld a,b
.pap:   or 0                    ; (auto-modificado) papel + BRIGHT
        ld (attr),a
        ld l,c                  ; HL = Tiles + 72*C
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        push hl
        add hl,hl
        add hl,hl
        add hl,hl
        pop bc
        add hl,bc
        ld bc,Tiles
        add hl,bc
        ld b,24
.lin:   push bc
        push hl
        ld a,(ty)
        ld l,a
        ld h,0
        add hl,hl
        ld de,Lines
        add hl,de
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld a,(tcol)
        add a,e
        ld e,a                  ; DE = tela
        pop hl
        ldi
        ldi
        ldi
        ld a,(ty)
        inc a
        ld (ty),a
        pop bc
        djnz .lin
        ld a,(trow)             ; atributos 3x3: $5800 + 32*fileira + coluna
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,(tcol)
        ld e,a
        ld d,$58
        add hl,de
        ld a,(attr)
        ld b,3
.at:    ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        ld (hl),a
        ld de,30
        add hl,de
        djnz .at
        ret

tcol:   DB 0
trow:   DB 0
ty:     DB 0
isrFrames: DB 0
inOver: DB 0
isrOver: DB 0
rstCnt: DB 0
rnd:    DB $5A
attr:   DB 0
Shadow: DS 66
; GetP: A = registrador P do 6502 (PHP + PLA), ver bench.asm
GetP:   push af
        pop hl
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
        rra
        ld a,h
        inc a
        dec a
        ret
        INCLUDE "logic_gen.asm"
        INCLUDE "tiles.asm"
CodeEnd:
        ASSERT CodeEnd < $E000
        SAVEBIN "../build/vchess.bin", $8000, CodeEnd - $8000
