# Video Chess — port para ZX Spectrum 48K / TK90X (etapa 2)

Port do Video Chess (Atari, 1979) com o **motor original traduzido automaticamente de 6502 para Z80**
(`tools/t65z80.py`, adaptado do kit do Keystone Kapers). Só a tela, o teclado e (depois) o som são do Spectrum.
ROM do Atari embutida: uso pessoal.

## Como jogar (`build/vchess_e2.tap`)

| Tecla | Função |
|---|---|
| I / K / J / L | cima / baixo / esquerda / direita (segure para andar, como o joystick) |
| ESPAÇO | botão: pega e solta a peça |
| 1 | GAME SELECT: troca o nível (1 a 8) |
| 2 | GAME RESET: nova partida |

A borda pisca em cores enquanto o computador pensa. Quando a peça dele estiver piscando entre a
origem e o destino, comece o seu lance que ela se assenta (comportamento do original).

## Como montar

```
python3 tools/t65z80.py src/logic_gen.asm LogicVbl:F00F:F0F2 LogicOver:F27B:F2A2   # lógica (rom/jogo.json)
python3 tools/make_tiles.py                                                       # src/tiles.asm
cd src && sjasmplus --sym=../build/vchess.sym main.asm && cd ..
python3 tools/make_tap.py build/vchess_e2.tap
```

## Mapa de memória

| Endereço | Conteúdo |
|---|---|
| $8000 | código (main, lógica traduzida, blocos das peças) — bloco `vchess` |
| $E000-$EFFF | cópia da ROM do 2600 (tabelas) — bloco `rom2600` |
| $FA00-$FAFF | página zero do 2600 ($80-$FF em $FA80), entradas e sombras do TIA ($FA60-$FA6D) |
| $FB00 | base de IX/IY (X = IXL, Y = IYL) |
| $FDF0 | pilha; $FDFD JP Isr; $FE00-$FF00 tabela da IM 2 |

## Verificação

- `tools/unit_test.py`: 11 sub-rotinas da busca × estados reais contra o 6502 (py65).
- `tools/search_diff.py`: a busca inteira, instrução a instrução, contra o 6502.
- `tools/closed.py lances...`: a partida no 6502 (ROM original) e no Z80, quadro a quadro.
- `tools/t_e2.py`: o TAP no emulador de testes (z80 + ROM 48K), lance pelo teclado, PNG e GIF.
- `skoolkit/tap2sna.py -s 32768 build/vchess_e2.tap`: carga do TAP com a ROM real.
