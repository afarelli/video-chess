# ♟️ Video Chess — do Atari 2600 para Apple II, ZX Spectrum e MSX1

> **GatinhuGames + Claude AI** · 2026
> O *Video Chess* (Atari, 1979) rodando em três micros clássicos, com o motor de xadrez **original** da ROM do 2600. Não é uma recriação.

```
   /\_/\      VIDEO CHESS
  ( o.o )     Atari 2600 → Apple II · ZX Spectrum · MSX1
   > ^ <      GatinhuGames
```

---

## ✨ O que tem aqui

| Máquina | Formato | Como o motor roda | Testado em |
|---|---|---|---|
| **Apple II** (//e, II+ com 64K, TK3000) | disco DOS 3.3 (`.dsk`) | A ROM original roda **hospedada**: o 6507 do Atari é um 6502 | AppleWin, Apple II+ real, TK3000 |
| **ZX Spectrum 48K / TK90X** | fita (`.tap`) | Lógica **traduzida automaticamente** de 6502 para Z80 e validada contra a ROM | Fuse 48K e 128K, ESPectrum (TK90X) |
| **MSX1** | cartucho de 32 KB (`.rom`) | A mesma lógica traduzida, com outros endereços | Emulador de testes próprio; validação em openMSX, blueMSX ou WebMSX |

Nas três versões:
- a **IA, as regras e os níveis** são os do cartucho de 1979;
- o tabuleiro e as peças saem da própria ROM, ampliados e com listras horizontais;
- os textos estão em **português**, em maiúsculas (com Ã, Í, Ç);
- a tela de apresentação traz o mascote da GatinhuGames (o gato arco-íris 🌈🐱);
- **enquanto o computador pensa, a tela pisca colorida**, como no Atari.

### 🎮 Controles (iguais nas três máquinas)

| Tecla | Função |
|---|---|
| **I / K / J / L** | cursor: cima, baixo, esquerda, direita (setas e joystick também funcionam) |
| **ESPAÇO** | pegar e soltar a peça (o botão do joystick) |
| **1** | nível de dificuldade (GAME SELECT) |
| **2** | nova partida (GAME RESET) |
| **H** | pausa (Spectrum e MSX) |

---

## 🍎 Apple II: a ROM original hospedada

O Apple II tem a mesma CPU do Atari, então o jogo **não foi traduzido**. A ROM inteira de 4 KB é copiada para a RAM da *language card* em `$F000`, onde todos os saltos continuam valendo. Um "host" pequeno cuida do resto:

- **Entradas:** `SWCHA`, `SWCHB` e `INTIM` ficam na RAM. O host escreve ali o que o jogo espera ler, e `INTIM = 0` desliga as esperas do timer.
- **Remendos mínimos:** um `JSR TICK` em `$F0F2`, o ponto em que o quadro está pronto para o kernel desenhar, além de sombras para os cliques de som e um gancho na busca para o efeito de "pensando".
- **Vídeo HGR:** redesenho só das casas que mudaram (sombra de 64 bytes) e peças geradas em Python respeitando as regras de cor do NTSC. O fundo é preto, as casas claras azuis e as peças laranja e brancas.
- **Pisca-cores:** troca para a página 2 da HGR com faixas de cores sorteadas, com custo de ~7 % na busca.
- **Som:** um "TIA de 1 bit" no alto-falante. Uma tabela por AUDC escolhe entre onda quadrada e LFSR de 4, 5 ou 8 bits.
- **Disco:** DOS 3.3 com tela de título de 8 KB carregada direto na página 2. Para jogar: `BRUN VCHESS,D2`.

## 🌈 ZX Spectrum 48K / TK90X: tradução 6502 → Z80

Aqui a CPU é outra, então a lógica do jogo foi **traduzida instrução por instrução** por um tradutor automático (`t65z80.py`), sem reescrever o motor à mão.

- **Unidades traduzidas:** `LogicVbl` (`$F00F-$F0F2`) e `LogicOver` (`$F27B-$F2A2`). O kernel de vídeo do Atari fica de fora.
- **Validação em três níveis:**
  1. `unit_test.py`: cada sub-rotina da busca, comparada com um 6502 emulado (py65);
  2. `search_diff.py`: a busca inteira, comparada instrução a instrução;
  3. `closed.py`: a partida inteira, quadro a quadro.

  **Resultado: 5.577 quadros e 3 buscas sem nenhuma diferença.** Foi assim que apareceu um bug sutil do tradutor (`BVC` apagando a flag S), que mudava o tempo de pensar.
- **Tabuleiro:** casas de 3×3 caracteres, 24 px cada, que fecham as 192 linhas da tela. Uma peça por casa = uma tinta e um papel por célula, sem *color clash*.
- **Paleta B, os "azuis do Atari":** fundo e casas escuras em azul, casas claras em azul brilhante, peças amarelas (computador) e brancas (jogador).
- **Pensando:** a borda pisca em cores sorteadas.
- **Som:** o mesmo "TIA de 1 bit" do Apple II, agora no beeper.
- **Fita:** tela de carregamento (`LOAD "" SCREEN$`) com o gato e a lista de comandos. O tempo que você leva para apertar a tecla vira a semente da IA, então as aberturas variam.

## 🎨 MSX1: cartucho de 32 KB

É a versão mais parecida com o Atari. A lógica é a mesma do Spectrum, traduzida para outros endereços: só muda um arquivo JSON.

- **Cartucho "AB"** com a página 2 ligada por `ENASLT`. Usa só 8 KB de RAM, então roda em qualquer MSX1.
- **SCREEN 2 (TMS9918):** até 2 cores a cada 8×1 pixels. Os dois azuis do TMS ficam bem perto dos do Atari.
- **Pensando:** **a tela inteira pisca colorida**, como no 2600. O programa desliga a imagem e sorteia a cor de fundo a cada 4 quadros, sem tocar na VRAM.
- **Som no PSG (AY-3-8910):** uma tabela por tipo de voz do TIA, ajustada de ouvido.
- **Entrada:** teclado pela BIOS (`SNSMAT`) e joystick na porta 1.

---

## 🧰 O kit de ferramentas (`kit_ports_gatinhu/`)

```
kit_ports_gatinhu/
├── LEIAME.md          ← ambiente e comandos de build
├── comum/             ← o coração do método
│   ├── dis6502.py       disassembler 6502 (recursive descent)
│   ├── op6502.py        tabela de opcodes
│   ├── atari_lite.py    "Atari de bolso": oráculo 6502 + RIOT + TIA de mentira
│   ├── t65z80.py        tradutor 6502 → Z80 (configurado por jogo.json)
│   ├── zlogic.py        roda a lógica traduzida no Z80 emulado
│   ├── unit_test.py     sub-rotinas × 6502
│   ├── search_diff.py   busca inteira, instrução a instrução
│   ├── closed.py        malha fechada quadro a quadro
│   ├── make_tiles.py    peças da ROM → blocos de 24×24 px
│   └── fonte.py         fonte 5×7 maiúscula com acentos
├── apple2/            ← simulador do Apple, discos DOS 3.3, título HGR
├── zx/                ← emulador de testes, TAP, título SCREEN$, prévias de paleta
├── msx/               ← mini-BIOS, emulador de testes, título SCREEN 2, WAV do PSG
└── modelos/           ← o Video Chess completo, como exemplo
    ├── vidchess.asm     disassembly comentado da ROM
    ├── Vidchess.sym     símbolos para o debugger do Stella
    ├── videochess_apple2/
    ├── videochess_zx/
    └── videochess_msx/
```

**Ambiente** (Linux, com o PyPI bloqueado, clonando do GitHub): `cc65`, `sjasmplus` (com `git submodule update --init`), `py65`, `skoolkit` e `z80` (compilado com `python3 setup.py build_ext --inplace`), mais o Pillow. Os comandos completos estão no `LEIAME.md` do kit.

---

## 🤖 Como usar as ferramentas em novos chats com o Claude

O método virou **três skills**, guardadas na minha conta do Claude e carregadas sozinhas quando o assunto aparece:

| Skill | Para quê |
|---|---|
| `atari2600-apple2-port` | destinos 6502: hospedar a ROM original |
| `atari2600-zx-port` | ZX Spectrum: tradução 6502→Z80, validação, beeper/AY, TAP |
| `atari2600-msx-port` | MSX1: cartucho, SCREEN 2, PSG, BIOS |

### Passo a passo (um chat por jogo)

1. **Abra um chat novo e anexe:**
   - o `kit_ports_gatinhu.zip`;
   - a ROM do jogo (`.bin`);
   - para jogos de **ação**, também o `kk_port_final.zip` (o kit do Keystone Kapers, com modelo do kernel e colisões).
2. **Diga o jogo e a máquina:**
   > *"Vamos portar o Freeway do Atari 2600 para MSX1."*

   A skill certa entra sozinha. Para garantir, peça pelo nome: *"use a skill atari2600-msx-port"*.
3. **Trabalhe em etapas curtas:** mapear a ROM (com o debugger do **Stella** aberto ao lado) → tabuleiro ou tela → movimento → lógica → som → tela de apresentação. Cada etapa termina com algo jogável e um **zip do projeto**.
4. **Chat ficou comprido?** Abra outro e anexe o kit + o último zip do projeto. Dá para continuar exatamente dali.
5. **Mesmo jogo em outra máquina?** Anexe o zip do port já pronto: no Spectrum e no MSX, a lógica traduzida e os testes servem quase inteiros.
6. **Aprendeu um truque novo?** Peça *"atualiza a skill com isso"*, e o método melhora a cada jogo.

---

## ⚖️ Aviso legal

*Video Chess* © 1979 Atari, Inc. Os ports **embutem a ROM original** e são um projeto de preservação e estudo **para uso pessoal**. **Este repositório não distribui ROMs nem imagens com a ROM embutida:** use a sua própria cópia do cartucho. As ferramentas e o código do host/port são da GatinhuGames.

## 💛 Créditos

- **Jogo original:** Atari, 1979
- **Ports, ferramentas e método:** GatinhuGames (Professor Daniel) + Claude AI (Anthropic)
- **Base do método Spectrum:** os ports de Seaquest, MegaMania, Pole Position, Enduro e Keystone Kapers feitos por um amigo portador de Spectrum
- **Ferramentas de terceiros:** cc65, sjasmplus, py65, skoolkit, z80 (kosarev), Stella, AppleWin, Fuse, ESPectrum
