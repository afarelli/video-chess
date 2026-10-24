; =====================================================================
; VIDEO CHESS - port para ZX Spectrum 48K / TK90X (etapa 3: paleta B, som, titulo)
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
BORDA    EQU 1          ; borda azul (paleta B)
; paleta B ("azuis do Atari"): fundo e casas escuras azul, casas claras azul
; brilhante; computador amarelo, jogador branco (o brilho segue a casa)
BRIGHT   EQU $40
PAP_CLARA EQU (1<<3)|BRIGHT
PAP_ESCURA EQU 1<<3
INK_PC   EQU 6          ; amarelo
INK_EU   EQU 7          ; branco
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
        ld a,BORDA
        out ($FE),a
        ld hl,Rodape            ; devolve as fileiras 22-23 do titulo (a ROM pode te-las apagado)
        ld de,$50C0
        ld b,8
.rd:    push bc
        push de
        ld bc,64
        ldir
        pop de
        inc d
        pop bc
        djnz .rd
        ld de,$5AC0
        ld bc,64
        ldir
        ei
        call Titulo             ; a tela de titulo veio com o LOAD "" SCREEN$
        di
        ; tela do jogo: tudo azul
        xor a
        ld hl,$4000
        ld de,$4001
        ld bc,6143
        ld (hl),a
        ldir
        ld hl,$5800
        ld de,$5801
        ld bc,767
        ld (hl),PAP_ESCURA|7
        ldir
        ; RAM do 2600 zerada, como o RESET dele ($F000)
        ld hl,$FA00
        ld de,$FA01
        ld bc,255
        ld (hl),0
        ldir
        ld a,(seed)             ; o tempo de espera no titulo vira o contador de
        ld (Z_D3),a             ; quadros do Atari, que a IA usa p/ variar as aberturas
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
        ld a,(lastFrame)
.w:     cp (hl)                 ; espera a interrupcao (sem HALT); se o som ja
        jr z,.w                 ; tocou ate ela, segue direto
        ld a,(hl)
        ld (lastFrame),a
        call Pausa
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
        ld a,(T_AUDC0)          ; som: a voz que o TIA tocaria agora, ate a proxima interrupcao
        call Som
        jr Main

; ---------------- pausa: H para, H de novo continua ----------------
Pausa:  call TeclaH
        ret nz
.s1:    call TeclaH             ; espera soltar
        jr z,.s1
.s2:    call TeclaH             ; espera apertar de novo
        jr nz,.s2
.s3:    call TeclaH
        jr z,.s3
        ld a,(isrFrames)        ; nao tenta recuperar o tempo parado
        ld (lastFrame),a
        ret
TeclaH: ld a,$BF                ; ENTER L K J H: H = bit 4 (Z = apertada)
        in a,($FE)
        bit 4,a
        ret

; ---------------- titulo: espera uma tecla; a espera vira a semente ----------------
Titulo: ld hl,seed
.t1:    inc (hl)                ; ate soltar tudo (a tecla do RUN/carga)
        xor a
        in a,($FE)
        cpl
        and $1F
        jr nz,.t1
.t2:    inc (hl)
        xor a
        in a,($FE)
        cpl
        and $1F
        jr z,.t2
        ret

; ---------------- som: "TIA de 1 bit" no beeper (o mesmo do Apple II) -------------
; Com AUDF0 = $0F (fixo no Video Chess) o TIA pulsa a ~1965 Hz. Cada AUDC vira
; onda quadrada (divisor) ou LFSR de 4/5/8 bits. Toca ate a proxima interrupcao.
Som:    and $0F
        ld e,a
        ld d,0
        ld hl,SModeT
        add hl,de
        ld a,(hl)
        or a
        ret z                   ; 0 = silencio
        ld (sMode),a
        ld hl,SDivT
        add hl,de
        ld a,(hl)
        ld (sDiv),a
        ld (sCnt),a
        ld a,(isrFrames)
        ld c,a
.tick:  ld a,(isrFrames)
        cp c
        ret nz                  ; a interrupcao chegou: fim do som deste quadro
        ld hl,sCnt
        dec (hl)
        jr nz,.esp
        ld a,(sDiv)
        ld (hl),a
        ld a,(sMode)
        cp 1
        jr nz,.poly
        ld a,(sOut)             ; onda quadrada
        xor 1
        jr .sai
.poly:  ld e,a                  ; LFSR de Galois (taps por modo)
        ld hl,PTap
        add hl,de
        ld b,(hl)
        ld a,(sPoly)
        srl a
        jr nc,.np
        xor b
.np:    ld (sPoly),a
        and 1
.sai:   ld hl,sOut
        cp (hl)
        jr z,.esp
        ld (hl),a
        rlca
        rlca
        rlca
        rlca                    ; bit 4 = alto-falante
        or BORDA
        out ($FE),a
.esp:   ld b,SOM_ESPERA         ; completa ~1780 T por pulso do TIA
.e1:    djnz .e1
        jp .tick
SOM_ESPERA EQU 128
;              AUDC:   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
SModeT: DB             0, 2, 2, 2, 1, 1, 1, 3, 4, 3, 1, 0, 1, 1, 1, 3
SDivT:  DB             1, 1,15, 1, 1, 1,15, 1, 1, 1,15, 1, 3, 3,46, 3
PTap:   DB 0, 0, $0C, $14, $B8      ; LFSR de 4, 5 e 8 bits
sMode:  DB 0
sDiv:   DB 1
sCnt:   DB 1
sPoly:  DB 1
sOut:   DB 0
lastFrame: DB 0
seed:   DB 0

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
        ld a,PAP_CLARA
        jr z,.cl
        ld a,PAP_ESCURA
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
        ld a,PAP_ESCURA
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
        ld a,PAP_ESCURA
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
        INCLUDE "rodape.asm"
CodeEnd:
        ASSERT CodeEnd < $E000
        SAVEBIN "../build/vchess.bin", $8000, CodeEnd - $8000
