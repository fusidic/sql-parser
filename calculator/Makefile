build: calculator.l calculator.y vtable.h
	lex calculator.l
	yacc -d calculator.y
	gcc -DYYDEBUG=1 -o example.pgm y.tab.c lex.yy.c -ll -ly -lm