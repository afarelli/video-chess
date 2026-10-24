; =====================================================================
; VIDEO CHESS - port para MSX1 (cartucho de 32 KB, SCREEN 2, PSG)
; A logica e' o codigo original do Atari 2600 (1979) traduzido para Z80
; (tools/t65z80.py com rom/jogo_msx.json -> logic_msx.asm), o mesmo do
; port do ZX Spectrum. Aqui: BIOS, VDP TMS9918, teclado/joystick e PSG.
; Cartucho: pagina 1 ($4000) = codigo; pagina 2 ($8000) = titulo + ROM do 2600.
; =====================================================================
        DEVICE NOSLOT64K
        INCLUDE "zp_msx.asm"
; BIOS
ENASLT  EQU $0024
FILVRM  EQU $0056
LDIRVM  EQU $005C
INIGRP  EQU $0072
GICINI  EQU $0090
WRTPSG  EQU $0093
CHSNS   EQU $009C
GTSTCK  EQU $00D5
GTTRIG  EQU $00D8
RSLREG  EQU $0138
SNSMAT  EQU $0141
KILBUF  EQU $0156
EXPTBL  EQU $FCC1
CLIKSW  EQU $F3DB
FORCLR  EQU $F3E9
BAKCLR  EQU $F3EA
BDRCLR  EQU $F3EB
HTIMI   EQU $FD9F
RG1SAV  EQU $F3E0      ; copia do registrador 1 do VDP (a BIOS mantem)
; RAM (pagina 3): pagina zero do 2600 em $E000 (RAM do jogo em $E080), base de IX/IY em $E100
inSWCHA  EQU $E060
inSWCHB  EQU $E061
inINPT4  EQU $E062
inINTIM  EQU $E063
T_AUDC0  EQU $E068
T_AUDF0  EQU $E069
T_AUDV0  EQU $E06A
T_AUDC1  EQU $E06B
T_AUDF1  EQU $E06C
T_AUDV1  EQU $E06D
isrFrames EQU $E200
inOver   EQU $E201
isrOver  EQU $E202
rstCnt   EQU $E203
rnd      EQU $E204
lastFrame EQU $E205
seed     EQU $E206
tcol     EQU $E207
trow     EQU $E208
tcor     EQU $E209      ; byte de cor do bloco (tinta<<4 | papel)
tval     EQU $E20A
sndCur   EQU $E20B
pisca    EQU $E20C
tmp      EQU $E20D
Shadow   EQU $E210      ; 66 bytes
RAMFIM   EQU $E260
; cores (paleta do TMS9918)
FUNDO    EQU 4          ; azul escuro: fundo, borda e casas escuras
CLARA    EQU 5          ; azul claro: casas claras
TINTA_PC EQU 11         ; amarelo claro: computador
TINTA_EU EQU 15         ; branco: jogador
TIT_PAT  EQU $8000      ; titulo (padroes e cores do SCREEN 2)
TIT_COL  EQU $9800
ROM2600  EQU $B000      ; copia da ROM do Atari (tabelas lidas pela logica)

        ORG $4000
        DB "AB"
        DW Init
        DW 0, 0, 0
        DS 6, 0
Init:   ; a pagina 2 ($8000) passa a ser o proprio cartucho
        call RSLREG
        rrca
        rrca
        and 3
        ld c,a
        ld b,0
        ld hl,EXPTBL
        add hl,bc
        ld a,(hl)
        and $80
        or c
        ld c,a
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl)
        and $0C
        or c
        ld h,$80
        call ENASLT
        ; RAM do jogo zerada
        ld hl,$E000
        ld de,$E001
        ld bc,RAMFIM-$E000-1
        ld (hl),0
        ldir
        xor a
        ld (CLIKSW),a           ; sem o clique do teclado da BIOS
        ld a,15
        ld (FORCLR),a
        ld a,FUNDO
        ld (BAKCLR),a
        ld (BDRCLR),a
        call INIGRP             ; SCREEN 2, tabelas padrao
        call GICINI             ; PSG em silencio
        ; titulo direto na VRAM
        ld hl,TIT_PAT
        ld de,$0000
        ld bc,6144
        call LDIRVM
        ld hl,TIT_COL
        ld de,$2000
        ld bc,6144
        call LDIRVM
        ; gancho da interrupcao (60 ou 50 Hz, do VDP)
        di
        ld a,$C3
        ld (HTIMI),a
        ld hl,Isr
        ld (HTIMI+1),hl
        ld a,$C9
        ld (HTIMI+3),a
        ld (HTIMI+4),a
        ei
        call Titulo
        ; tela do jogo: tudo azul escuro
        ld hl,$0000
        ld bc,6144
        xor a
        call FILVRM
        ld hl,$2000
        ld bc,6144
        ld a,(FUNDO<<4)|FUNDO
        call FILVRM
        ld a,(seed)             ; o tempo de espera no titulo vira o contador
        ld (Z_D3),a             ; de quadros do Atari (a IA o usa p/ variar)
        or 1                    ; e a semente das cores do "pensando" (nunca 0)
        ld (rnd),a
        ld ix,$E100
        ld iy,$E100
        ld hl,Shadow
        ld de,Shadow+1
        ld bc,65
        ld (hl),$FF
        ldir
        ld a,$FF
        ld (sndCur),a
        ld a,2                  ; 2 quadros com o RESET apertado: monta o tabuleiro
        ld (rstCnt),a
        ld a,(isrFrames)
        ld (lastFrame),a
