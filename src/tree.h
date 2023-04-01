/* tree.h */

typedef enum {
  /* for non-terminals : */
  Prog,
  DeclVarsGlobal, DeclarateursGlobal, DeclVarsLocal, DeclarateursLocal, InitVars,
  DeclFoncts, DeclFonct, EnTeteFonct, Parametres, ListTypVar, Corps,
  SuiteInstr, Instr, Exp, TB, FB, M, E, T, F, LValue, Arguments, ListExp,
  /* for terminals : */
  _void, _if, _else, _while, _return,
  eq, order,
  addsub, divstar,
  _or, _and,
  character,
  num,
  type,
  ident,
  assign, /* = */
  neg /* ! */
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef enum {
  NODE,
  INT,
  OP_CHAR,
  OP_STRING,
  NAME_STRING
  /* used to know the attribute's type in a node Node */
  /* this enum will be useful to us in the function makeNode and printTree */
} type_attr;

typedef struct Node {
  label_t label;
  
  union {
    /* for node attributes : */
    int num; /* for numeric constants value */
    char op_byte; /* for the operators: +, -, *, /, %, =, ! */
    char op[3]; /* for comparison and boolean operators: ==, !=, <, <=, >, >=, ||, && */
    char name[64]; /* for all the other attributes type: keyword, character, type, ident */
  } attr;
  type_attr type;

  struct Node *firstChild, *nextSibling;
  int lineno;
} Node;

Node *makeNode(label_t label, type_attr type, ...);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
