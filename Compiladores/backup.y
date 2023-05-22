%{

/*
librerias y variables
prototipos
*/
#include<stdio.h>
#include<string.h>
#include<ctype.h>

void yyerror(char *s);
int localizaSimbolo(char *lexema, int token);
int yylex();
char lexema[100];
typedef struct {
	char nombre[100];
	int token;
	double valor;
	int tipo;
}TipoTablaDeSimbolos  ;

int nSim=0;

TipoTablaDeSimbolos tablaDeSimbolos[200];
%}

%token  MIENTRAS ID IGUAL NUMENT SUMA PARIZQ LLAVEDER LLAVEIZQ PARDER RESTA MUL DIV PARIZ PUNTOYCOMA DARDIMENSION PIEZA NUEVO TABLERO NOMBRE DARPOSICION LIMPIARPOSICION SACO LIMPIARSACO AMOGUS COMILLAS PUNTO COMA EVALUARPOSICION RANDOM ELIMINAR COMPARA MOSTRAR IMPRIMIR LIMPIAR CLONAR EXISTEPIEZA GLOBAL LOCAL VAR XCOOR YCOOR COMENT OBTENERPIEZA ELIMINARPOSICION FUNCION MAIN IMPORTAR

%%
/*gramatica*/

// programa: encabezados funciones main ;
programa: encabezados main ;

encabezados: IMPORTAR COMILLAS encabezados;
encabezados: ;

//funciones: FUNCION idvalor PARIZQ paramfunc PARDER //bloqinst funciones;
//funciones:  ;

// func ejemplo(parm1 par2)
//paramfunc: factor paramfunc;
//paramfunc: ;

main: FUNCION MAIN PARIZQ PARDER bloqinst ;

listInst: instr listInst;
listInst: ;

instr: idvalor IGUAL expr PUNTOYCOMA;
instr: table LIMPIARPOSICION PARIZQ expr COMA expr PARDER PUNTOYCOMA;
instr: idpieza DARPOSICION PARIZQ expr COMA expr PARDER PUNTOYCOMA;
instr: table DARDIMENSION PARIZQ expr COMA expr PARDER PUNTOYCOMA;
instr: table MOSTRAR PARIZQ PARDER PUNTOYCOMA;
instr: IMPRIMIR PARIZQ COMILLAS PARDER PUNTOYCOMA;
instr: idpieza NOMBRE IGUAL COMILLAS PUNTOYCOMA;
instr: idpieza ELIMINAR PARIZQ PARDER PUNTOYCOMA;
instr: MIENTRAS PARIZQ expr PARDER bloqinst;
instr: AMOGUS PARIZQ PARDER PUNTOYCOMA;
instr: sack LIMPIARSACO PARIZQ PARDER PUNTOYCOMA;
instr: table LIMPIAR PARIZQ PARDER PUNTOYCOMA;
instr: COMENT;
instr: GLOBAL VAR idvalor PUNTOYCOMA;
instr: GLOBAL VAR idvalor IGUAL expr PUNTOYCOMA;
instr: LOCAL VAR idvalor PUNTOYCOMA;
instr: LOCAL VAR idvalor IGUAL expr PUNTOYCOMA;
instr: table ELIMINARPOSICION PARIZQ expr COMA expr PARDER PUNTOYCOMA;

//instrnum no debe tener tener punto y coma al final
instrnum: randomcito PUNTO CLONAR PARIZQ PARDER;
instrnum: idpieza CLONAR PARIZQ PARDER;
instrnum: table EVALUARPOSICION PARIZQ expr COMA expr PARDER;
instrnum: randomcito;
instrnum: table EXISTEPIEZA PARIZQ expr COMA expr PARDER;
instrnum: idpieza XCOOR;
instrnum: idpieza YCOOR;
instrnum: PIEZA PUNTO NUEVO PARIZQ PARDER;
instrnum: table OBTENERPIEZA PARIZQ expr COMA expr PARDER;

randomcito: RANDOM PARIZQ expr COMA expr PARDER;