; ---------------- laco principal: um passo do 2600 por quadro ----------------
Main:   ld hl,isrFrames
        ld a,(lastFrame)
.w:     cp (hl)
        jr z,.w
        ld a,(hl)
        ld (lastFrame),a
        call Pausa
        call ReadKeys
        call LogicVbl           ; inicio do quadro do Atari (cursor e pisca escritos)
        call DrawBoard
        call DrawPanel
        ld a,(T_AUDC0)          ; som do inicio do quadro (silencio antes da busca)
        call Som
        ld a,1
        ld (inOver),a
        call LogicOver          ; joystick, regras e, as vezes, a busca da IA
        di
        xor a
        ld (inOver),a
        ld a,(isrOver)
        cp 2
        ld a,0
        ld (isrOver),a
        ei
        jr c,.nb                ; o Over foi curto: nada a desfazer
        ld a,FUNDO              ; fundo de volta ao azul
        ld b,7
        call VdpReg
        ld a,(RG1SAV)           ; e a imagem de volta
        ld b,1
        call VdpReg
.nb:
        ld a,(T_AUDC0)          ; cliques do fim do quadro
        call Som
        jr Main

; ---------------- interrupcao (H.TIMI): conta quadros; na busca, a tela inteira pisca ---
; Como no Atari, que embaralha a TV enquanto pensa: o VDP deixa de mostrar o tabuleiro
; (registrador 1, bit 6 = 0: so a cor de fundo) e a cor de fundo (registrador 7) e' sorteada.
Isr:    push af
        push hl
        ld hl,isrFrames
        inc (hl)
        ld a,(inOver)
        or a
        jr z,.fim
        ld hl,isrOver
        inc (hl)
        ld a,(hl)
        cp 2
        jr c,.fim
        jr nz,.cor
        ld a,(RG1SAV)           ; primeira vez: apaga a imagem (a tela vira so cor)
        and $BF
        out ($99),a
        ld a,$81
        out ($99),a
        jr .sort                ; e ja sorteia a primeira cor
.cor:   ld a,(hl)
        and 3
        jr nz,.fim              ; troca a cor a cada 4 quadros
.sort:  ld a,(rnd)
        add a,a
        jr nc,.r
        xor $1D
.r:     ld (rnd),a
        and 15
        cp 2                    ; sem 0 (transparente) e 1 (preto)
        jr c,.sort
        cp FUNDO
        jr z,.sort
        out ($99),a
        ld a,$87
        out ($99),a
.fim:   pop hl
        pop af
        ret

; VdpReg: escreve A no registrador B do VDP
VdpReg: di
        out ($99),a
        ld a,b
        or $80
        out ($99),a
        ei
        ret

; ---------------- pausa: H para, H de novo continua ----------------
Pausa:  call TeclaH
        ret nz
        ld a,$BF                ; som calado na pausa
        ld e,a
        ld a,7
        call WRTPSG
        ld a,$FF
        ld (sndCur),a
.s1:    call TeclaH
        jr z,.s1
.s2:    call TeclaH
        jr nz,.s2
.s3:    call TeclaH
        jr z,.s3
        ld a,(isrFrames)
        ld (lastFrame),a
        ret
TeclaH: ld a,3                  ; fileira 3: J I H G F E D C -> H = bit 5
        call SNSMAT
        bit 5,a
        ret

; ---------------- titulo: pisca APERTE UMA TECLA; a espera vira a semente -------
Titulo: call KILBUF
.t:     ld hl,seed
        inc (hl)
        ld a,(isrFrames)
        and 31
        jr nz,.k
        ld a,(isrFrames)        ; a cada 32 quadros troca a faixa da fileira 23
        ld hl,pisca
        cp (hl)
        jr z,.k
        ld (hl),a
        and 32
        jr z,.apaga
        ld hl,TIT_COL+23*256
        ld de,$2000+23*256
        ld bc,256
        call LDIRVM
        jr .k
.apaga: ld hl,$2000+23*256
        ld bc,256
        ld a,(FUNDO<<4)|FUNDO
        call FILVRM
.k:     call CHSNS
        jr nz,.fim
        ld a,1
        call GTTRIG
        or a
        jr z,.t
