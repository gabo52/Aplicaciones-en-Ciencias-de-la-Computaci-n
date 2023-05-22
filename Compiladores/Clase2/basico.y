%{

/*
librerias y variables
prototipos
*/
#include<stdio.h>
#include<string.h>
#include<ctype.h>
#include<stdlib.h>
void yyerror(char *s);
int yylex();
int genTemp();
char lexema[100];
typedef struct {
	char nombre[100];
	int token;
	double valor;
	int tipo;
}TipoTablaDeSimbolos;

typedef struct {
	int op;
	int a1;
	int a2;
	int a3;
}TipoTablaCod;

TipoTablaCod tablacod[200];


int nSim=0;
int cx=-1;
int nVarTemp=1;

TipoTablaDeSimbolos tablaDeSimbolos[200];
%}

%token  MIENTRAS ID IGUAL NUMENT SUMA CAMBIOLINEA PARIZQ LLAVEDER LLAVEIZQ PARDER RESTA MUL DIV 

%token ASIGNAR SUMAR MULTIPLICAR
%%
/*gramatica*/
programa: listInst ;

listInst: instr listInst;

listInst: ;	

instr: ID {int i=localizaSimbolo(lexema,ID);$$=i;} IGUAL expr {generaCodigo(ASIGNAR,$2,$4,'-');};

expr: expr SUMA term{int i=genTemp();generaCodigo(SUMAR,i,$1,$3);$$=i;};

expr: expr RESTA term;

expr: term;

term: term MUL factor{int i=genTemp();generaCodigo(MULTIPLICAR,i,$1,$3);$$=i;};

term: term DIV factor;

term: factor;

factor: PARIZQ expr PARDER;

factor: NUMENT{ int i=localizaSimbolo(lexema,NUMENT);$$=i;};

factor: ID {int i=localizaSimbolo(lexema,ID);$$=i;};

instr: MIENTRAS PARIZQ expr PARDER bloqinst;

bloqinst : LLAVEIZQ listInst LLAVEDER;
%%

/*codigo C*/
/*análisis léxico*/
int localizaSimbolo(char *lexema, int token){
	for(int i=0;i<nSim;i++){
		if(!strcmp(tablaDeSimbolos[i].nombre,lexema)){
			return i;
		}
	}
	strcpy(tablaDeSimbolos[nSim].nombre,lexema);
	tablaDeSimbolos[nSim].token=token;
	tablaDeSimbolos[nSim].tipo=0;
	if(token==NUMENT){
		tablaDeSimbolos[nSim].valor=atof(lexema);
	}else{
		tablaDeSimbolos[nSim].valor=0.0;
	}
	
	nSim++;
	return nSim-1;
}

int genTemp(){
	int pos;
	char t[10];
	sprintf(t,"_Y%d\n",nVarTemp++);
	pos=localizaSimbolo(t,ID);
	return pos;
}

void generaCodigo(int op, int a1, int a2, int a3){
	cx ++;
	tablacod[cx].op=op;
	tablacod[cx].a1=a1;
	tablacod[cx].a2=a2;
	tablacod[cx].a3=a3;
			
}

int yylex(){
        char c;int i;
	    	c=getchar();
	    	while(c==' ' || c=='\n' || c=='\t'){ c=getchar(); if(c!=' ' && c!='\n' && c!='\t') break;} 
               
                
                if(c=='#') return 0;
		if(isalpha(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isalnum(c));
			ungetc(c,stdin);
			lexema[i++]='\0';
	
                        if(!strcmp(lexema,"while")) return MIENTRAS; 
			//localizaSimbolo(lexema,ID);
			return ID;

		}

                if(isdigit(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isdigit(c));
			ungetc(c,stdin);
			lexema[i++]='\0';
                         
			return NUMENT;
                } 
                 
               if(c=='='){
               		return IGUAL;
               }
               
               if(c=='+'){
               		return SUMA;
               }
               if(c=='-'){
               		return RESTA;
               }
               if(c=='*'){
               		return MUL;
               }
               if(c=='/'){
               		return DIV;
               }
               if(c=='('){
               		return PARIZQ;
               }
               if(c==')'){
               		return PARDER;
               }
               if(c=='}'){
               		return LLAVEDER;
               }
               if(c=='{'){
               		return LLAVEIZQ;
               }
		return c;
	
}
void yyerror(char *s){
	fprintf(stderr,"%s\n",s);
}



void imprimeTablaSimbolo(){
	printf("Tabla de simbolo\n");
	printf("nombre\ttoken\tvalor\n");
	for(int i=0;i<=nSim;i++){
		printf("%s\t%d\t%lf",tablaDeSimbolos[i].nombre,tablaDeSimbolos[i].token,tablaDeSimbolos[i].valor);
		printf("\n");
	}
}

void imprimeTablaCodigo(){
	printf("Tabla de codigo\n");
	printf("nombre\t token\t valor\n");
	for(int i=0;i<=cx;i++){
		printf("%d %d %d %d\n",tablacod[i].op,tablacod[i].a1,tablacod[i].a2,tablacod[i].a3);
		printf("\n");
	}
}

int main(){
        if(!yyparse()){
	         printf("cadena válida\n");
	         imprimeTablaSimbolo();
	         imprimeTablaCodigo();
	}
	else{
	         printf("cadena inválida\n");	
	}
        return 0;
}



