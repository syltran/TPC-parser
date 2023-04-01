/* tree.c */
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
extern int lineno;       /* from lexer */

static const char *StringFromLabel[] = {
  "Prog",
  "DeclVarsGlobal", "DeclarateursGlobal", "DeclVarsLocal", "DeclarateursLocal", "InitVars",
  "DeclFoncts", "DeclFonct", "EnTeteFonct", "Parametres", "ListTypVar", "Corps",
  "SuiteInstr", "Instr", "Exp", "TB", "FB", "M", "E", "T", "F", "LValue", "Arguments", "ListExp",
  "void", "if", "else", "while", "return",
  "eq", "order",
  "addsub", "divstar",
  "or", "and",
  "character",
  "num",
  "type",
  "ident",
  "assign",
  "neg"
  /* list all other node labels, if any */
  /* The list must coincide with the label_t enum in tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

Node *makeNode(label_t label, type_attr type, ...) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }

  va_list ap;
  va_start(ap, type);
  /* we only fill the variable in the union attr which corresponds to the attribute's type 'type' */
  switch(type) {
    case INT: 
      node->attr.num = va_arg(ap, int);
      break;
    case OP_CHAR:
      node->attr.op_byte = va_arg(ap, int);
      break;
    case OP_STRING:
      strcpy(node->attr.op, va_arg(ap, char *));
      break;
    case NAME_STRING:
      strcpy(node->attr.name, va_arg(ap, char *));
      break;
    default: ;
  }
  va_end(ap);
  node->type = type;

  node->label = label;
  node->firstChild = node->nextSibling = NULL;
  node->lineno=lineno;
  return node;
}

void addSibling(Node *node, Node *sibling) {
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteChild(Node *parent, Node *child) {
  Node *node, *tmp;

  if (parent->firstChild == child){
    node = parent->firstChild;
    parent->firstChild = parent->firstChild->nextSibling;
    free(node);
    return;
  }

  tmp = parent->firstChild;
  while (tmp->nextSibling != child){
    tmp = tmp->nextSibling;
  }
  node = tmp->nextSibling;
  tmp->nextSibling = node->nextSibling;
  free(node);
}

void deleteTree(Node *node) {
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node);
}

void printTree(Node *node) {
  static bool rightmost[128]; // tells if node is rightmost sibling
  static int depth = 0;       // depth of current node
  for (int i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = L form; 2500 = horizontal line; 251c = vertical line and right horiz 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }

  switch(node->type) {
    case NODE:
      printf("%s", StringFromLabel[node->label]);
      break;
    case INT: 
      printf("%d", node->attr.num);
      break;
    case OP_CHAR:
      if (node->attr.op_byte == '=') printf("Assign");
      else printf("%c", node->attr.op_byte);
      break;
    case OP_STRING:
      printf("%s", node->attr.op); 
      break;
    case NAME_STRING:
      if (node->label == type) printf("Type (%s)", node->attr.name);
      else if (node->label == ident) printf("Ident (%s)", node->attr.name);
      else printf("%s", node->attr.name);
      break;
    default: ;
  }
  printf("\n");
  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}
