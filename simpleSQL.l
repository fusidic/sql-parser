%{
    #include <string.h>
    #include <stdio.h>
    #include "y.tab.h"
%}

%%
    /* literal tokens in sql */
ALL		                                yylval.string=strdup(yytext); return ALL;
OR                                      yylval.string=strdup(yytext); return OR;
NOT                                     yylval.string=strdup(yytext); return NOT
AND|and                                 yylval.string=strdup(yytext); return AND;
FROM|from|From                          yylval.string=strdup(yytext); return FROM;
WHERE|where|Where                       yylval.string=strdup(yytext); return WHERE;
SELECT|select|Select                    yylval.string=strdup(yytext); return SELECT;
    /* 
SET|set|Set                             yylval.string=strdup(yytext); return SET;
UPDATE|update|Update                    yylval.string=strdup(yytext); return UPDATE;
DELETE|delete|Delete                    yylval.string=strdup(yytext); return DELETE;
    */

    /* general matching */
[A-Za-z][A-Za-z0-9_]*                   yylval.string=strdup(yytext); return NUM;
([0-9]*\.?[0-9]*)|(\".*?\")|(\'.\')     yylval.string=strdup(yytext); return VAL;
";"                                     return ENDL;
"+"                                     yylval.string=strdup(yytext); return PL;
"-"                                     yylval.string=strdup(yytext); return MI;
"/"                                     yylval.string=strdup(yytext); return DIV;
"*"                                     yylval.string=strdup(yytext); return MUL;
"="|"<"|">"|">="|"<="                   yylval.string=strdup(yytext); return COMPARISON;
[ \t\r\n]                               ;


%%
