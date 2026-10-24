; ===========================================================
; VIDEO CHESS para Apple II (64K)  -  etapa 3: MOTOR ORIGINAL
; O codigo do Atari 2600 roda INTEIRO, sem relocar, na RAM da
; language card em $F000-$FFFF. O Apple so faz:
;   - entrada: teclado -> "joystick" ($0280) e "botao" ($3C)
;   - video:   copia o tabuleiro do Atari ($80-$BF) p/ a HGR
; Toda a logica (cursor, pisca, regras, IA) e' a de 1979.
; ===========================================================
        .macpack longbranch
LEFT    = 4
BOARD   = $80           ; o tabuleiro do Atari, na pagina zero
SWCHA   = $0280         ; "joystick" do Atari (cai em RAM no Apple)
SWCHB   = $0282         ; chaves do console
INTIM   = $0284         ; timer: deixamos sempre 0 (sem espera)
INPT4   = $3C           ; botao (o jogo le com LDA $3C)
F3_EST  = $F3           ; estado do jogo (descoberto no Stella)
F4_TMP  = $F4           ; contador que bloqueia o botao
; --- variaveis do Apple em $40-$5F (o Atari nunca toca nessa faixa)
SQ      = $40
ROW     = $41
COL     = $42
XOFF    = $43
BLUE    = $44
T       = $45
BG0     = $46
BG1     = $47
YL      = $48
L       = $49
TI      = $4A
TMPY    = $4B
TP      = $4C           ; ponteiro tile
SP      = $4E           ; ponteiro linha
CONT    = $50
DI      = $51
JOYDIR  = $52           ; direcao segurada
JOYCNT  = $53           ; quadros restantes segurando
BTNCNT  = $54           ; quadros de botao pendentes
RSTCNT  = $55           ; quadros de RESET
CURS4   = $56           ; $D4 e $D5 no momento da tecla
CURS5   = $57
SNDN    = $58           ; som: ticks restantes
SDIV    = $59           ; divisor de frequencia (recarga)
SCNT    = $5A           ; contador do divisor
SMODE   = $5B           ; 1 = onda quadrada, 2-4 = polinomio (ruido)
SPOLY   = $5C           ; registrador de deslocamento (LFSR)
SOUT    = $5D           ; ultimo nivel do alto-falante
CLICK   = $5F
CANTO   = $5E           ; o que esta desenhado no canto (rei tombado)
NIVEL   = $5F+1         ; nivel desenhado no canto direito ($60)
SELCNT  = $61           ; quadros com o "Game Select" apertado
HCNT    = $62           ; pisca-cores: chamadas ate a proxima faixa
HC0     = $63           ; cor sorteada (byte par / impar)
HC1     = $64
HBAND   = $65           ; faixa atual (0-23)
HLIN    = $66
HN      = $67
RNDV    = $68           ; gerador aleatorio (LFSR de 8 bits)
HLOOP   = $69
HRATE   = 4             ; ~16 faixas por segundo durante a busca           ; cliques que o Atari mandava p/ AUDC0
AUDC0   = $15           ; registrador de som da TIA (cai na pag. zero)
SPKR    = $C030
DLY     = 88            ; ajusta o "relogio" da TIA: ~1962 Hz no Apple
SHADOW  = $0300         ; copia do que esta na tela (64 bytes)
HOLD    = 60            ; segura a seta ate o cursor andar (max ~1 s)

        .segment "CODE"
; O arquivo e' carregado em $3FFD: um JMP (nos "buracos" da pagina 1,
; que nao aparecem na tela) e logo depois a TELA DE TITULO, que cai
; exatamente na pagina 2 da HGR ($4000-$5FFF). O codigo comeca em $6000.
        jmp START
        .incbin "titulo.hgr"
START:  sei
        cld
        lda $C050               ; mostra o titulo ja enquanto prepara tudo
        lda $C052
        lda $C055
        lda $C057
        lda $C083               ; language card: le e escreve RAM
        lda $C083
        lda #<ROMIMG            ; copia a ROM do Atari para $F000
        sta TP
        lda #>ROMIMG
        sta TP+1
        lda #0
        sta SP
        lda #$F0
        sta SP+1
        ldy #0
@cp:    lda (TP),y
        sta (SP),y
        iny
        bne @cp
        inc TP+1
        inc SP+1
        bne @cp                 ; ate $FFFF -> volta p/ $00
        ; remendo: no $F0F2 o Atari esperava o timer antes de desenhar
        ; a tela (LDX INTIM / BNE). E' o momento em que o tabuleiro tem
        ; o cursor e o pisca aplicados -> trocamos por JSR TICK + 2 NOPs
        ldx #4
