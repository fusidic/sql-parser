build:
	lex simpleSQL.l
	yacc -d simpleSQL.y
	gcc lex.yy.c y.tab.c -ll

run:
	./a.out < in.txt