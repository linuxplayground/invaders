
TOP=../..
# case here has to match the directory name
PROGS=invaders.com

include Make.rules

.PHONY: all

# make 'all' be the default build target...
all:: $(PROGS)

%.com: $(TOP)/src/main.asm
	z80asm $(ASMFLAGS) --list=$@.lis -L$@.sym -o $@ $^

C.DSK:: $(PROGS)
	rm -f $@
	LC_CTYPE=C tr '\0' '\345' < /dev/zero | dd of=$@ bs=8M count=1 conv=fsync iflag=fullblock
	cpmcp -f $(DISKDEF) $@ *.com 0:
	cpmls -f $(DISKDEF) $@

store: C.DSK
	cp $^ $(STOREDIR)

clean::
	rm -f *.com *.lis c.dsk