@pt:    lda PATCH,x
        sta $F0F2,x
        dex
        bpl @pt
        lda #CLICK              ; cliques do botao/joystick e o "pronto" do
        sta $F1E7               ; computador ($F1E6 STA e $FA36 STX AUDC0)
        sta $FA37               ; vao para CLICK, p/ nao se perderem
        lda #1
        sta SPOLY
        ldx #3                  ; 2o remendo: $F5DB (inicio da varredura de
@p2:    lda PATCH2,x            ; pecas de um no' da busca, ~65x por segundo)
        sta $F5DB,x             ; chama o pisca-cores
        dex
        bpl @p2
        lda #HRATE
        sta HCNT
        lda #$5A
        sta RNDV
        ; fundo preto (casas escuras = fundo, como no Atari)
        lda #$80
        ldx #$20
        stx SP+1
        ldy #0
        sty SP
@clr:   sta (SP),y
        iny
        bne @clr
        inc SP+1
        ldx SP+1
        cpx #$40
        bne @clr
        jsr TITULO              ; espera uma tecla (pisca o APERTE UMA TECLA)
        lda #24                 ; agora a pagina 2 vira a das cores do "pensando"
        sta HLOOP
@f2:    jsr BANDA
        dec HLOOP
        bne @f2
        bit $C054               ; mostra o tabuleiro
        ; entradas do Atari "soltas"
        lda #$FF
        sta SWCHA
        lda #$3F
        sta SWCHB
        lda #$80
        sta INPT4
        lda #0
        sta INTIM
        sta JOYCNT
        sta BTNCNT
        sta RSTCNT
        lda #$00
        sta CANTO
        sta SELCNT
        lda #$FF
        sta NIVEL
        ldx #63                 ; forca redesenhar tudo
        lda #$FF
@sh:    sta SHADOW,x
        dex
        bpl @sh
        ; = RESET do Atari ($F000), sem apagar $00-$7F
        ldx #$FF
        txs
        lda #0
        ldx #$80
@z:     sta $00,x
        inx
        bne @z
        lda RNDV                ; semente: o tempo que voce levou p/ apertar
        sta $D3                 ; a tecla vira o contador de quadros do Atari
        lda #0                  ; (a IA usa $D3 p/ variar as aberturas)
        jsr $F2AD               ; monta o tabuleiro (com A=0)
        jmp $F00F               ; e entra no laco de quadros do Atari

; ===== chamado a cada quadro, logo antes do Atari desenhar a tela =====
TICK:   bit $C054               ; volta a mostrar o tabuleiro (pagina 1)
        lda CLICK                ; som: clique pendente (curto)
        beq @c
        ldy #20                 ; ~10 ms
        jsr SOUND
        lda #0
        sta CLICK
@c:     lda AUDC0               ; som continuo (xeque, mate, erro)
        ldy #24
        jsr SOUND
        lda $C000
        bpl NOKEY
        sta $C010
        jsr KEY
NOKEY:  lda JOYCNT              ; joystick
        beq @rel
        lda $D4                 ; o cursor ja andou? entao solta
        cmp CURS4
        bne @stop
        lda $D5
        cmp CURS5
        beq @hold
@stop:  lda #0
        sta JOYCNT
        beq @rel
@hold:  dec JOYCNT
        lda JOYDIR
        bne @set
@rel:   lda #$FF
@set:   sta SWCHA
        lda #$80                ; botao: so aperta quando o jogo escuta
        ldx BTNCNT
        beq @b
        ldx F4_TMP
        bne @b
        dec BTNCNT
        lda #$00
@b:     sta INPT4
        lda #$3F                ; RESET do console
        ldx RSTCNT
        beq @r
        dec RSTCNT
        lda #$3E
@r:     ldx SELCNT          ; tecla 1: segura o "Game Select" (bit 1)
        beq @s
        dec SELCNT
        and #$FD
@s:     sta SWCHB
        ldx #63                 ; redesenha as casas que mudaram
@d:     lda BOARD,x
        cmp SHADOW,x
        beq @n
        sta SHADOW,x
        stx DI
        jsr DRAWSQ
        ldx DI
@n:     dex
        bpl @d
        ; --- rei tombado no canto: o Atari usa $EE (0 = computador
        ; levou mate, 1 = jogador levou mate, 3 = jogo em andamento)
        ; e desenha o grafico $FF38 (tipo 7) na cor do perdedor
        lda #$00                ; nada
        ldx $EE
        beq @pc
        dex
        bne @cv
        lda #$0F                ; tipo 7 + bit 3: rei tombado BRANCO
        bne @cv
