
TOP=../..
# case here has to match the directory name
PROGS=invaders.com

include Make.rules

.PHONY: all

# make 'all' be the default build target...
all:: $(PROGS)

%.com: $(TOP)/src/main.asm
	z80asm $(ASMFLAGS) --list=$@.lis -L$@.sym -o $@ $^

clean::
	rm -f *.com *.lis

