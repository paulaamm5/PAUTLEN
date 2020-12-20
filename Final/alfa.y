%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "alfa.h"
	#incluse "tabla_simbolos.h"

	void yyerror(char *s);
	extern int yylex();

	extern FILE *yyin;
	extern FILE *yyout;
	extern int yyleng;
	extern int linea, columna, error;

	int tipo_actual;
	int clase_actual;

	int longitud;
	int tamanio_vector_actual;
	
	int es_funcion;
	num_variables_locales_actual=0;
   	pos_variable_local_actual=1;   /*cambiar a 0 alomejor*/
    	num_parametros_actual = 0;
    	pos_parametro_actual = 0;
    	control_retorno=0


	int control_retorno

	TablaHash tablaGlobal = NULL;
	TablaHash tablaLocal = NULL;
	tablaSimbolosAmbitos tabla;	/* Tabla de simbolos*/
%}

%union
{
 tipo_atributos atributos;
}


%token  TOK_MAIN
%token  TOK_INT
%token  TOK_ARRAY
%token  TOK_BOOLEAN
%token  TOK_FUNCTION
%token  TOK_IF
%token  TOK_ELSE
%token  TOK_WHILE
%token  TOK_SCANF
%token  TOK_PRINTF
%token  TOK_RETURN

%token  TOK_PUNTOYCOMA
%token  TOK_COMA
%token  TOK_LLAVEIZQUIERDA
%token  TOK_LLAVEDERECHA
%token  TOK_PARENTESISIZQUIERDO
%token  TOK_PARENTESISDERECHO
%token  TOK_CORCHETEIZQUIERDO
%token  TOK_CORCHETEDERECHO
%token  TOK_MAS
%token  TOK_MENOS
%token  TOK_DIVISION
%token  TOK_ASTERISCO
%token  TOK_AND
%token  TOK_OR
%token  TOK_ASIGNACION
%token  TOK_IGUAL
%token  TOK_NOT
%token  TOK_DISTINTO
%token  TOK_MENORIGUAL
%token  TOK_MAYORIGUAL
%token  TOK_MENOR
%token  TOK_MAYOR

%token  TOK_TRUE
%token  TOK_FALSE

%token TOK_ERROR


%token <atributos> TOK_CONSTANTE_ENTERA
%token <atributos> TOK_IDENTIFICADOR


%type <atributos> comparacion
%type <atributos> elemento_vector
%type <atributos> exp
%type <atributos> constante
%type <atributos> constante_entera
%type <atributos> constante_logica
%type <atributos> identificador


%type <atributos> if_exp
%type <atributos> if_exp_sentencias

%type <atributos> while
%type <atributos> while_exp

%type <atributos> fn_name
%type <atributos> fn_declaration

%type <atributos> call_func

/*por prioridad, preguntar a alfonso, el ultimo*/

%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND

%right TOK_NOT MENOSU



%start programa