expr: expr COMPARA term;
expr: expr SUMA term;
expr: expr RESTA term;
expr: term;

term: term MUL factor;
term: term DIV factor;
term: factor;

table: TABLERO PUNTO;

idpieza: ID{ localizaSimbolo(lexema,ID);} PUNTO;

factor: PARIZQ expr PARDER;
factor: numeral;
factor: instrnum;
factor: ID{ localizaSimbolo(lexema,ID);};

idvalor: ID{ localizaSimbolo(lexema,ID);};

numeral: NUMENT{ localizaSimbolo(lexema,NUMENT);};

bloqinst : LLAVEIZQ listInst LLAVEDER;

sack: SACO PUNTO;
%%

/*codigo C*/
/*análisis léxico*/

void imprimirAmogus(){
	printf("⠀⠀⠀⠀       ⣤⣤⣶⣦⣤⣄⡀⣤⣤⣤⣠\n");
	printf("	⢀⣴⣿⡿⠛⠉⠙⠛⠛⠛⠛⠻⢿⣿⣷⣤⡀⠀⠀⠀⠀⠀ \n");
	printf("⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠋⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠈⢻⣿⣿⡄⠀⠀⠀⠀ \n");
	printf("⠀⠀⠀⠀⠀⠀⠀⣸⣿⡏⠀⠀⠀⣠⣶⣾⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣄⠀⠀⠀ \n");
	printf("⠀⠀⠀⠀⠀⠀⠀⣿⣿⠁⠀⠀⢰⣿⣿⣯⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣷⡄⠀ \n");
	printf("⠀⠀⣀⣤⣴⣶⣶⣿⡟⠀⠀⠀⢸⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣷⠀ \n");
	printf("⠀⢰⣿⡟⠋⠉⣹⣿⡇⠀⠀⠀⠘⣿⣿⣿⣿⣷⣦⣤⣤⣤⣶⣶⣶⣶⣿⣿⣿⠀ \n");
	printf("⠀⢸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀ \n");
	printf("⠀⣸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠉⠻⠿⣿⣿⣿⣿⡿⠿⠿⠛⢻⣿⡇⠀⠀ \n");
	printf("⠀⣿⣿⠁⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣧⠀⠀ \n");
	printf("⠀⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀ \n");
	printf("⠀⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀ \n");
	printf("⠀⢿⣿⡆⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀ \n");
	printf("⠀⠸⣿⣧⡀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠃⠀⠀ \n");
	printf("⠀⠀⠛⢿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⣰⣿⣿⣷⣶⣶⣶⣶⠶⠀⢠⣿⣿⠀⠀⠀ \n");
	printf("⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⣽⣿⡏⠁⠀⠀⢸⣿⡇⠀\n");
	printf("       ⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⢹⣿⡆⠀⠀⠀⣸⣿⠇⠀\n");
	printf("⠀⠀⠀⠀⠀⠀⠀⢿⣿⣦⣄⣀⣠⣴⣿⣿⠁⠀⠈⠻⣿⣿⣿⣿⡿⠏⠀ \n");
	printf("⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠿⠿⠿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n");
}

int localizaSimbolo(char *lexema, int token){
	for(int i=0;i<nSim;i++){
		if(!strcmp(tablaDeSimbolos[i].nombre,lexema)){
			return i;
		}
	}
	strcpy(tablaDeSimbolos[nSim].nombre,lexema);
	tablaDeSimbolos[nSim].token=token;
	tablaDeSimbolos[nSim].tipo=0;
	tablaDeSimbolos[nSim].valor=0.0;
	nSim++;
	return nSim-1;
}

