CFLAGS=-g -ggdb

all: ss base

ss.exe:
	cl ss.c

base.exe:
	cl base.c

clean: 
	rm -f ss ss.exe base base.exe

