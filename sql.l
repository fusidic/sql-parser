%option header-file="sql.lex.h"

%{
#include <stdio.h>
#include <string.h>
#include "sql.tab.h"
#include "sql-parser.h"
%}

%%

 /* keywords */
ADD                     return ADD;
AND                     return AND;
ALTER                   return ALTER;

BY                      return BY;

CREATE                  return CREATE;
DATABASE                return DATABASE;
DATABASES               return DATABASES;
DELETE                  return DELETE;
DROP                    return DROP;

FROM                    return FROM;

INNER                   return INNER;
INSERT                  return INSERT;

JOIN                    return JOIN;
LEFT                    return LEFT;

ON                      return ON;
OR                      return OR;
ORDER                   return ORDER;
OUTER                   return OUTER;
RIGHT                   return RIGHT;
SCHEMA                  return SCHEMA;
SCHEMAS                 return SCHEMAS;
SELECT                  return SELECT;

UPDATE                  return UPDATE;
USE                     return USE;

WHERE                   return WHERE;
XOR                     return XOR;

    /* operators */
[-+&~|^/%*(),.;!]       return yytext[0];
"&&"                    return ANDOP;
"||"                    return OR;
"="                     yylval->subtok = 4; return 


    /* numbers */
-?[0-9]+                yylval->intval = atoi(yytext); return INTNUM;

    /* booleans */
TRUE                    yylval->intval = 1; return BOOL;
FALSE                   yylval->intval = 0; return BOOL;

zone                    return ZONETOK;
file                    return FILETOK;
[a-zA-Z][a-zA-Z0-9]*    yylval=strdup(yytext); return WORD;
[a-zA-Z0-9\/.-]*        yylval=strdup(yytext); return FILENAME;
\"                      return QUOTE;
\{                      return OBRACE;
\}                      return EBRACE;
;                       return SEMICOLON;
\n                      /* ignore EOL */
[ \t]+                  /* ignore whitespace */
%%