@pc:    lda #$07                ; tipo 7: rei tombado LARANJA
@cv:    cmp CANTO
        beq @ok
        sta CANTO
        sta CONT
        lda #0                  ; canto superior esquerdo, fundo preto
        sta XOFF
        sta BLUE
        lda ROWY
        sta YL
        jsr DRAWAT
@ok:    lda $EA                 ; --- nivel: o Atari guarda 0-7 em $EA
        cmp NIVEL
        beq @fim
        sta NIVEL
        asl                     ; tile = (16 + nivel)*2
        clc
        adc #32
        pha
        lda #36                 ; canto superior direito (bytes 36-39)
        sta XOFF
        lda ROWY
        sta YL
        lda #0
        sta BLUE
        jsr BGSET
        pla
        tax
        jsr DRAWIX
@fim:   ldx #0                  ; o Atari espera X=0 (valor do timer)
        rts

PATCH:  jsr TICK
        nop
        nop
PATCH2: jsr HOOK
        nop

; ===== pisca-cores: chamado em $F5DB (no lugar de LDA #$40 / STA $D4) =====
; Enquanto o computador pensa ($F3 = $C0), mostra a pagina 2 da HGR
; e vai repintando faixas dela com cores sorteadas. Quando a busca
; acaba, o proximo TICK volta para a pagina 1: nada a redesenhar.
HOOK:   txa                     ; preserva X e Y
        pha
        tya
        pha
        lda F3_EST
        cmp #$C0
        bne @x
        dec HCNT
        bne @x
        lda #HRATE
        sta HCNT
        bit $C055               ; mostra a pagina 2
        jsr BANDA
@x:     pla
        tay
        pla
        tax
        lda #$40                ; as instrucoes originais
        sta $D4
        rts

BANDA:  jsr RND                 ; sorteia uma das 6 cores do HGR
        and #7
        cmp #6
        bcc :+
        sbc #3
:       tax
        lda COLE,x
        sta HC0
        lda COLO,x
        sta HC1
        lda HBAND               ; proxima faixa: +7 (mod 24) parece aleatorio
        clc
        adc #7
        cmp #24
        bcc :+
        sbc #24
:       sta HBAND
        asl
        asl
        asl
        sta HLIN
        lda #8
        sta HN
@l:     ldx HLIN
        lda LINE_LO,x
        sta SP
        lda LINE_HI,x
        clc
        adc #$20                ; pagina 2 = pagina 1 + $2000
        sta SP+1
        ldy #39
@b:     lda HC1
        sta (SP),y
        dey
        lda HC0
        sta (SP),y
        dey
        bpl @b
        inc HLIN
        dec HN
        bne @l
        rts

; ===== tela de titulo: pisca o APERTE UMA TECLA ate apertar algo =====
TITULO: sta $C010
@lp:    lda HLOOP               ; HLOOP: 1 = texto aceso, 0 = apagado
        eor #1
        sta HLOOP
        lda #<BLINKDATA
        sta TP
        lda #>BLINKDATA
        sta TP+1
        lda #BLINK_Y
        sta HLIN
        lda #10
        sta HN
@ln:    ldx HLIN
        lda LINE_LO,x
        sta SP
        lda LINE_HI,x
        clc
        adc #$20                ; pagina 2
        sta SP+1
        ldy #39
@by:    lda #0
        ldx HLOOP
        beq :+
        lda (TP),y
:       sta (SP),y
        dey
        bpl @by
        lda TP
        clc
        adc #40
        sta TP
        bcc :+
        inc TP+1
:       inc HLIN
        dec HN
        bne @ln
        ldy #$90                ; ~0,4 s olhando o teclado
@w1:    ldx #0
@w2:    inc RNDV                ; gira a semente enquanto espera
        bne :+
        inc RNDV
:       lda $C000
        bmi @tecla
        dex
        bne @w2
        dey
        bne @w1
        jmp @lp
@tecla: sta $C010
        rts

RND:    lda RNDV
        lsr
        bcc :+
        eor #$B8
:       sta RNDV
        rts
;            preto violeta verde azul laranja branco
COLE:   .byte $00, $55,   $2A,  $D5, $AA,    $FF
COLO:   .byte $00, $2A,   $55,  $AA, $D5,    $FF

KEY:    cmp #$B1                ; 1 = escolhe o nivel (Game Select)
        beq @sel
        cmp #$B2                ; 2 = inicia/reinicia (Game Reset)
        beq @rst
        cmp #$A0                ; espaco/RETURN = botao
        beq @btn
        cmp #$8D
        beq @btn
        and #$DF
        cmp #$D2                ; R = novo jogo (Reset do console)
        beq @rst
        ldx #3
@k:     cmp KEYTAB,x
        beq @mv
        cmp KEYALT,x
        beq @mv
        dex
        bpl @k
        rts
@mv:    lda JOYVAL,x
        sta JOYDIR
        lda $D4
        sta CURS4
        lda $D5
        sta CURS5
        lda #HOLD
        sta JOYCNT
        rts
@btn:   lda #3
        sta BTNCNT
        rts
@rst:   lda #6
        sta RSTCNT
        rts
@sel:   lda #2                  ; 2 quadros = 1 passo de nivel
        sta SELCNT
        rts
; ===== "TIA de 1 bit": toca A = AUDC0 (tipo de som) por Y ticks =====
; Com AUDF0 = $0F (fixo no Video Chess) a TIA "bate" a ~1962 Hz.
; Quadrada: alterna a cada SDIV batidas. Polinomio: o bit de saida
; de um LFSR de 4, 5 ou 8 bits (os "ruidos" e zumbidos do Atari).
SOUND:  and #$0F
        tax
        lda SMODE_T,x
        beq @fim                ; 0 = silencio
        sta SMODE
        lda SDIV_T,x
        sta SDIV
        sta SCNT
        sty SNDN
@tick:  dec SCNT
        bne @esp
        lda SDIV
        sta SCNT
        ldx SMODE
        cpx #1
        bne @poly
        lda SOUT                ; onda quadrada
        eor #1
        jmp @sai
@poly:  lda SPOLY               ; LFSR de Galois
        lsr
        bcc :+
        eor PTAP,x
:       sta SPOLY
        and #1
@sai:   cmp SOUT
        beq @esp
        sta SOUT
        bit SPKR                ; clique no alto-falante
@esp:   ldx #DLY
:       dex
        bne :-
        dec SNDN
        bne @tick
@fim:   rts
;              AUDC0:  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
SMODE_T: .byte         0, 2, 2, 2, 1, 1, 1, 3, 4, 3, 1, 0, 1, 1, 1, 3
SDIV_T:  .byte         1, 1,15, 1, 1, 1,15, 1, 1, 1,15, 1, 3, 3,46, 3
PTAP:    .byte 0, 0, $0C, $14, $B8   ; taps: 4 bits, 5 bits, 8 bits

KEYTAB: .byte $8B,$8A,$88,$95   ; cima, baixo, esquerda, direita
KEYALT: .byte $C9,$CB,$CA,$CC   ; I K J L
JOYVAL: .byte $EF,$DF,$BF,$7F   ; bits do SWCHA do Atari

; --- desenha UMA casa: X = casa (0-63), A = byte do tabuleiro Atari ---
DRAWSQ: stx SQ
        sta CONT
        txa
        lsr
        lsr
        lsr
        sta ROW
        txa
        and #7
        sta COL
        asl
        asl
        clc
        adc #LEFT
        sta XOFF
        lda ROW
        eor COL
        and #1
        eor #1
        sta BLUE
        ldx ROW
        lda ROWY,x
        sta YL
; entrada alternativa: XOFF, YL, BLUE e CONT ja preenchidos
DRAWAT: lda CONT                ; indice = (tipo*2 + jogador)*2 + azul
        and #$0F
        asl
        ora BLUE
        tax
; entrada direta: X = indice do tile (valor*2 + azul)
        jsr BGSET
DRAWIX: lda TILE_LO,x
        sta TP
        lda TILE_HI,x
        sta TP+1
        jmp DRAWT
BGSET:  lda #$80                ; cor de fundo conforme BLUE
        sta BG0
        sta BG1
        lda BLUE
        beq :+
        lda #$D5
        sta BG0
        lda #$AA
        sta BG1
:       rts
DRAWT:  lda #0
        sta L
        sta TI
@ll:    lda #$80                ; fundo preto; casa clara = azul cheio
        sta BG0
        sta BG1
        lda BLUE                ; casa escura = preto (como o fundo)
        beq @pr
        lda #$D5
        sta BG0
        lda #$AA
        sta BG1
@pr:    ldx YL
        lda LINE_LO,x
        sta SP
        lda LINE_HI,x
        sta SP+1
        ldy XOFF
        lda BG0
        sta (SP),y
        iny
        lda L
        cmp #2
        bcc @mg
        cmp #20
        bcs @mg
        sty TMPY
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
        bne @lst
@mg:    lda BG1
        sta (SP),y
        iny
        lda BG0
        sta (SP),y
        iny
@lst:   lda BG1
        sta (SP),y
        inc YL
        inc L
        lda L
        cmp #22
        jne @ll
        rts

        .include "tiles.inc"
        .include "pisca.inc"
ROMIMG: .incbin "Vidchess.bin"
