# Kit de ports GatinhuGames (Atari 2600 → Apple II, ZX Spectrum, MSX1)

Ferramentas e modelos do port do **Video Chess** (out/2026). Anexe este zip no começo de
cada conversa nova de port, junto com a ROM (.bin) do jogo. As ROMs comerciais **não** vão no kit.

## Montar o ambiente (no container do Claude)

O PyPI pode estar bloqueado; tudo abaixo vem do GitHub.

```
cd /home/claude
git clone --depth 1 https://github.com/cc65/cc65 && make -C cc65 -j8 bin          # Apple II (ca65/ld65)
git clone --depth 1 https://github.com/z00m128/sjasmplus && cd sjasmplus && git submodule update --init && make -j8 && cd ..
git clone --depth 1 https://github.com/mnaberez/py65                                # 6502 em Python (sys.path)
git clone --depth 1 https://github.com/skoolkid/skoolkit                            # ROM do 48K, tap2sna, snapshots
git clone --depth 1 https://github.com/kosarev/z80 z80src && cd z80src && python3 setup.py build_ext --inplace && cd ..
```

Os scripts esperam `/home/claude/py65`, `/home/claude/z80src` e `/home/claude/skoolkit`.
O `pip install z80` falha (PyPI e o `install_layout` do setuptools do Debian): use o `build_ext --inplace`.

## Pastas

| Pasta | O que tem |
|---|---|
| `comum/` | `dis6502.py` (disassembler do 2600), `atari_lite.py` (oráculo: 6502 + RIOT + WSYNC), `t65z80.py` + `op6502.py` (tradutor 6502→Z80, configurado por `jogo.json`), `zlogic.py` (roda a lógica traduzida), `closed.py` / `unit_test.py` / `search_diff.py` (validação contra o 6502), `fonte.py` (fonte 5×7 com Ã Í Ç), `make_tiles.py` (blocos 24×24 listrados) |
| `zx/` | `run_zx.py` (emulador de testes), `make_tap.py` (loader + SCREEN$ + blocos), `gera_titulo_zx.py`, `mock_cores.py`, `t_e3.py` |
| `msx/` | `run_msx.py` (z80 + VDP e PSG simples), `minibios.asm` (BIOS só de teste), `psg_wav.py` (WAV do log do PSG), `gera_titulo_msx.py`, `t_msx.py`, `t_msx_pensa.py` |
| `apple2/` | `gen_tiles.py` (HGR), `mkdos33.py` / `mkdsk.py` (discos), `apple_sim.py` + `testa_hgr_lib.py` (emulador de testes), `gera_titulo.py`, `t_mate.py` |
| `modelos/` | o Video Chess comentado (`vidchess.asm`, `Vidchess.sym`) e os programas finais de cada máquina, como ponto de partida |

## Configuração do tradutor (`rom/jogo.json`)

```
{"rom": "Jogo.bin", "nomes": "",
 "skip2": [], "decimal": [["FBA0", "FBA5"]], "frame_end": ["F00F"],
 "drop2": ["F45E"], "php_plp": {"FBBC": "FBF9"},
 "zp": "FA00", "rom2": "E000"}
```
Spectrum: `zp` FA00, `rom2` E000. MSX (cartucho): `zp` E000, `rom2` B000.
Rode com `T65CFG=rom/jogo_msx.json python3 tools/t65z80.py saida.asm Vbl:inicio:fim Over:inicio:fim`.
