#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tablaSimbolos.h"


TABLA_HASH * tablaLocal = NULL;
TABLA_HASH * tablaGlobal = NULL;

TABLA_HASH * CrearTablaGlobal(){
    if(tablaGlobal == NULL){
       tablaGlobal = crear_tabla(TAM_GLOBAL);
       return tablaGlobal;
    }

    return NULL;
}

TABLA_HASH * CrearTablaLocal(){
    if(tablaLocal == NULL){
       tablaLocal = crear_tabla(TAM_LOCAL);
       return tablaLocal;
    }
    return NULL;
}

STATUS Declarar(const char *id, INFO_SIMBOLO *is){
    if(tablaLocal == NULL)
        return DeclararGlobal(id, is);
    return DeclararLocal(id, is);
}

STATUS DeclararGlobal(const char * id,INFO_SIMBOLO *is){

    if(tablaGlobal == NULL){
        tablaGlobal = crear_tabla(TAM_GLOBAL);
        if(tablaGlobal == NULL)
            return ERROR;
    }
    if(buscar_simbolo(tablaGlobal, id) == NULL){
        return insertar_simbolo(tablaGlobal, id, is->categoria, is->tipo, is->clase, is->valor1, is->valor2);
    }
    return ERROR;
    
}

STATUS DeclararLocal(const char * id,INFO_SIMBOLO *is){

    if(tablaLocal == NULL){
        tablaLocal = crear_tabla(TAM_LOCAL);
        if(tablaLocal == NULL)
            return ERROR;
    }
    if(buscar_simbolo(tablaLocal, id) == NULL){
        return insertar_simbolo(tablaLocal, id, is->categoria, is->tipo, is->clase, is->valor1, is->valor2);
    }
    return ERROR;
    
}

INFO_SIMBOLO * UsoGlobal(const char * id){

    if(tablaGlobal == NULL)
        return NULL;

    return buscar_simbolo(tablaGlobal, id);
     
}

INFO_SIMBOLO * UsoLocal(const char * id){

    INFO_SIMBOLO *dato = NULL;
    
    if(tablaLocal == NULL)
        return UsoGlobal(id);
    
    dato = buscar_simbolo(tablaLocal, id);
    if(dato != NULL){
        return dato;
    }
    return UsoGlobal(id);

}

STATUS DeclararFuncion(const char * id,INFO_SIMBOLO *is){

    
    if(buscar_simbolo(tablaGlobal, id) == NULL){
        if(insertar_simbolo(tablaGlobal, id, is->categoria, is->tipo, is->clase, is->valor1, is->valor2) == ERROR){

            return ERROR;
        }

        liberar_tabla(tablaLocal);
        tablaLocal = crear_tabla(TAM_LOCAL);
        if(tablaLocal == NULL){
            borrar_simbolo(tablaGlobal, id);
            liberar_tabla(tablaLocal);
            tablaLocal = NULL;
            return ERROR;
        }
        if(insertar_simbolo(tablaLocal, id, is->categoria, is->tipo, is->clase, is->valor1, is->valor2) == ERROR){
            borrar_simbolo(tablaGlobal, id);
            liberar_tabla(tablaLocal);
            tablaLocal = NULL;
            return ERROR;
        }
        return OK;
    }

    return ERROR;

}

STATUS CerrarFuncion(){
    if(tablaLocal == NULL)
        return ERROR;

    liberar_tabla(tablaLocal);
    tablaLocal = NULL;
    return ERROR;
  
}

void liberarTablas(){
    if(tablaLocal != NULL)
        liberar_tabla(tablaLocal);
    if(tablaGlobal != NULL)
        liberar_tabla(tablaGlobal);
}

