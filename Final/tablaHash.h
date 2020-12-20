#ifndef TABLAHASH_H
#define TABLAHASH_H
#include <stdio.h>

/**************** CONSTANTES ****************/

#define POS_INI_PARAMS 0       /* posición de inicio de parámetros de función (empiezan a contar en 0) */
#define POS_INI_VARS_LOCALES 1  /* posición de inicio de variables locales de función (empiezan a contar en 1) */

#define HASH_INI 5381
#define HASH_FACTOR 33


/*Categoria del elemento*/
typedef enum {
    VARIABLE=1,
    PARAMETRO,
    FUNCION
}CATEGORIA;

/*Tipo variable que almacena un unico valor o un vector que almacena una serie de elementos */
typedef enum {
    BOOLEAN=1,
    INT
}TIPO;

/*Tipo del elemento si es una variable o paramentro, si es un vector es el tipo que se alamcena en este, si es una funcion se refiere al tipo de retorno*/
typedef enum {
    ESCALAR=1,
    VECTOR
}CLASE;

/*ESTADO CORRECTO Y ERRONEO*/
typedef enum {
    ERROR=0,
    OK
} STATUS;


/* Información de un símbolo */
typedef struct  info_simbolo {
    char* lexema;           /* identificador */
    CATEGORIA categoria;    /* categoría */
    TIPO tipo;              /* tipo */
    CLASE clase;            /* clase */
    int valor1;    /* valor si escalar, longitud si vector, número de parámetros si función */
    int valor2;    /* posición en llamada a función si parámetro, posición de declaración si variable local de función, número de variables locales si función */
  //  struct info_simbolo* siguiente; /* Lista enlazada con todos los simbolos de la tabla */

} INFO_SIMBOLO;

/* Nodo de la tabla hash */
typedef struct nodo_hash {
    INFO_SIMBOLO* info;      /* información del símbolo */
    struct nodo_hash* siguiente;    /* puntero al siguiente nodo (encadenamiento si colisión en misma celda) */
} NODO_HASH;

/* Tabla hash */
typedef struct {
    int tam;            /* tamaño de la tabla hash */
    NODO_HASH** tabla;  /* tabla en sí (array de tam punteros a nodo) */
    //INFO_SIMBOLO* simbolos; /* Lista enlazada con todos los info_simbolos */
} TABLA_HASH;


/**************** FUNCIONES ****************/

INFO_SIMBOLO* crear_info_simbolo(const char* lexema, CATEGORIA categ, TIPO tipo, CLASE clase, int adic1, int adic2);
void liberar_info_simbolo(INFO_SIMBOLO* is);
NODO_HASH* crear_nodo(INFO_SIMBOLO* is);
void liberar_nodo(NODO_HASH* nh);
TABLA_HASH* crear_tabla(int tam);
void liberar_tabla(TABLA_HASH* th);
unsigned long hash(const char* str);
INFO_SIMBOLO* buscar_simbolo(const TABLA_HASH* th, const char* lexema);
STATUS insertar_simbolo(TABLA_HASH* th, const char* lexema, CATEGORIA categ, TIPO tipo, CLASE clase, int adic1, int adic2);
void borrar_simbolo(TABLA_HASH* th, const char* lexema);
INFO_SIMBOLO* lista_simbolos(const TABLA_HASH* th);
void tabla_dump(const TABLA_HASH * th);

#endif  /* TABLAHASH_H */