%{

/*
librerias y variables
prototipos
*/
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<ctype.h>
void yyerror(char *s);
int yylex();
int copiaRegistro(int i);
int localizaSimbolo(char *lexema, int token,int indice);
char lexema[100];
typedef struct {
	char nombre[100];
	int token;
	double valor;
	int tipo;
}TipoTablaDeSimbolos;
int genTemp(int indice);
void InicializarReg(int Rx);
void interpretaCodigo(int indice);
void generaCodigo(int op,int a1,int a2 , int a3,int indice);
typedef struct {
	int op;
        int a1;
        int a2;
        int a3;
}TipoTablaCod;
//TipoTablaCod tablaCod[200];

//TipoTablaDeSimbolos tablaDeSimbolos[200];


typedef struct{
        int nSim;
        int cx;
        int nVarTemp;        
        TipoTablaDeSimbolos tablaDeSimbolos[200];
        TipoTablaCod tablaCod[200];
}tipoRegistroAct;
tipoRegistroAct RegAct[100];
int nReg=0;

typedef struct{
        char nombre[100];
        int posReg;
}
tipoListFunciones;
tipoListFunciones listaFunciones[100];
 
int Rx=0;
%}

%token  MIENTRAS ID IGUAL NUMENT SUMA CAMBIOLINEA  LLAVEDER LLAVEIZQ PARDER RESTA MUL DIV PARIZQ SI SINO IMPRESION BEGIN END  BEGINFUN   ENDFUN NOMBFUNC LLAMARFUNC
%token  ASIGNAR SUMAR MULTIPLICAR MAYORQUE SALTARF SALTAR RESTAR IMPRIMIR SALTARV MENORQUE
 

%%
/*gramatica*/

programa: BEGIN {InicializarReg(Rx); nReg++;  } listInst END{Rx++;}listFunc;

listFunc: funcion listFunc;
listFunc: ;
listInst: instr listInst;
funcion: BEGINFUN {InicializarReg(Rx); nReg++;  }   ID {int i= localizaSimbolo(lexema,NOMBFUNC,Rx);$$=i;} listInst  ENDFUN {Rx++;};

listInst: ;

instr: ID {int i= localizaSimbolo(lexema,NOMBFUNC,Rx);$$=i;} {int i =copiaRegistro($2);$$=i;} PARIZQ PARDER {generaCodigo(LLAMARFUNC,$3,'-','-',Rx);} ;

instr: ID {int i= localizaSimbolo(lexema,ID,Rx);$$=i;} IGUAL expr  {generaCodigo(ASIGNAR
,$2,$4,'-',Rx); }

expr: expr SUMA term {int i= genTemp(Rx) ;generaCodigo(SUMAR,i,$1,$3,Rx);$$=i;} ;

expr: expr RESTA term {int i= genTemp(Rx) ;generaCodigo(RESTAR,i,$1,$3,Rx);$$=i;} ;

expr: term;


term: term MUL factor {int i= genTemp(Rx) ;generaCodigo(MULTIPLICAR,i,$1,$3,Rx);$$=i;} ;

term: term DIV factor;

term: factor;

factor: PARIZQ expr PARDER;

factor: NUMENT{int i= localizaSimbolo(lexema,NUMENT,Rx);$$=i;};

factor: ID {int i=localizaSimbolo(lexema,ID,Rx);$$=i;};

cond: expr '>' expr {int i=genTemp(Rx); generaCodigo(MAYORQUE,i ,$1,$3,Rx);$$=i;};
cond: expr '<' expr {int i=genTemp(Rx); generaCodigo(MENORQUE,i ,$1,$3,Rx);$$=i;};


instr: SI PARIZQ  cond  { generaCodigo(SALTARF,$3,'?','-',Rx); $$=RegAct[Rx].cx; }  PARDER bloqinst { generaCodigo(SALTAR,'?','-','-',Rx); $$=RegAct[Rx].cx; }   {RegAct[Rx].tablaCod[$4].a2=RegAct[Rx].cx+1;} bloqueSino {RegAct[Rx].tablaCod[$7].a1=RegAct[Rx].cx+1;};


bloqueSino: SINO bloqinst ;
bloqueSino:;
instr : IMPRESION ID {int i=localizaSimbolo(lexema,ID,Rx);$$=i;} { generaCodigo(IMPRIMIR,$3,'-','-',Rx);} ;

