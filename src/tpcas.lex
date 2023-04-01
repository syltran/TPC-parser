%{
#include "tree.h"
#include "tpcas.tab.h"
#include <stdlib.h>
#include <string.h>

int lineno = 1;
int colno = 0;
%}
%x COMMENT
%option nounput
%option noinput


%%
\/\* BEGIN COMMENT;
<COMMENT>\n {lineno++; colno = 0;}
<COMMENT>. colno++;
<COMMENT>\*\/ {colno += 2; BEGIN INITIAL;}
\/\/.* ;

void {colno += 4; strcpy(yylval.keyw, yytext); return VOID;}
if {colno += 2; strcpy(yylval.keyw, yytext); return IF;}
else {colno += 4; strcpy(yylval.keyw, yytext); return ELSE;}
while {colno += 5; strcpy(yylval.keyw, yytext); return WHILE;}
return {colno += 6; strcpy(yylval.keyw, yytext); return RETURN;}

==|!= {colno += 2; strcpy(yylval.op_comp, yytext); return EQ;}
\<|\<=|\>|\>= {colno += yyleng; strcpy(yylval.op_comp, yytext); return ORDER;}
[+-] {colno++; yylval.op_byte = yytext[0]; return ADDSUB;}
[*/%] {colno++; yylval.op_byte = yytext[0]; return DIVSTAR;}
\|\| {colno += 2; strcpy(yylval.op_bool, yytext); return OR;}
&& {colno += 2; strcpy(yylval.op_bool, yytext); return AND;}

'[a-zA-Z0-9!"#$%&*+,-./:;=?@^_`~\(\)\<\>\[\]\{\}\| ]'|'\\n'|'\\t'|'\\r'|'\\''|'\\\\' {colno += 3;
                                                                                      strcpy(yylval.charac, yytext); 
                                                                                      return CHARACTER;}
[0-9]+ {colno += yyleng; yylval.num = atoi(yytext); return NUM;}
int|char {colno += yyleng; strcpy(yylval.type, yytext); return TYPE;}
[a-zA-Z_][a-zA-z_0-9]* {colno += yyleng; strcpy(yylval.ident, yytext); return IDENT;}

=|! {colno++; return yytext[0];}
;|, {colno++; return yytext[0];}
\(|\) {colno++; return yytext[0];}
\{|\} {colno++; return yytext[0];}

\n {lineno++; colno = 0;}
[ \t\r]* colno += yyleng;
. {colno++; return yytext[0];}
%%