.fim:   call KILBUF
        ret

; ---------------- teclado e joystick -> joystick e chaves do console do 2600 -----
; I/K/J/L ou setas ou joystick 1 = direcoes; ESPACO ou gatilho = botao; 1 = SELECT; 2 = RESET
ReadKeys:
        ld a,$FF
        ld (tmp),a
        ld a,3                  ; J I H G F E D C
        call SNSMAT
        bit 6,a                 ; I = cima
        call z,Cima
        bit 7,a                 ; J = esquerda
        call z,Esq
        ld a,4                  ; R Q P O N M L K
        call SNSMAT
        bit 0,a                 ; K = baixo
        call z,Baixo
        bit 1,a                 ; L = direita
        call z,Dir
        ld a,8                  ; DIR BAIXO CIMA ESQ DEL INS HOME ESPACO
        call SNSMAT
        ld (tval),a
        bit 5,a
        call z,Cima
        ld a,(tval)
        bit 6,a
        call z,Baixo
        ld a,(tval)
        bit 4,a
        call z,Esq
        ld a,(tval)
        bit 7,a
        call z,Dir
        ld a,1                  ; joystick da porta 1: 1 = cima, 3 = direita, 5 = baixo, 7 = esquerda
        call GTSTCK
        or a
        jr z,.j
        ld c,a
        cp 2+1                  ; 8, 1, 2 = cima
        call c,Cima
        ld a,c
        cp 8
        call z,Cima
        ld a,c
        sub 2
        cp 3                    ; 2, 3, 4 = direita
        call c,Dir
        ld a,c
        sub 4
        cp 3                    ; 4, 5, 6 = baixo
        call c,Baixo
        ld a,c
        sub 6
        cp 3                    ; 6, 7, 8 = esquerda
        call c,Esq
.j:     ld a,(tmp)
        ld (inSWCHA),a
        ld b,$80                ; INPT4: bit 7 = 0 com o botao apertado
        ld a,(tval)
        bit 0,a
        jr nz,.t2
        ld b,0
.t2:    push bc
        ld a,1
        call GTTRIG
        pop bc
        or a
        jr z,.t3
        ld b,0
.t3:    ld a,b
        ld (inINPT4),a
        ld a,0                  ; fileira 0: 7 6 5 4 3 2 1 0
        call SNSMAT
        ld c,$3F                ; SWCHB solto
        bit 1,a                 ; 1 = GAME SELECT
        jr nz,.s
        res 1,c
.s:     bit 2,a                 ; 2 = GAME RESET
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
Cima:   ld hl,tmp
        res 4,(hl)
        ret
Baixo:  ld hl,tmp
        res 5,(hl)
        ret
Esq:    ld hl,tmp
        res 6,(hl)
        ret
Dir:    ld hl,tmp
        res 7,(hl)
        ret

; ---------------- som: cada AUDC do TIA vira uma combinacao do PSG -------------
; Tabela por AUDC: mixer, tom A (lo, hi), volume A, tom B (lo, hi), volume B, ruido
Som:    and $0F
        ld hl,sndCur
        cp (hl)
        ret z                   ; mesma voz: nao mexe (sem reiniciar a fase)
        ld (hl),a
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld de,SomTab
        add hl,de
        ld de,SomReg            ; DE = numeros dos registradores, HL = valores
        ld b,8
.r:     ld a,(de)
        push de
        ld e,(hl)
        push hl
        push bc
        call WRTPSG             ; A = registrador, E = valor
        pop bc
        pop hl
        pop de
        inc hl
        inc de
        djnz .r
        ret
SomReg: DB 7, 0, 1, 8, 2, 3, 9, 6
VOL     EQU 12
;   AUDF0 = $0F no Video Chess: pulsos do TIA a ~1965 Hz. Tom do PSG: TP = 111860 / f
SomTab: DB $BF, 0, 0, 0, 0, 0, 0, 0                         ; 0 silencio
        DB $BC, $56, 3, VOL, $AB, 1, VOL-2, 0                 ; 1 poly4: f0 = 131 Hz e 2 f0
        DB $BE, $EF, 6, VOL, 0, 0, 0, 0                       ; 2 zumbido de 63 Hz
        DB $BC, $56, 3, VOL, $AB, 1, VOL-2, 0                 ; 3 como o 1
        DB $BE, 114, 0, VOL, 0, 0, 0, 0                       ; 4 tom puro 982 Hz (clique do botao)
        DB $BE, 114, 0, VOL, 0, 0, 0, 0                       ; 5 idem
        DB $BE, $EF, 6, VOL, 0, 0, 0, 0                       ; 6 63 Hz
        DB $B6, $EF, 6, VOL, 0, 0, 0, 31                      ; 7 poly5: 63 Hz abrindo o ruido
        DB $B7, 0, 0, VOL, 0, 0, 0, 31                        ; 8 ruido
        DB $B6, $EF, 6, VOL, 0, 0, 0, 31                      ; 9 como o 7
        DB $BE, $EF, 6, VOL, 0, 0, 0, 0                       ; A 63 Hz
        DB $BF, 0, 0, 0, 0, 0, 0, 0                           ; B silencio
        DB $BE, $56, 1, VOL, 0, 0, 0, 0                       ; C tom 327 Hz
        DB $BE, $56, 1, VOL, 0, 0, 0, 0                       ; D idem
        DB $BE, $EF, 6, VOL, 0, 0, 0, 0                       ; E 63 Hz
        DB $B6, $EF, 6, VOL, 0, 0, 0, 31                      ; F cursor, buzina, "pronto": 63 Hz + ruido