instr: MIENTRAS PARIZQ {$$=RegAct[Rx].cx+1;} cond { generaCodigo(SALTARF,$4,'?','-',Rx); $$=RegAct[Rx].cx; }  PARDER bloqinst { generaCodigo(SALTAR,$3, '-','-',Rx);$$=RegAct[Rx].cx;   }   {RegAct[Rx].tablaCod[$5].a2=RegAct[Rx].cx+1;}  ;

bloqinst : LLAVEIZQ listInst LLAVEDER;
%%

/*codigo C*/
/*análisis léxico*/

int copiaRegistro(int i){
nReg++;
        RegAct[nReg].cx=RegAct[i].cx;
        RegAct[nReg].nSim=RegAct[i].nSim;
        for(int j=0;j<=RegAct[nReg].nSim;j++){
                RegAct[nReg].tablaDeSimbolos[j].tipo=RegAct[i].tablaDeSimbolos[j].tipo;
               RegAct[nReg].tablaDeSimbolos[j].valor=RegAct[i].tablaDeSimbolos[j].valor;
RegAct[nReg].tablaDeSimbolos[j].token=RegAct[i].tablaDeSimbolos[j].token; strcpy(RegAct[nReg].tablaDeSimbolos[j].nombre,RegAct[i].tablaDeSimbolos[j].nombre);

        }
        for(int j=0;j<RegAct[nReg].cx;j++){
            RegAct[nReg].tablaCod[j].op=   RegAct[i].tablaCod[j].op; 
            RegAct[nReg].tablaCod[j].a1=   RegAct[i].tablaCod[j].a1; 
            RegAct[nReg].tablaCod[j].a2=   RegAct[i].tablaCod[j].a2; 
            RegAct[nReg].tablaCod[j].a3=   RegAct[i].tablaCod[j].a3; 
        }

        


}
void InicializarReg(int Rx){
        RegAct[Rx].nSim=0;
        RegAct[Rx].cx=-1;
        RegAct[Rx].nVarTemp=1;     
        
}
void imprimeFunciones(){
        for(int i=0;i<nReg;i++){
                printf("%s %d ",listaFunciones[i].nombre,listaFunciones[i].posReg);
        }
}
int localizaSimbolo(char *lexema, int token,int indice){
        if(token==NOMBFUNC){
                for(int i=0;i<nReg;i++){
		        if(!strcmp(listaFunciones[i].nombre,lexema)){
			        return i;
		        }
	        }
                strcpy(listaFunciones[indice].nombre,lexema);
                listaFunciones[indice].posReg=indice;
                               
        }
        else{


	        for(int i=0;i<RegAct[indice].nSim;i++){
		        if(!strcmp(RegAct[indice].tablaDeSimbolos[i].nombre,lexema)){
			        return i;
		        }
	        }
	        strcpy(RegAct[indice].tablaDeSimbolos[RegAct[indice].nSim].nombre,lexema);
	        RegAct[indice].tablaDeSimbolos[RegAct[indice].nSim].token=token;
	        RegAct[indice].tablaDeSimbolos[RegAct[indice].nSim].tipo=0;
                if (token==NUMENT){ 
                        RegAct[indice].tablaDeSimbolos[RegAct[indice].nSim].valor=atof(lexema);     
                }
                else {
	                RegAct[indice].tablaDeSimbolos[RegAct[indice].nSim].valor=0.0;
                }	
                RegAct[indice].nSim++;
	        return RegAct[indice].nSim-1;
        }
}

int genTemp(int indice){
        int pos;
        char t[10];
        sprintf(t,"_T%d",RegAct[indice].nVarTemp++);
        pos=localizaSimbolo(t,ID,indice);
        return pos;        
}

