.PHONY: all clean

all: clean
	z80asm -Ilib -Iinclude -o invaders.com --list=invaders.lis --label=invaders.sym main.asm
	mkfs.cpm -f naburn c.dsk
	cpmcp -f naburn c.dsk invaders.com 0:invaders.com
	cp c.dsk "/mnt/c/dev/nabu/Nabu Internet Adapter/Store/"

retro: clean
	z80asm -Ilib -Iinclude -o invaders.com --list=invaders.lis --label=invaders.sym main.asm
	mkfs.cpm -f naburn c.dsk
	cpmcp -f naburn c.dsk invaders.com 0:invaders.com
	scp invaders.com davelatham@192.168.0.230:~/dev/retro/
clean:
	rm -f invaders.com c.dsk invaders.lst invaders.sym invaders.lis