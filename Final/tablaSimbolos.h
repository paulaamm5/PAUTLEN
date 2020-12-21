#ifndef TABLASIMBOLOS_H
#define TABLASIMBOLOS_H

#include "tablaHash.h"

#define TAM_GLOBAL 1000
#define TAM_LOCAL 1000

TABLA_HASH * CrearTablaGlobal();

TABLA_HASH * CrearTablaLocal();

STATUS Declarar(const char *id, INFO_SIMBOLO *is);

STATUS DeclararGlobal(const char * identificador,INFO_SIMBOLO *is);

STATUS DeclararLocal(const char * identificador,INFO_SIMBOLO *is);

INFO_SIMBOLO * UsoGlobal(const char * identificador);

INFO_SIMBOLO * UsoLocal(const char * identificador);

STATUS DeclararFuncion(const char * identificador,INFO_SIMBOLO *is);

STATUS CerrarFuncion();

void liberarTablas();

void ImprimirTablaGlobal();

void ImprimirTablaLocal();

#endif
