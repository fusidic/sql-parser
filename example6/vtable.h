#define NSYMS 20  // 最大存储变量的数量

struct symtab {
    char *name;
    double (*funcptr)();    // 学到了
    double value;
} symtab[NSYMS];

struct symtab *symlook();