; ---------------- desenho ----------------
DrawBoard:
        ld b,0
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
        ld c,a
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
        add a,d                 ; fileira = 3*linha
        ld d,a
        ld a,b
        rrca
        rrca
        rrca
        xor b
        and 1
        ld a,CLARA
        jr z,.cl
        ld a,FUNDO
.cl:    call DrawTile
        pop bc
.n:     inc b
        ld a,b
        cp 64
        jr nz,.l
        ret
DrawPanel:
        ld a,(Z_EE)             ; 0 = computador perdeu, 1 = jogador perdeu
        ld c,0
        or a
        jr nz,.p1
        ld c,7
.p1:    dec a
        jr nz,.p2
        ld c,$0F
.p2:    ld hl,Shadow+64
        ld a,c
        cp (hl)
        jr z,.p3
        ld (hl),a
        ld de,$0000
        ld a,FUNDO
        call DrawTile
.p3:    ld a,(Z_EA)             ; nivel 0-7 -> digito 1-8 (blocos 16-23)
        and 7
        add a,16
        ld hl,Shadow+65
        cp (hl)
        ret z
        ld (hl),a
        ld c,a
        ld de,$001D
        ld a,FUNDO
        jp DrawTile

; DrawTile: bloco C (0-23) em 3x3 caracteres na fileira D, coluna E, papel A
; No SCREEN 2 o caractere (f, c) tem padrao em f*256 + c*8 e cor em $2000 + f*256 + c*8.
DrawTile:
        ld b,a                  ; papel
        ld a,c
        ld (tval),a
        cp 16
        ld a,TINTA_EU
        jr nc,.ik               ; digitos: branco
        ld a,c
        cp 8
        ld a,TINTA_PC
        jr z,.ik                ; cursor X: cor do computador, como no Atari
        bit 3,c
        jr z,.ik
        ld a,TINTA_EU
.ik:    add a,a
        add a,a
        add a,a
        add a,a
        or b
        ld (tcor),a
        ld a,e
        ld (tcol),a
        ld a,d
        ld (trow),a
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
        ld c,0                  ; C = fileira dentro do bloco (0-2)
.fr:    ld b,0                  ; B = coluna dentro do bloco (0-2)
.cc:    push hl
        push bc
        ; endereco VRAM: (trow+C)*256 + (tcol+B)*8
        ld a,(tcol)
        add a,b
        add a,a
        add a,a
        add a,a
        ld e,a
        ld a,(trow)
        add a,c
        ld d,a
        ; fonte: Tiles + 72*v + 24*C + B, passo 3
        ld a,b
        add a,l
        ld l,a
        jr nc,.s1
        inc h
.s1:    di
        ld a,e
        out ($99),a
        ld a,d
        or $40
        out ($99),a
        ld b,8
.pt:    ld a,(hl)
        out ($98),a
        inc hl
        inc hl
        inc hl
        djnz .pt
        ld a,e                  ; cores
        out ($99),a
        ld a,d
        add a,$20
        or $40
        out ($99),a
        ld a,(tcor)
        ld b,8
.co:    out ($98),a
        nop
        nop
        nop
        djnz .co
        ei
        pop bc
        pop hl
        inc b
        ld a,b
        cp 3
        jr nz,.cc
        ld de,24                ; proxima fileira de caracteres do bloco
        add hl,de
        inc c
        ld a,c
        cp 3
        jr nz,.fr
        ret

; GetP: A = registrador P do 6502 (PHP + PLA) a partir das flags do Z80
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
        INCLUDE "logic_msx.asm"
        INCLUDE "../src/tiles.asm"
CodeEnd:
        ASSERT CodeEnd <= $8000
        ORG TIT_PAT
        INCBIN "../build/msx/titulo_pat.bin"
        ORG TIT_COL
        INCBIN "../build/msx/titulo_col.bin"
        ORG ROM2600
        INCBIN "../rom/Vidchess.bin"
        SAVEBIN "../build/msx/vchess.rom", $4000, $8000
