make clean
z80asm -I../../lib -I../../libnabu -o temp.com ../../experiments/temp.asm --list=temp.lis
z80asm -I../../lib -I../../libnabu -o temp1.com ../../experiments/temp1.asm --list=temp1.lis

make C.DSK
make store
