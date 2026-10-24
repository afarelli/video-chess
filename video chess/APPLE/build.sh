#!/bin/sh
# Requer cc65 (ca65/ld65) e Python 3 com Pillow
python3 gen_tiles.py Vidchess.bin            # pecas da ROM -> tiles.inc
ca65 -l vcboard.lst vcboard.s && ld65 -C boot.cfg -o vcboard.bin vcboard.o
python3 mkdsk.py vcboard.bin VideoChessA2.dsk  # disco bootavel
