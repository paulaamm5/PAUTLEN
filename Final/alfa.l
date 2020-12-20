%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"

    int linea = 1, columna = 1, error = 0;
%}
%option noyywrap
%%

"\n" {linea++; columna=1;}
"\t" {columna+=yyleng;}
" " {columna+=yyleng;}
"\r" {columna+=yyleng;}
"//".*\n {linea++;}


main {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MAIN;}
int {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_INT;}
boolean {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_BOOLEAN;}
function {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_FUNCTION;}
array {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_ARRAY;}
if {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_IF;}
else {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_ELSE;}
while {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_WHILE;}
scanf {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_SCANF;}
printf {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_PRINTF;}
return {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_RETURN;}

";" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_PUNTOYCOMA;}
"," {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_COMA;}
"{" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_LLAVEIZQUIERDA;}
"}" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_LLAVEDERECHA;}
"(" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_PARENTESISIZQUIERDO;}
")" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_PARENTESISDERECHO;}
"[" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_CORCHETEIZQUIERDO;}
"]" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_CORCHETEDERECHO;}
"+" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MAS;}
"-" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MENOS;}
"/" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_DIVISION;}
"*" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_ASTERISCO;}
"&&" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_AND;}
"||" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_OR;}
"=" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_ASIGNACION;}
"!=" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_DISTINTO;}
"==" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_IGUAL;}
"!" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_NOT;}
"<=" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MENORIGUAL;}
">=" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MAYORIGUAL;}
"<" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MENOR;}
">" {columna+=yyleng;fprintf(yyout,";D:\t%s\n",yytext); return TOK_MAYOR;}

true {columna+=yyleng; fprintf(yyout,";D:\t%s\n",yytext); return TOK_TRUE;}
false {columna+=yyleng; fprintf(yyout,";D:\t%s\n",yytext); return TOK_FALSE;}

[0-9]+ {columna+=yyleng; yylval.atributos.valor_entero=atoi(yytext); fprintf(yyout,";D:\t%s\n",yytext); return TOK_CONSTANTE_ENTERA;}



[a-zA-Z][a-zA-Z0-9]* {columna+=yyleng; strcpy(yylval.atributos.lexema, yytext);
			if(yyleng<=100){
				fprintf(yyout,";D:\t%s\n",yytext);
			}
			else{fprintf(stdout,"Error en [linea %d, columna %d]: identificador demasiado largo (%s)\n",linea,columna-yyleng,yytext); error=1; return TOK_ERROR;}; return TOK_IDENTIFICADOR;}


. {error=1; columna+=yyleng; fprintf(stdout,"Error morfologico en [lin %d, columna %d]: simbolo no permitido (%s)\n",linea,columna-yyleng,yytext); return TOK_ERROR;}

























%%
