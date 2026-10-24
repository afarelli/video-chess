; ===========================================================
; VIDEO CHESS - port Apple II, etapa 1: tabuleiro em HGR
; Boot direto do disco (sem DOS): o ROM da controladora le
; N setores da trilha 0 para $0800 e salta para $0801.
; Tabuleiro na MESMA codificacao do Atari (bits 0-2 tipo,
; bit 3 = peca do jogador) -> o motor encaixa sem traducao.
; ===========================================================
        .macpack longbranch
LEFT    = 4             ; 1a coluna (byte) do tabuleiro
BOARD   = $0300         ; 64 bytes, = RAM $80-$BF do Atari
SQ      = $E0           ; variaveis em pagina zero
ROW     = $E1
COL     = $E2
XOFF    = $E3
BLUE    = $E4
T       = $E5
BG0     = $E6
BG1     = $E7
YL      = $E8
L       = $E9
TI      = $EA
TMPY    = $EB
BGL     = $F0           ; fundo do 1o byte (sem o pixel colado na peca)
TP      = $EC           ; ponteiro do tile (2 bytes)
SP      = $EE           ; ponteiro da linha na tela (2 bytes)

        .segment "CODE"
        .byte <((FIM - $0800 + 255) / 256)   ; setores a carregar
START:  lda $C050       ; graficos
        lda $C052       ; tela cheia
        lda $C054       ; pagina 1
        lda $C057       ; alta resolucao
        lda #0          ; limpa HGR $2000-$3FFF
        sta SP
        tay
        ldx #$20
        stx SP+1
CLR:    sta (SP),y
        iny
        bne CLR
        inc SP+1
        ldx SP+1
        cpx #$40
        bne CLR
        jsr SETUP
        jsr DRAW
HANG:   jmp HANG

; --- monta a posicao inicial (igual $F2AD do Atari) ---
SETUP:  ldx #7
@l:     lda INIT,x
        sta BOARD,x             ; fileira do computador
        ora #$08
        sta BOARD+56,x          ; fileira do jogador
        lda #$46
        sta BOARD+8,x           ; peoes do computador
        lda #$8E
        sta BOARD+48,x          ; peoes do jogador
        lda #0
        sta BOARD+16,x
        sta BOARD+24,x
        sta BOARD+32,x
        sta BOARD+40,x
        dex
        bpl @l
        rts
INIT:   .byte 5,4,3,2,1,3,4,5   ; T C B D R B C T (ROM $FEF2)

; --- desenha as 64 casas ---
DRAW:   lda #0
        sta SQ
SQLOOP: lda SQ
        lsr
        lsr
        lsr
        sta ROW
        lda SQ
        and #7
        sta COL
        asl
        asl
        clc
        adc #LEFT
        sta XOFF
        lda ROW                 ; casa clara (azul) se linha+coluna par
        eor COL
        and #1
        eor #1
        sta BLUE
        ldx SQ
        lda BOARD,x
        and #7
        asl
        sta T
        lda BOARD,x
        and #8
        beq :+
        inc T                   ; peca do jogador = branca
:       lda T
        asl
        ora BLUE
        tax
        lda TILE_LO,x
        sta TP
        lda TILE_HI,x
        sta TP+1
        lda #$80                ; fundo preto
        sta BG0
        sta BG1
        sta BGL
        lda BLUE
        beq :+
        lda #$D5                ; 1o byte azul
        sta BGL
        lda #$D5                ; fundo azul (bytes pares/impares)
        sta BG0
        lda #$AA
        sta BG1
:       ldx ROW
        lda ROWY,x
        sta YL
        lda #0
        sta L
        sta TI
LLOOP:  ldx YL
        lda LINE_LO,x
        sta SP
        lda LINE_HI,x
        sta SP+1
        ldy XOFF
        lda BGL
        sta (SP),y
        iny
        lda L
        cmp #2
        bcc MARG
        cmp #20
        bcs MARG
        sty TMPY                ; 2 bytes do tile
        ldy TI
        lda (TP),y
        pha
        iny
        lda (TP),y
        tax
        iny
        sty TI
        ldy TMPY
        pla
        sta (SP),y
        iny
        txa
        sta (SP),y
        iny
        bne LAST
MARG:   lda BG1
        sta (SP),y
        iny
        lda BG0
        sta (SP),y
        iny
LAST:   lda BG1
        sta (SP),y
        inc YL
        inc L
        lda L
        cmp #22
        jne LLOOP
        inc SQ
        lda SQ
        cmp #64
        jne SQLOOP
        rts

        .include "tiles.inc"
FIM:
