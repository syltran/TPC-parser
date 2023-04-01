%{
#include <stdio.h>
#include <getopt.h>
#include "tree.h"

int yylex();
int yyerror(char *s);
int tree = 0; /* si tree vaut 1 alors on affiche l’arbre abstrait sur la sortie standard */
extern int lineno;
extern int colno;
extern char *yytext;
extern int yyleng;
%}

%union {
    Node *node;
    char keyw[7];
    char op_comp[3];
    char op_byte;
    char op_bool[3];
    char charac[5];
    int num;
    char type[5];
    char ident[64];
}
/* Les non-terminaux qui ont un attribut */
%type <node> Prog
%type <node> DeclVarsGlobal DeclarateursGlobal DeclVarsLocal DeclarateursLocal InitVars
%type <node> DeclFoncts DeclFonct EnTeteFonct Parametres ListTypVar Corps
%type <node> SuiteInstr Instr Exp TB FB M E T F LValue Arguments ListExp

/* Les terminaux qui ont un attribut */
%token <keyw> VOID IF ELSE WHILE RETURN
%token <op_comp> EQ ORDER
%token <op_byte> ADDSUB DIVSTAR
%token <op_bool> OR AND
%token <charac> CHARACTER
%token <num> NUM
%token <type> TYPE
%token <ident> IDENT


%%
Tree: Prog {if (tree) printTree($1);}
    ;
Prog:  DeclVarsGlobal DeclFoncts {$$ = makeNode(Prog, NODE); 
                                  addChild($$, $1);
                                  /* si DeclVarsGlobal se dérive en epsilon alors je supprime son noeud */
                                  if ($1 != NULL && $1->firstChild == NULL) deleteChild($$, $1);
                                  addChild($$, $2);}
    ;
DeclVarsGlobal:
       DeclVarsGlobal TYPE DeclarateursGlobal ';' {$$ = $1;
                                                   Node *child2 = makeNode(type, NAME_STRING, $2);
                                                   addChild(child2, $3);
                                                   addChild($$, child2);}
    | {$$ = makeNode(DeclVarsGlobal, NODE);}
    ;
DeclarateursGlobal:
       DeclarateursGlobal ',' IDENT {$$ = $1;
                                     Node *child3 = makeNode(ident, NAME_STRING, $3);
                                     addChild($$, child3);}
    |  IDENT {$$ = makeNode(DeclarateursGlobal, NODE);
              Node *child1 = makeNode(ident, NAME_STRING, $1);
              addChild($$, child1);}
    ;
DeclVarsLocal:
       DeclVarsLocal TYPE DeclarateursLocal ';' {$$ = $1;
                                                 Node *child2 = makeNode(type, NAME_STRING, $2);
                                                 addChild(child2, $3);
                                                 addChild($$, child2);}
    | {$$ = makeNode(DeclVarsLocal, NODE);}
    ;
DeclarateursLocal:
       DeclarateursLocal ',' InitVars {$$ = $1; addChild($$, $3);}
    |  InitVars {$$ = makeNode(DeclarateursLocal, NODE); addChild($$, $1);}
    ;
InitVars:
      IDENT '=' Exp {$$ = makeNode(assign, OP_CHAR, '=');
                     Node *child1 = makeNode(ident, NAME_STRING, $1);
                     addChild($$, child1); 
                     addChild($$, $3);}
    | IDENT {$$ = makeNode(ident, NAME_STRING, $1);}
    ;
DeclFoncts:
       DeclFoncts DeclFonct {$$ = $1; addChild($$, $2);}
    |  DeclFonct {$$ = makeNode(DeclFoncts, NODE); addChild($$, $1);}
    ;
DeclFonct:
       EnTeteFonct Corps {$$ = makeNode(DeclFonct, NODE); addChild($$, $1); addChild($$, $2);}
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')' {$$ = makeNode(EnTeteFonct, NODE);
                                      Node *child1 = makeNode(type, NAME_STRING, $1);
                                      Node *child2 = makeNode(ident, NAME_STRING, $2);
                                      addChild(child1, child2);
                                      addChild($$, child1);
                                      addChild($$, $4);}
    |  VOID IDENT '(' Parametres ')' {$$ = makeNode(EnTeteFonct, NODE);
                                      Node *child1 = makeNode(_void, NAME_STRING, $1);
                                      Node *child2 = makeNode(ident, NAME_STRING, $2);
                                      addChild(child1, child2);
                                      addChild($$, child1);
                                      addChild($$, $4);}
    ;
Parametres:
       VOID {$$ = makeNode(Parametres, NODE); 
             Node *child1 = makeNode(_void, NAME_STRING, $1); 
             addChild($$, child1);}
    |  ListTypVar {$$ = makeNode(Parametres, NODE); addChild($$, $1);}
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT {$$ = $1;
                                  Node *child3 = makeNode(type, NAME_STRING, $3);
                                  Node *child4 = makeNode(ident, NAME_STRING, $4);
                                  addChild(child3, child4);
                                  addChild($$, child3);}
    |  TYPE IDENT {$$ = makeNode(ListTypVar, NODE);
                   Node *child1 = makeNode(type, NAME_STRING, $1);
                   Node *child2 = makeNode(ident, NAME_STRING, $2);
                   addChild(child1, child2);
                   addChild($$, child1);}
    ;
Corps: '{' DeclVarsLocal SuiteInstr '}' {$$ = makeNode(Corps, NODE); 
                                         addChild($$, $2); 
                                         /* si DeclVarsLocal se dérive en epsilon alors je supprime son noeud */
                                         if ($2 != NULL && $2->firstChild == NULL) deleteChild($$, $2);
                                         addChild($$, $3);
                                         /* si SuiteInstr se dérive en epsilon alors je supprime son noeud */
                                         if ($3 != NULL && $3->firstChild == NULL) deleteChild($$, $3);
                                        }
    ;
SuiteInstr:
       SuiteInstr Instr {$$ = $1; addChild($$, $2);}
    | {$$ = makeNode(SuiteInstr, NODE);}
    ;
Instr:
       LValue '=' Exp ';' {$$ = makeNode(assign, OP_CHAR, '='); addChild($$, $1); addChild($$, $3);}
    |  IF '(' Exp ')' Instr {$$ = makeNode(_if, NAME_STRING, $1); addChild($$, $3); addChild($$, $5);}
    |  IF '(' Exp ')' Instr ELSE Instr {$$ = makeNode(_if, NAME_STRING, $1); 
                                        addChild($$, $3); 
                                        addChild($$, $5);
                                        Node *child6 = makeNode(_else, NAME_STRING, $6); 
                                        addChild(child6, $7);
                                        addChild($$, child6);}
    |  WHILE '(' Exp ')' Instr {$$ = makeNode(_while, NAME_STRING, $1); addChild($$, $3); addChild($$, $5);}
    |  IDENT '(' Arguments  ')' ';' {$$ = makeNode(ident, NAME_STRING, $1); addChild($$, $3);}
    |  RETURN Exp ';' {$$ = makeNode(_return, NAME_STRING, $1); addChild($$, $2);}
    |  RETURN ';' {$$ = makeNode(_return, NAME_STRING, $1);}
    |  '{' SuiteInstr '}' {$$ = $2;}
    |  ';' {$$ = NULL;}
    ;
Exp :  Exp OR TB {$$ = makeNode(_or, OP_STRING, $2); addChild($$, $1); addChild($$, $3);}
    |  TB
    ;
TB  :  TB AND FB {$$ = makeNode(_and, OP_STRING, $2); addChild($$, $1); addChild($$, $3);}
    |  FB
    ;
FB  :  FB EQ M {$$ = makeNode(eq, OP_STRING, $2); addChild($$, $1); addChild($$, $3);}
    |  M
    ;
M   :  M ORDER E {$$ = makeNode(order, OP_STRING, $2); addChild($$, $1); addChild($$, $3);}
    |  E
    ;
E   :  E ADDSUB T {$$ = makeNode(addsub, OP_CHAR, $2); addChild($$, $1); addChild($$, $3);}
    |  T
    ;    
T   :  T DIVSTAR F {$$ = makeNode(divstar, OP_CHAR, $2); addChild($$, $1); addChild($$, $3);}
    |  F
    ;
F   :  ADDSUB F {$$ = makeNode(addsub, OP_CHAR, $1); addChild($$, $2);}
    |  '!' F {$$ = makeNode(neg, OP_CHAR, '!'); addChild($$, $2);}
    |  '(' Exp ')' {$$ = $2;}
    |  NUM {$$ = makeNode(num, INT, $1);}
    |  CHARACTER {$$ = makeNode(character, NAME_STRING, $1);}
    |  LValue
    |  IDENT '(' Arguments  ')' {$$ = makeNode(ident, NAME_STRING, $1); addChild($$, $3);}
    ;
LValue:
       IDENT {$$ = makeNode(ident, NAME_STRING, $1);}
    ;
Arguments:
       ListExp
    | {$$ = NULL;}
    ;
ListExp:
       ListExp ',' Exp {$$ = $1; addChild($$, $3);}
    |  Exp {$$ = makeNode(ListExp, NODE); addChild($$, $1);}
    ;
%%


int yyerror(char *s){
    fprintf(stderr, "%s : line:%d, character n°%d, lexeme:%s\n", s, lineno, colno - yyleng + 1, yytext);
    return 0;
}

int main(int argc, char *argv[]){
    int opt;
    int err = 0; /* 1 s'il y a une erreur en ligne de commande, O sinon */
    int help = 0; /* 1 s'il y a l'option -h ou --help, 0 sinon */
    static struct option long_opt[] = {
        {"tree", no_argument, NULL, 't'},
        {"help", no_argument, NULL, 'h'},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "th", long_opt, NULL)) != -1){
        /* si opt = -1 alors il n'y a plus d'options à traiter.
        une option commence par "-" ou "--" */
        switch(opt){
            case 't': /* on affiche l’arbre abstrait sur la sortie standard */
                tree = 1;
                break;
            case 'h': /* on affiche une description de l’interface utilisateur et termine l’exécution */
                help = 1;
                break;
            default: /* l'option n'existe pas */
                err = 1;
                break;
        }
    }

    if (optind < argc){ /* il y a des args qui ne sont pas des options */
        for (; optind < argc; optind++){
            printf("not a option: %s\n", argv[optind]); 
        }
        err = 1;
    }

    if (err) return 2;
    if (help){
        printf("Usage: %s [-h | --help | -t | --tree] < filename.tpc\n", argv[0]);
        return 0;
    }
    return yyparse();
}