int yylex(){
  char c;int i;
  c=getchar();
  while(c==' ' || c=='\n' || c=='\t'){ c=getchar(); if(c!=' ' && c!='\n' && c!='\t') break;} 
  
                
  if(c=='#') return 0;
  if(isalpha(c)){
    i=0;
    do {
      lexema[i++]=c;
      c=getchar();
    } while(isalnum(c));
    ungetc(c,stdin);
    lexema[i++]='\0';

    if(!strcmp(lexema,"while")) return MIENTRAS; 
    if(!strcmp(lexema,"setdim")) return DARDIMENSION; 
    if(!strcmp(lexema,"setpos")) return DARPOSICION; 
    if(!strcmp(lexema,"tag")) return NOMBRE; 
    if(!strcmp(lexema,"board")) return TABLERO; 
    if(!strcmp(lexema,"new")) return NUEVO; 
    if(!strcmp(lexema,"piece")) return PIEZA; 
    if(!strcmp(lexema,"clearpos")) return LIMPIARPOSICION; 
    if(!strcmp(lexema,"sack")) return SACO; 
    if(!strcmp(lexema,"empty")) return LIMPIARSACO; 
    if(!strcmp(lexema,"random")) return RANDOM; 
    if(!strcmp(lexema,"posval")) return EVALUARPOSICION; 
    if(!strcmp(lexema,"delete")) return ELIMINAR; 
    if(!strcmp(lexema,"amogus")) {
    	imprimirAmogus();
    	return AMOGUS;
    }
    if(!strcmp(lexema,"show")) return MOSTRAR;
    if(!strcmp(lexema,"print")) return IMPRIMIR;
    if(!strcmp(lexema,"clear")) return LIMPIAR;
    if(!strcmp(lexema,"clone")) return CLONAR;
    if(!strcmp(lexema,"existpiece")) return EXISTEPIEZA;
    if(!strcmp(lexema,"global")) return GLOBAL;
    if(!strcmp(lexema,"local")) return LOCAL;
    if(!strcmp(lexema,"var")) return VAR;
    if(!strcmp(lexema,"getpieces")) return OBTENERPIEZA;
    if(!strcmp(lexema,"x")) return XCOOR;
    if(!strcmp(lexema,"y")) return YCOOR;
    if(!strcmp(lexema,"delpos")) return ELIMINARPOSICION;
    if(!strcmp(lexema,"func")) return FUNCION;
    if(!strcmp(lexema,"main")) return MAIN;
    if(!strcmp(lexema,"import")) return IMPORTAR;
    return ID;
  }

  if(isdigit(c)){
    i=0;
    do{
      lexema[i++]=c;
      c=getchar();
    } while(isdigit(c));
    ungetc(c,stdin);
    lexema[i++]='\0';
                             
    return NUMENT;
  } 
                 
  if(c=='=') {
    c = getchar();
    if(c=='=') return COMPARA;
    ungetc(c,stdin);
    return IGUAL;
  }
   
  if(c=='+') return SUMA;
  if(c=='-') return RESTA;
  if(c=='*') return MUL;
  if(c=='(') return PARIZQ;
  if(c==')') return PARDER;
  if(c=='}') return LLAVEDER;
  if(c=='{') return LLAVEIZQ;
  if(c==';') return PUNTOYCOMA;
  if(c=='.') return PUNTO;
  if(c=='"'){
    while(1) {
      c = getchar();
      if(c == '"') return COMILLAS;
    }    
  }
  if(c=='/'){
      c =  getchar();
      if(c=='/'){        
        while(1) {
          c = getchar();
          if(c == '\n'){
            return COMENT;
          }
        }  
      } else if(c == '*'){
        while(1) {
          c = getchar();
          if(c == '*'){
            c = getchar();
            if(c == '/'){
              return COMENT;
            }       
          } 
        }  
      }else{
        ungetc(c,stdin);
        return DIV;
      }
  }
  if(c==',') return COMA;
               
  return c;
}

void yyerror(char *s){
	fprintf(stderr,"%s\n",s);
}

void imprimeTablaSimbolo(){
	for(int i=0;i<nSim;i++){
		printf("%s",tablaDeSimbolos[i].nombre);
		printf("\n");
	}
}

int main() {
        if(!yyparse()){
	         printf("cadena válida\n");
	         imprimeTablaSimbolo();
	}
	else {
	         printf("cadena inválida\n");	
	}
  return 0;
}
