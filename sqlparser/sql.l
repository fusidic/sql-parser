%option header-file="sql.lex.h"

%{
#include <stdio.h>
#include <string.h>
#include "sql1.h"
int lineno = 1;
void yyerror(char *s);
%}

%e 1200
%%

 /* keywords */
ADA                     return ADA;
ALL                     return ALL;
ADD                     return ADD;
AND                     return AND;
ANY                     return ANY;
AS                      return AS;
ASC                     return ASC;
AUTHORIZATION           return AUTHORIZATION;
AVG                     return AVG;

BETWEEN                 return BETWEEN;
BY                      return BY;

C                       return C;
CHAR(ACTER)?            return CHARACTER;
CHECK                   return CHECK;
CLOSE                   return CLOSE;
COBOL                   return COBOL;
COMMIT                  return COMMIT;
CONTINUE                return CONTINUE;
COUNT                   return COUNT;
CREATE                  return CREATE;
CURRENT                 return CURRENT;
CURSOR                  return CURSOR;

DATABASE                return DATABASE;
DATABASES               return DATABASES;
DECIMAL                 return DECIMAL;
DECLARE                 return DECLARE;
DEFAULT                 return DEFAULT;
DELETE                  return DELETE;
DESC                    return DESC;
DISTINCT                return DISTINCT;
DOUBLE                  return DOUBLE;
DROP                    return DROP;

ESCAPE                  return ESCAPE;
EXISTS                  return EXISTS;
FETCH                   return FETCH;
FLOAT                   return FLOAT;
FOR                     return FOR;
FOREIGN                 return FOREIGN;
FORTRAN                 return FORTRAN;
FOUND                   return FOUND;
FROM                    return FROM;

GO[ \t]*TO              return GOTO;
GRANT                   return GRANT;
GROUP                   return GROUP;

HAVING                  return HAVING;

IN                      return IN;
INDICATOR               return INDICATOR;
INNER                   return INNER;
INSERT                  return INSERT;
INT(EGER)?              return INTEGER;
INTO                    return INTO;
IS                      return IS;

KEY                     return KEY;

JOIN                    return JOIN;
LANGUAGE                return LANGUAGE;
LEFT                    return LEFT;
LIKE                    return LIKE;

MAX                     return MAX;
MIN                     return MIN;
MODULE                  return MODULE;

NOT                     return NOT;
NULL                    return NULL;
NUMERIC                 return NUMERIC;

OF                      return OF:
ON                      return ON;
OPEN                    return OPEN;
OPTION                  return OPTION;
OR                      return OR;
ORDER                   return ORDER;
OUTER                   return OUTER;

PASCAL                  return PASCAL;
PLI                     return PLI;
PRECISION               return PRECISION;
PRIMARY                 return PRIMARY;
PRIVILEGES              return PRIVILEGES;
PROCEDURE               return PROCEDURE;
PUBLIC                  return PUBLIC;

REAL                    return REAL;
REFERENCES              return REFERENCES;
RIGHT                   return RIGHT;
ROLLBACK                return ROLLBACK;
SCHEMA                  return SCHEMA;
SCHEMAS                 return SCHEMAS;
SELECT                  return SELECT;
SET                     return SET;
SMALLINT                return SMALLINT;
SOME                    return SOME;
SQLCODE                 return SQLCODE;
SUM                     return SUM;

TABLE                   return TABLE;
TO                      return TO;

UNION                   return UNION;
UNIQUE                  return UNIQUE;
UPDATE                  return UPDATE;
USE                     return USE;
USER                    return USER;

VALUES                  return VALUES;
VIEW                    return VIEW;

WHENEVER                return WHENEVER;
WHERE                   return WHERE;
WITH                    return WITH;
WORK                    return WORK;

XOR                     return XOR;

    /* punctuation */
"="|"<>"|"<"|
">"|"<="|">="           return COMPARISON;

    /* operators */
[-+*/:(),.;]            return yytext[0];

"||"                    return OR;

    /* name */
[A-Za-z][A-Za-z0-9_]*   return NAME;


    /* numbers */
[0-9]+                  |
[0-9]+"."[0-9]*         |
"."[0-9]*               return INTNUM;
-?[0-9]+                yylval->intval = atoi(yytext); return INTNUM;

[0-9]+[eE][+-]?[0-9]+   |
[0-9]+"."[0-9]*[eE][+-]?[0-9]+ |
"."[0-9]*[eE][+-]?[0-9]+    { return APPROXNUM; }

    /* booleans */
TRUE                    yylval->intval = 1; return BOOL;
FALSE                   yylval->intval = 0; return BOOL;

	/* strings */

'[^'\n]*'	{
		int c = input();

		unput(c);	/* just peeking */
		if(c != '\'') {
			return STRING;
		} else
			yymore();
	}
		
'[^'\n]*$	            { yyerror("Unterminated string"); }

\n		                lineno++;
zone                    return ZONETOK;
file                    return FILETOK;
[a-zA-Z][a-zA-Z0-9]*    yylval=strdup(yytext); return WORD;
[a-zA-Z0-9\/.-]*        yylval=strdup(yytext); return FILENAME;
\"                      return QUOTE;
\{                      return OBRACE;
\}                      return EBRACE;
;                       return SEMICOLON;
[ \t]+                  /* ignore whitespace */
%%

void
yyerror(char *s)
{
    printf(%d: %s at %s\n", lineno, s, yytext);
}

main(int ac, char **av)
{
    if(ac > 1 && (yyin = fopen(av[1], "r")) == NULL) {
        perror(av[1]);
        exit(1);
    }

    if(!yyparse())
        printf("SQL parse worked\n");
    else
        printf("SQL parse failed\n");
} /* main */