CC = gcc -ansi -pedantic
CFLAGS = -g -Wall
OBJECTS = lex.yy.o y.tab.o compilador.o tablahash.o generacion.o

all: $(OBJECTS)
	$(CC) $(CFLAGS) -o final $(OBJECTS)

lex.yy.c: alfa.l
	flex alfa.l

lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) -c lex.yy.c

y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -c y.tab.c

y.tab.h: alfa.y
	bison -d -y -v alfa.y

compilador.o: compilador.c y.tab.h
	$(CC) $(CFLAGS) -c compilador.c

tablahash.o: tablahash.c tablahash.h
	$(CC) $(CFLAGS) -c tablahash.c

generacion.o: generacion.c generacion.h
	$(CC) $(CFLAGS) -c generacion.c

clean:
	rm -rf alfa *.o lex.yy.c y.tab.c y.tab.h y.output

prueba1:
	./pruebaSintactico ficheros/entrada_sin_1.txt salidas/misalida1.txt

prueba2:
	./pruebaSintactico ficheros/entrada_sin_2.txt salidas/misalida2.txt

prueba3:
	./pruebaSintactico ficheros/entrada_sin_3.txt salidas/misalida3.txt

dif1:
	diff -Bb ficheros/salida_sin_1.txt salidas/misalida1.txt

dif2:
	diff -Bb ficheros/salida_sin_2.txt salidas/misalida2.txt

dif3:
	diff -Bb ficheros/salida_sin_3.txt salidas/misalida3.txt

zip:
	zip Huidobro_Pimentel_Moreno_morfo.zip *.y *.l *.c *.h makefile ficheros/* salidas/*