void interpretaCodigo(int indice){
        int i,op,a1,a2,a3;
        for (i=0;i<=RegAct[indice].cx;i=i+1) {
                op=RegAct[indice].tablaCod[i].op;
                a1=RegAct[indice].tablaCod[i].a1 ;
                a2=RegAct[indice].tablaCod[i].a2 ;
                a3=RegAct[indice].tablaCod[i].a3 ;
                if (op==LLAMARFUNC){
                        interpretaCodigo(a1);

                }
                if(op==RESTAR){
                                RegAct[indice].tablaDeSimbolos[a1].valor=RegAct[indice].tablaDeSimbolos[a2].valor-RegAct[indice].tablaDeSimbolos[a3].valor;
                }   
                if(op==SUMAR){
                                RegAct[indice].tablaDeSimbolos[a1].valor=RegAct[indice].tablaDeSimbolos[a2].valor+RegAct[indice].tablaDeSimbolos[a3].valor;
                }   
                if(op==MULTIPLICAR){
                                RegAct[indice].tablaDeSimbolos[a1].valor=RegAct[indice].tablaDeSimbolos[a2].valor*RegAct[indice].tablaDeSimbolos[a3].valor;
                }   
                if(op==IMPRIMIR){
                                printf("%lf",RegAct[indice].tablaDeSimbolos[a1].valor );
                } 
                if(op==SALTAR){
                        i=a1-1;
                }   
                if(op==SALTARF){
                        if(RegAct[indice].tablaDeSimbolos[a1].valor==0)
                                i=a2-1;
        
                }   
                if(op==SALTARV){
                        if(RegAct[indice].tablaDeSimbolos[a1].valor==1)
                                i=a2-1;
                }   
                if(op==MAYORQUE){
                        if(RegAct[indice].tablaDeSimbolos[a2].valor>RegAct[indice].tablaDeSimbolos[a3].valor)
                                RegAct[indice].tablaDeSimbolos[a1].valor=1;
                        else
                                RegAct[indice].tablaDeSimbolos[a1].valor=0;
                }  
                if(op==MENORQUE){
                        if(RegAct[indice].tablaDeSimbolos[a2].valor>RegAct[indice].tablaDeSimbolos[a3].valor)
                                RegAct[indice].tablaDeSimbolos[a1].valor=1;
                        else
                                RegAct[indice].tablaDeSimbolos[a1].valor=0;
                }  
                if(op==ASIGNAR){
                                RegAct[indice].tablaDeSimbolos[a1].valor=RegAct[indice].tablaDeSimbolos[a2].valor;
                }      
        }

}
void generaCodigo(int op,int a1,int a2 , int a3,int indice){
        RegAct[indice].cx++;        
        RegAct[indice].tablaCod[RegAct[indice].cx].op=op;
        RegAct[indice].tablaCod[RegAct[indice].cx].a1=a1;
        RegAct[indice].tablaCod[RegAct[indice].cx].a2=a2;
        RegAct[indice].tablaCod[RegAct[indice].cx].a3=a3;

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
	                if(!strcmp(lexema,"if")) return SI; 
                        if(!strcmp(lexema,"else")) return SINO; 
                        if(!strcmp(lexema,"while")) return MIENTRAS;
                        if(!strcmp(lexema,"print")) return IMPRESION;
                        if(!strcmp(lexema,"begin")) return BEGIN;
                        if(!strcmp(lexema,"end")) return END;
                        if(!strcmp(lexema,"funcbegin")) return BEGINFUN;
                        if(!strcmp(lexema,"funcend")) return ENDFUN;
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

void imprimeTablaCodigo(int indice){
        printf("Tabla de codigo %d\n",indice);
        printf("op\ta1\ta2\ta3\n");
	for(int i=0;i<=RegAct[indice].cx;i++){
	if(RegAct[indice].tablaCod[i].op==SUMAR){
                printf("SUMAR ");
        }
	printf("%d\t%d\t%d\t%d\t%d\n",i,RegAct[indice].tablaCod[i].op,RegAct[indice].tablaCod[i].a1,RegAct[indice].tablaCod[i].a2,RegAct[indice].tablaCod[i].a3);
		
	}
}


void imprimeTablaSimbolo(int indice){
        printf("Tabla de simbolo %d\n",indice);
        printf("nombre\ttoken\tvalor\n");

	for(int i=0;i<RegAct[indice].nSim;i++){
		printf("%d\t%s\t%d\t%lf",i,RegAct[indice].tablaDeSimbolos[i].nombre,RegAct[indice].tablaDeSimbolos[i].token,RegAct[indice].tablaDeSimbolos[i].valor);
		printf("\n");
	}
}

void ImprimeRegAct(){
        for(int i=0;i<nReg;i++){
                imprimeTablaSimbolo(i);
                imprimeTablaCodigo(i);
        }
}

int main(){
        if(!yyparse()){
	         printf("cadena válida\n");
                 imprimeFunciones();
	         ImprimeRegAct(); 
                 interpretaCodigo(0);
	         ImprimeRegAct(); 
	}
	else{
	         printf("cadena inválida\n");	
	}
        return 0;
}



