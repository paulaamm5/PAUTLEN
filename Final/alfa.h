#ifndef ALFA_H
#define ALFA_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tablaHash.h"
#include "tablaSimbolos.h"
#include "generacion.h"
#define MAX_LONG 100
#define MAX_TAMANIO_VECTOR 64
#define ERR_OUT stdout
struct _tipo_atributos {

typedef enum {
  FALSE = 0,
  TRUE = 1
} BOOL;

struct _tipo_atributos{
  char lexema[MAX_LONG_ID+1];
  int tipo;
  int valor_entero;
  BOOL valor_boolean;
  int es_direccion;
  int etiqueta;
};
typedef struct _tipo_atributos tipo_atributos;



/* CLASES */
#define ESCALAR 1
#define VECTOR 3
···

/* TIPOS */
#define INT 1
#define BOOLEAN 3




#endif