%%
programa: TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escritura1 funciones escritura2 sentencias TOK_LLAVEDERECHA {
				fprintf(yyout, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
				fprintf( yyout, ";escribir_fin\n" );
        escribir_fin( yyout );
				}
;

escritura1: {
              fprintf( yyout, ";escribir_segmento_codigo\n" );
              escribir_segmento_codigo( yyout );

						fprintf( yyout, ";escribir_subseccion_data\n" );
						escribir_subseccion_data( yyout );
						fprintf( yyout, ";escribir_cabecera_bss\n" );
						escribir_cabecera_bss( yyout );
						}
  ;
escritura2: {
							fprintf( yyout, ";escribir_inicio_main\n" );
              escribir_inicio_main( yyout );
}
	;


/*REGLA PR 2*/
declaraciones: declaracion {
			fprintf(yyout, ";R2:\t<declaraciones> ::= <declaracion>\n");
			}

/*REGLA PR 3*/
		| declaracion declaraciones {
				fprintf(yyout, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");
		}
;

/*REGLA PR 4*/
declaracion: clase identificadores TOK_PUNTOYCOMA {
					fprintf(yyout, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");
					}
;

/*REGLA PR 5*/
clase: clase_escalar {
			fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
			clase_actual = ESCALAR;
			}


			| clase_vector {fprintf(yyout, ";R7:\t<clase> ::= <clase_vector>\n");
			clase_actual = VECTOR;
			}
;

/*REGLA PR 9*/
clase_escalar:tipo {
			fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");
			}
;

/*REGLA PR 10,11*/
tipo: TOK_INT {
				fprintf(yyout, ";R10:\t<tipo> ::= int\n");
				tipo_actual = VECTOR;
				}

				|	TOK_BOOLEAN {
					fprintf(yyout, ";R11:\t<tipo> ::= boolean\n");
					tipo_actual = BOOLEANO;
					}
;


/*REGLA PR 15*/
clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO {
					fprintf(yyout, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");

					/*$4 tiene el tamaño del vector. Comprobaciones semanticas*/  /*diapositiva 31*/
					tamanio_vector_actual = $4.valor_entero;
  					if(tamanio_vector_actual<1 || tamanio_vector_actual > MAX_TAMANIO_VECTOR) {
    					fprintf(ERR_OUT, "****Error semantico en lin %ld: El tamanio del vector incorrecto.\n", linea);
    					return -1;
  				}
				}
;

/*REGLA PR 18,19*/
identificadores: identificador {
					fprintf(yyout, ";R18:\t<identificadores> ::= <identificador>\n");
					}

					| identificador TOK_COMA identificadores {
						fprintf(yyout, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
					}
;



/*REGLA PR 20*/
funciones: funcion funciones {
					fprintf(yyout, ";R20:\t<funciones> ::= <funcion> <funciones>\n");
					}
					|  {
						fprintf(yyout, ";R21:\t<funciones> ::=\n");
						}
;



fn_name : TOK_FUNCTION tipo TOK_IDENTIFICADOR {
    hay_return = 0;
    es_funcion=1;
    simbolo = BuscarSimbolo($3.nombre);
    if(simbolo != NULL) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Declaracion duplicada.\n", linea);
      return -1;
    }

    inserta.lexema = $3.nombre;
    inserta.categoria = FUNCION;
    inserta.clase = ESCALAR;
    inserta.tipo = tipo_actual;

    strcpy($$.nombre, $3.nombre);
    $$.tipo = tipo_actual;

    DeclararFuncion($3.nombre, &inserta);
    num_variables_locales_actual=0;
    pos_variable_local_actual=1;   /*cambiar a 0 alomejor*/
    num_parametros_actual = 0;
    pos_parametro_actual = 0;
    control_retorno=0
};



fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion {
  /* Actualizar atributo num_parametros */
    simbolo = BuscarSimbolo($1.nombre);
    if(simbolo == NULL) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Declaracion duplicada.\n", linea);
      return -1;
    }
    simbolo->adicional1 = num_parametros_actual;
    strcpy($$.nombre, $1.nombre);
    $$.tipo = $1.tipo;
    declarar_funcion(out, $1.nombre, num_variables_locales_actual);
};
/*REGLA PR 22*/
/*
funcion: fn_declaration sentencias TOK_LLAVEDERECHA {
  if(control_retorno==0) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Funcion %s sin sentencia de retorno.\n", linea, $1.nombre);
    return -1;
  }
  CerrarFuncion();
  fin_funcion(out);
  simbolo = BuscarSimbolo($1.nombre);
  if(simbolo == NULL) {
      /* TODO *//*
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Declaracion duplicada.\n", linea);
      return -1;
  }
  simbolo->adicional1 = num_parametros_actual;
  es_funcion = 0;
  fprintf(yyout, ";R22:\t<funcion> ::=function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");}
*/


funcion: TOK_FUNCTION tipo identificador TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion sentencias TOK_LLAVEDERECHA {
				fprintf(yyout, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
				if(flagretorno==0){
		  	printf("****Error semantico en lin %d: Funcion <nombre_funcion> sin sentencia de retorno\n", nlin);
			return -1;
		  }

		  if(cerrarAmbito(&hashes)==-1){
		  printf("Error. La funcion no se ha le ha podido cerrar el ámbito.\n");
		  return -1;
		  }


		  aux = buscarTabla(&hashes, $1.lexema);
		  if(aux==NULL){
			printf("Error. La funcion ya estaba declarada pero no la encontramos.\n");
			return -1;
		  }


		  aux = new_simbolo($1.lexema, FUNCION, aux->tipo, -1, -1, -1, num_parametros_actual, -1, num_var_locales_actual);

		  insertarTabla(&hashes, $1.lexema, aux);
		  //Volvemos a cerrarAmbito porque por defecto se abre para una función pero no lo queremos.
		  if(cerrarAmbito(&hashes)==-1){
		  printf("Error. La funcion no se ha le ha podido cerrar el ámbito.\n");
		  return -1;
		  }
		  flag_definicion_funcion = 0;

				}
;


/*REGLA PR 23,24*/
parametros_funcion: parametro_funcion resto_parametros_funcion {
				fprintf(yyout, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
				}


			|  {
				fprintf(yyout, ";R24:\t<parametros_funcion> :=\n");
			}
;

/*REGLA PR 25,26*/
resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {
				fprintf(yyout, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
				}

				|  {
				fprintf(yyout, ";R26:\t<resto_parametros_funcion> ::=\n");
				}
;


/*REGLA PR 27*/
parametro_funcion: tipo identificador {
			fprintf(yyout, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
			num_parametros_actual++;
  		pos_parametro_actual++;
			}
;

idpf : TOK_IDENTIFICADOR {
    simbolo = BuscarSimbolo($1.nombre);
    if(simbolo != NULL) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Declaracion duplicada.\n", linea);
      return -1;
    }
    inserta.lexema = $1.nombre;
    inserta.categoria = PARAMETRO;
    inserta.clase = ESCALAR;
    inserta.tipo = tipo_actual;
    inserta.adicional1 = num_parametros_actual;

    Declarar($1.nombre, &inserta);
};

/*REGLA PR 28,29*/
declaraciones_funcion: declaraciones {
				fprintf(yyout, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");
				}

			|  {
			fprintf(yyout, ";R29:\t<declaraciones_funcion> ::=\n");
			}
;

/*REGLA PR 30,31*/
sentencias: sentencia {
				fprintf(yyout, ";R30:\t<sentencias> ::= <sentencia>\n");
				}

				| sentencia sentencias {
					fprintf(yyout, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");
				}
;

/*REGLA PR 32,33*/
sentencia: sentencia_simple TOK_PUNTOYCOMA {
				fprintf(yyout, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
				}

				| bloque {
				fprintf(yyout, ";R33:\t<sentencia> ::= <bloque>\n");
				}
;

/*REGLA PR 34, 35,36,38*/
sentencia_simple: asignacion {fprintf(yyout, ";R34:\t<sentencia_simple> ::= <asignacion>\n");}
		| lectura {fprintf(yyout, ";R35:\t<sentencia_simple> ::= <lectura>\n");}
		| escritura {fprintf(yyout, ";R36:\t<sentencia_simple> ::= <escritura>\n");}
		| retorno_funcion {fprintf(yyout, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");}
;


/*REGLA PR 40,41*/
bloque: condicional {fprintf(yyout, ";R40:\t<bloque> ::= <condicional>\n");}
	| bucle {fprintf(yyout, ";R41:\t<bloque> ::= <bucle>\n");}
;

/*REGLA PR 43,44*/
asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp  {
    simbolo = BuscarSimbolo($1.nombre);
    if(simbolo==NULL) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", linea, $1.nombre);
      return -1;
    } else {
      if(simbolo->categoria == FUNCION) {
        fprintf(ERR_OUT, "****Error semantico en lin %ld: Asignacion incompatible.\n", linea);
        return -1;
      }
      if(simbolo->clase == VECTOR) {
        fprintf(ERR_OUT, "****Error semantico en lin %ld: Asignacion incompatible.\n", linea);
        return -1;
      }
      if(simbolo->tipo != $3.tipo) {
        fprintf(ERR_OUT, "****Error semantico en lin %ld: Asignacion incompatible.\n", linea);
        return -1;

        }
      if (UsoGlobal($1.nombre) == NULL) {
      /* Estamos en una funcion y la variable es local */
        if(simbolo->categoria == PARAMETRO) {
          // REVISAR
          asignar_local(yyout, (num_parametros_actual-simbolo->adicional1+1), $3.es_direccion?0:1);
        } else {
          asignar_local(yyout, -(simbolo->adicional1+1), $3.es_direccion?0:1);
        }

      } else {
        asignar(out, $1.nombre, $3.es_direccion?0:1);
        fprintf(yyout, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
    }
  }
}

          | elemento_vector TOK_ASIGNACION exp {
            if($1.tipo != $3.tipo) {
              fprintf(ERR_OUT, "****Error semantico en lin %ld: Asignacion incompatible.\n", linea);
              return -1;
            }
            asignar_vector(out, $3.es_direccion?0:1);
            fprintf(yyout, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");}
          ;

/*REGLA PR 48*/
elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO {
		 simbolo = BuscarSimbolo($1.nombre);
	   if(simbolo == NULL) {
				 fprintf(ERR_OUT, "****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", linea, $1.nombre);
				 return -1;
			}
			if(simbolo->categoria == FUNCION) { /***REVISAR*/
					fprintf(ERR_OUT,"****Error semantico en lin %ld: Identificador no valido\n", linea);
					return -1;
			}
			if(simbolo->clase == ESCALAR) {
				  fprintf(ERR_OUT, "****Error semantico en lin %ld: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
					 return -1;
			}
			$$.tipo = simbolo->tipo;
			$$.es_direccion = 1;
			if($3.tipo != ENTERO) {
				 fprintf(ERR_OUT, "****Error semantico en lin %ld: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", linea);
				 return -1;
			 }
			 escribir_operando_array(out, $1.nombre, $3.es_direccion?0:1, simbolo->adicional1);

					  fprintf(yyout, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");}
					               ;


/*REGLA PR 50,51*/
condicional: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {fprintf(yyout, ";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");}
	|  TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias  TOK_LLAVEDERECHA {fprintf(yyout, ";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");}
;


if_exp: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA {
    if($3.tipo != BOOLEANO) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Condicional con condicion de tipo int.\n", linea);
      return -1;
    }
    $$.etiqueta = cuantos_condicionales++;
    inicio_condicional(yyout, $3.es_direccion?0:1, $$.etiqueta);
  }
	;

if_exp_sentencias:  if_exp sentencias {
	 $$.etiqueta = $1.etiqueta;
  sino_condicional(yyout, $$.etiqueta);

}
;


/*REGLA PR 52*/
bucle: TOK_WHILE TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {fprintf(yyout, ";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");}
;


while: TOK_WHILE TOK_PARENTESISIZQUIERDO {
  $$.etiqueta = cuantos_bucles++;
  etiqueta_inicio_while(yyout, $$.etiqueta);
}
;


while_exp: while exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA {
  if($2.tipo != BOOLEANO) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Bucle con condicion de tipo int.\n", linea);
    return -1;
  }

  $$.etiqueta = $1.etiqueta;
  inicio_bucle(yyout, $2.es_direccion?0:1, $$.etiqueta);
};

/*REGLA PR 54*/
lectura: TOK_SCANF TOK_IDENTIFICADOR {
    simbolo = BuscarSimbolo($2.nombre);   /*cambiar $2.nombre por $2.lexema */
    if(simbolo == NULL) {
      fprintf(ERR_OUT, "*Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", linea, $2.nombre);
      return -1;
    }
    leer(yyout, $2.nombre, simbolo->tipo);
    fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");
};

/*
lectura: TOK_SCANF identificador {fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");}
;
*/


/*REGLA PR 56*/
escritura: TOK_PRINTF exp {
			escribir(yyout, !($2.es_direccion), ($2.tipo));
			fprintf(yyout, ";R56:\t<escritura> ::= printf <exp>\n");
			}
;


/*REGLA PR 61*/
retorno_funcion: TOK_RETURN exp {
  if(!es_funcion) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Sentencia de retorno fuera del cuerpo de una funcion.\n", linea);
    return -1;
  }

  hay_return = 1;
  retorno_funcion(out, $2.es_direccion?0:1);
  fprintf(yyout, ";R61:\t<retorno_funcion> ::= return <exp>\n");
	}
;

/*REGLA PR 72,73,74,75,76,77,78,79,80,81,82,83,85,88*/
exp: exp TOK_MAS exp {
  if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", linea);
    return -1;
  }
  sumar(out, $1.es_direccion?0:1, $3.es_direccion?0:1);
  $$.es_direccion = 0;
  $$.tipo = ENTERO;

  fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");
}

   | exp TOK_MENOS exp {
  if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", linea);
    return -1;
  }
  $$.tipo = ENTERO;
  restar(out, $1.es_direccion?0:1, $3.es_direccion?0:1);
  $$.es_direccion = 0;
    fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");
}

   | exp TOK_DIVISION exp {
  if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
    /** ERROR **/
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", linea);
    return -1;
  }
  $$.tipo = ENTERO;
  dividir(out, $1.es_direccion?0:1, $3.es_direccion?0:1);
  $$.es_direccion = 0;
    fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");
}

   | exp TOK_ASTERISCO exp {
  if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", linea);
    return -1;
  }
  $$.tipo = ENTERO;
  multiplicar(out, $1.es_direccion?0:1, $3.es_direccion?0:1);
  $$.es_direccion = 0;
    fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");
}

   | TOK_MENOS exp %prec MENOSU {
    if($2.tipo!=ENTERO) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", linea);
      return -1;
    }
    $$.tipo = ENTERO;
    cambiar_signo(out, $2.es_direccion?0:1);
    $$.es_direccion = 0;
    fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");
}
   | exp TOK_AND exp {
    if($1.tipo!=BOOLEANO || $3.tipo != BOOLEANO) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion logica con operandos int.\n", linea);
      return -1;
    }
    $$.tipo = BOOLEANO;
    y(out, $1.es_direccion?0:1, $3.es_direccion?0:1);
    $$.es_direccion = 0;
    fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
}
   | exp TOK_OR exp {
    if($1.tipo!=BOOLEANO || $3.tipo != BOOLEANO) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion logica con operandos int.\n", linea);
      return -1;
    }
    $$.tipo = BOOLEANO;
    o(out, $1.es_direccion?0:1, $3.es_direccion?0:1);
    $$.es_direccion = 0;
    fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
    fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");
  }
   | TOK_NOT exp {
    if($2.tipo!=BOOLEANO) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Operacion logica con operandos int.\n", linea);
      return -1;
    }
    $$.tipo = BOOLEANO;
    no(out, $2.es_direccion?0:1, cuantos_no++);
    $$.es_direccion = 0;
    fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");
}
   | TOK_IDENTIFICADOR {
    strcpy($$.nombre, $1.nombre);
    simbolo = BuscarSimbolo($1.nombre);
    if(simbolo == NULL) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", linea, $1.nombre);
      return -1;
    }
    if (UsoGlobal($1.nombre) == NULL) {
      /* Estamos en una funcion y la variable es local */
      if(simbolo->categoria == PARAMETRO) {
        escribir_operando_funcion(out, (num_parametros_actual-simbolo->adicional1)+1);
      } else {
        escribir_operando_funcion(out, -(simbolo->adicional1+1));
      }

    } else {
      if(simbolo->categoria==FUNCION) {
        /* NUNCA SUCEDE */
        fprintf(ERR_OUT,"Identificador no valido\n");
        return -1;
    }

    escribir_operando(out, $1.nombre, 1);

    }
    $$.es_direccion = 1;
    $$.tipo = simbolo->tipo;

    fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");

  }
   | constante {
    $$.tipo =$1.tipo;
    $$.es_direccion = $1.es_direccion;
    escribir_operando(out, $1.nombre, 0);
    fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");
  }
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {
    $$.tipo =$2.tipo;
    $$.es_direccion = $2.es_direccion;
    fprintf(yyout, ";R82:\t<exp> ::= ( <exp> )\n");
  }
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {
    $$.tipo =BOOLEANO;
    $$.es_direccion = 0;
    fprintf(yyout, ";R82:\t<exp> ::= ( <exp> )\n");
    fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");
  }
   | elemento_vector {
    fprintf(yyout, ";R85:\t<exp> ::= <elemento_vector>\n");

  }
   |  call_func lista_expresiones TOK_PARENTESISDERECHO {
    simbolo = BuscarSimbolo($1.nombre);
    if(simbolo == NULL) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Funcion no declarada (%s).\n", linea, $1.nombre);
      return -1;
    }
    if(simbolo->categoria != FUNCION){
      fprintf(ERR_OUT, "****Error semantico en lin %ld: El identificador no es una funcion (%s).\n", linea, $1.nombre);
      return -1;
    }
    if(simbolo->adicional1 != params) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Numero incorrecto de parametros en llamada a funcion.\n", linea);
      return -1;
    }
    es_llamada = 0;
    $$.tipo = simbolo->tipo;
    llamar_funcion(out, $1.nombre, simbolo->adicional1);

    fprintf(yyout, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");}
   ;

/*
exp: exp TOK_MAS exp {fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");}
	| exp TOK_MENOS exp {fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");}
	| exp TOK_DIVISION exp {fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");}
	| exp TOK_ASTERISCO exp {fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");}
	| TOK_MENOS exp %prec MENOSU {fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");}
	| exp TOK_AND exp {fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");}
	| exp TOK_OR exp {fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");}
	| TOK_NOT exp {fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");}
	| TOK_IDENTIFICADOR {fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");}
	| constante {fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");}
	| TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {fprintf(yyout, ";R82:\t<exp> ::= ( <exp> )\n");}
	| TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");}
	| elemento_vector {fprintf(yyout, ";R85:\t<exp> ::= <elemento_vector>\n");}
	| identificador TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO {fprintf(yyout, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");}
;*/

call_func: TOK_IDENTIFICADOR TOK_PARENTESISIZQUIERDO {
  if(es_llamada) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n", linea);
    return -1;
  }
  es_llamada = 1;
  params = 0;
  strcpy($$.nombre, $1.nombre);
}
;

/*REGLA PR 89,90*/
lista_expresiones: exp resto_lista_expresiones {
				fprintf(yyout, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
				}
		|  {
		fprintf(yyout, ";R90:\t<lista_expresiones> ::=\n");
		es_llamada = 0;
		}
;

expf: exp {
  if($1.es_direccion) {
    cambiar_a_valor(out);
  }
};

/*REGLA PR 91,92*/
resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones {
					fprintf(yyout, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
					paramas++;
					}
					|  {
						fprintf(yyout, ";R92:\t<resto_lista_expresiones> ::=\n");
						}
;


/*REGLA PR 93,94,95,96,97,98*/
comparacion: exp TOK_IGUAL exp {
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    fprintf(ERR_OUT, "****Error semantico en lin %ld: Comparacion con operandos boolean.\n", linea);
    return -1;
  }
  igual(out, $1.es_direccion?0:1, $3.es_direccion?0:1, cuantas_comparaciones++);
  /*$$.tipo = BOOLEANO;
  $$.es_direccion = 0;*/
  fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
}
           | exp TOK_DISTINTO exp {
            if($1.tipo != ENTERO || $3.tipo != ENTERO) {
              fprintf(ERR_OUT, "****Error semantico en lin %ld: Comparacion con operandos boolean.\n", linea);
              return -1;
            }
            distinto(out, $1.es_direccion?0:1, $3.es_direccion?0:1, cuantas_comparaciones++);
            fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
            }
           | exp TOK_MENORIGUAL exp {
            if($1.tipo != ENTERO || $3.tipo != ENTERO) {
              fprintf(ERR_OUT, "****Error semantico en lin %ld: Comparacion con operandos boolean.\n", linea);
              return -1;
            }
            menorigual(out, $1.es_direccion?0:1, $3.es_direccion?0:1, cuantas_comparaciones++);
            fprintf(yyout, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");}
           | exp TOK_MAYORIGUAL exp {
            if($1.tipo != ENTERO || $3.tipo != ENTERO) {
              fprintf(ERR_OUT, "****Error semantico en lin %ld: Comparacion con operandos boolean.\n", linea);
              return -1;
            }
            mayorigual(out, $1.es_direccion?0:1, $3.es_direccion?0:1, cuantas_comparaciones++);
            fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");}
           | exp TOK_MENOR exp {
            if($1.tipo != ENTERO || $3.tipo != ENTERO) {
              fprintf(ERR_OUT, "****Error semantico en lin %ld: Comparacion con operandos boolean.\n", linea);
              return -1;
            }
            menor(out, $1.es_direccion?0:1, $3.es_direccion?0:1, cuantas_comparaciones++);
            fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");}
           | exp TOK_MAYOR exp {
            if($1.tipo != ENTERO || $3.tipo != ENTERO) {
              fprintf(ERR_OUT, "****Error semantico en lin %ld: Comparacion con operandos boolean.\n", linea);
              return -1;
            }
            mayor(out, $1.es_direccion?0:1, $3.es_direccion?0:1, cuantas_comparaciones++);
            fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");}
           ;


/*
comparacion: exp TOK_IGUAL exp {fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");}
	| exp TOK_DISTINTO exp {fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");}
	| exp TOK_MENORIGUAL exp {fprintf(yyout, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");}
	| exp TOK_MAYORIGUAL exp {fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");}
	| exp TOK_MENOR exp {fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");}
	| exp TOK_MAYOR exp {fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");}
;*/



/*REGLA PR 99,100*/
constante: constante_logica {
		fprintf(yyout, ";R99:\t<constante> ::= <constante_logica>\n");
		$$.tipo = $1.tipo;
    $$.es_direccion = $1.es_direccion;
		strcpy($$.nombre, $1.nombre);
		}
	| constante_entera {
		fprintf(yyout, ";R100:\t<constante> ::= <constante_entera>\n");
		$$.tipo = $1.tipo;
    $$.es_direccion = $1.es_direccion;
		strcpy($$.nombre, $1.nombre);
		}
;

/* REGLA PR 102,103 */
constante_logica: TOK_TRUE {
		fprintf(yyout, ";R102:\t<constante_logica> ::= true\n");
		$$.tipo = BOOLEANO;
                $$.es_direccion = 0;
		strcpy($$.nombre,"1");

		fprintf(yyout, ";escribir_operando\n");
                escribir_operando( out, "1" , 0 );
		}

		| TOK_FALSE {
			fprintf(yyout, ";R103:\t<constante_logica> ::= false\n");
			$$.tipo = BOOLEANO;
                   	$$.es_direccion = 0;
			strcpy($$.nombre,"0");
			fprintf(yyout, ";escribir_operando\n");
                    	escribir_operando( out, "0" , 0 )
			}
;

/* REGLA PR 104 */
constante_entera: TOK_CONSTANTE_ENTERA {

	fprintf(yyout, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");

	$$.tipo = INT;
	$$.es_direccion = 0;
	$$.valor_entero = $1.valor_entero;

		/* escribe código con tu librería para meter en la pila la constante
			  push dword $1.valor_entero
		  */

	sprintf( buff, "%d", $$.valor_entero );
					fprintf(yyout, ";escribir_operando\n");
                    escribir_operando( out, buff , 0 );


	}
;

/*REGLA PR 108*/
identificador: TOK_IDENTIFICADOR {
    simbolo = BuscarSimbolo($1.nombre);
    if((simbolo != NULL && !es_funcion) || (simbolo != NULL && EsLocal($1.nombre)) ) {
      fprintf(ERR_OUT, "****Error semantico en lin %ld: Declaracion duplicada.\n", linea);
      return -1;
    }

    inserta.lexema = $1.nombre;
    inserta.categoria = VARIABLE;
    inserta.clase = clase_actual;
    inserta.tipo = tipo_actual;
    if(clase_actual == VECTOR) {
      inserta.adicional1 = tamano_vector_actual;

    } else {
      inserta.adicional1 = 1;
    }
    if(es_funcion) {
      if(clase_actual == VECTOR) {
        fprintf(ERR_OUT, "****Error semantico en lin %ld: Variable local de tipo no escalar.\n", linea);
        return -1;
      }
      inserta.adicional1 = num_variables_locales_actual;
      num_variables_locales_actual++;
      pos_variable_local_actual++;
    } else {
      declarar_variable(out, $1.nombre, tipo_actual,  inserta.adicional1);

    }
    Declarar($1.nombre, &inserta);


    fprintf(out, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");}
             ;

/*
escribirTabla: { /* Escribir tabla de simbolos a nasm */ escribir_segmento_codigo(out); }

 escribirMain: { escribir_inicio_main(out);}*/
%%

void yyerror (char *s){
	if(error == 0){
		fprintf(stderr,"**** Error sintáctico en [linea %d, columna %d]\n", linea, columna-yyleng);
	}

	error = 0;
}
