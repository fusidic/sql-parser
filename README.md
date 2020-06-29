# DBMS project - SimpleSQL parser

## 准备工作与相关环境

本文的目的是实现一个 SQL 语句子集的解析器，预留足够的扩展空间，便于之后扩充所能处理的语句。

实验环境：

+ Ubuntu 18.04
+ gcc version 7.5.0 (Ubuntu 7.5.0-3ubuntu1~18.04)
+ lex && yacc

源码：https://github.com/fusidic/sql-parser

<br/>

## 相关原理

仅仅针对 sql 语句的解析，其实一定程度上是编译原理相关的内容，需要用到 lex 与 yacc。当然这里也不可能完整地说明二者的使用方式，可以参见后文[参考文献](#reference)。

从形式上，lex 与 yacc 程序都通过双百分号将整个程序结构分为三段：**定义声明**、**语法规则**、和 **C 代码** ，由于最初 lex 与 yacc 的诞生就是为了简化 C 语言的开发，所以原生的 lex 与 yacc 最终都会生成为 C 代码。当然其他语言也是有支持的，具体语法规则相差不大，只是会生成对应语言的解析器代码。

### lex

lex 常用于编译程序时，对程序文本中的保留字、关键词、变量等进行词法上的解析。

通常可以撰写一个 `.l` 后缀名的文本，利用正则表达式匹配对应的单词，并可以为每个单词匹配一个对应的动作，lex 与 C 是强耦合的，可以将一个 `.lex`  (即 `.l`) 生成为一个 C 的输出文件，并编译为一个词法解析器的可执行版本。

将文本输入这个可执行文件，每完成一个匹配，将会执行对应的动作 (比如返回相应的标记) ；如果没有可以匹配的常规表达式，将会停止进一步处理，这时会显示一个错误信息。

<br/>

### yacc

yacc 文件对 lex 词法分析 (即识别单词) 的基础之上完成语法分析，利用巴科斯范式 (BNF, Backus Naur Form) 进行书写。

用 Yacc 来创建一个编译器包括四个步骤：

> 1. 通过在语法文件上运行 Yacc 生成一个解析器。
> 2. 说明语法：
> 	- 编写一个 .y 的语法文件（同时说明 C 在这里要进行的动作）。
> 	- 编写一个词法分析器来处理输入并将标记传递给解析器。 这可以使用 Lex 来完成。
> 	- 编写一个函数，通过调用 yyparse() 来开始解析。
> 	- 编写错误处理例程（如 yyerror()）。
> 3. 编译 Yacc 生成的代码以及其他相关的源文件。
> 4. 将目标文件链接到适当的可执行解析器库。

在书写 yacc 文件的过程中，以下几个地方需要注意：

**%token %type**

在 yacc 文件中，对输入文件中的每个 symbol 进行标记，通常使用 `%token`，由于 C 语言特性的原因，`%token` 中的关键词事实上是被当作整型来处理的。

当然如果使用 `%type` 对 symbol 进行了定义，yacc 会进行类型检查，将会把对应的 symbol 视为对应类型而非整型。

**yylval**
如果由函数返回的标记关联一个重要的数值，yylex应该将该值放在这个全局变量中。

缺省情况下，`yyval` 为 `long` 型。定义区域可使用 `%union` 定义来使用其它的数据类型，包括结构。如果使用 `-d` 选项运行 yacc，全部的 `yylval` 定义被写入可被 lex 访问的文件 <y.tab.h> 中。

**%union**
yacc 维护了一个栈来保存 `token` 的“属性值”，这个栈与移进-归约分析中的文法符号栈是对应的，即如果移进归约分析栈中某个位置存放文法符号X，则对应Yacc“属性值”栈中就存放X的属性值。
yacc 中属性值栈栈内元素的类型定义为 YYSTYPE ，默认情况下为 int 类型，当然也可以在定义段(第一段)中将其定义为其他类型，如下：

```c
#define YYSTYPE double
```
但是更为普遍和方便的用法是，使用 `%union` 定义 `yylval` 的结构体，来存放多种类型的属性值。

如：
```yacc
%union{
	int number;
	char *str;
}
```
此时相当于将 YYSTYPE 定义为了这个联合体的类型，这样一来，可以使用更为精细的 `yylval.number` 与 `yylval.str` 来获取文本内容了。

更进一步，可以直接使用
```yacc
%token <number> STATE
%token <number> NUMBER
%token <str> WORD
```
直接将 tokens 对号入座。

**归约**
归约在语法分析中是一个非常重要的概念，归约意味着“一句话说完了”，代表着一段表述、功能、意义的终结。看下面这个规则段定义的归约规则：

```yacc
expr : expr PLUS term      {$$ = $1 + $3;}      | term      {$$ = $1;}      ;
```
上述例子中，归约 `expr PLUS term` 为 `expr` 时，将会做如下操作：
+ 从属性值栈中取出产生式右部 expr 的属性值 `$1` 和 term 的属性值 `$3`
+ 将两者的和存入属性值栈中对应产生式左部的expr的属性值的位置 `$$`
+ 归约 term 为 expr 时，则将 term 的属性`$1`存入产生式左部 expr 的属性值`$$`中。

注意，**能**出现在产生式左侧的符号都是“非终结符”，此处 expr 与 term 都是非终结符，而 PLUS 为“终结符”

<br/>

## 部分代码解析

lex 直接见源码，内容比较简单。

在 yacc 中，很多东西是自己摸索的，可能在某种意义上犯了常识性错误，请见谅。

### 数据结构

针对 sql 语句解析中所需要处理的一些点，设计了一个简单的数据结构，可以将一条 sql 语句中的所有元素都用该数据结构进行处理，如下：

```c
typedef struct tnode {
  struct tnode *left, *right;
  char* val;
}TNODE;

typedef struct sqlquery {
  char* keyword;
  TNODE* subtree;
  struct sqlquery *subquery;
  struct sqlquery *next;
}QUERY;
```

理论上我们需要将 sql 语句解析为一个语法树，但是单纯的树的结构似乎并不能满足这个要求。

如 `SELECT` `FROM` `WHERE` 等都作为 `sqlquery` 节点进行存储，以类似链表的形式相连接 (`SLECET->next` 即 `FROM`)。而各个节点的子句，将会按顺序存入 `subquery` 中，也是以类似链表的形式相连。

上述二者构成了一个类似“十字链表”这样的结构，当然这还是不够的，因为在处理如 **比较**、**筛选**、**算术运算**、**逻辑运算** 的时候，树是一个更好的存储方式，这也是设计 `tnode` 的原因。

### 函数设计

接下来的关键是，如何将词法分析的结果，分别放到它们该去的数据结构中，并将这些数据结构**连**起来。

为了完成这个需求，需要在 yacc 定义段中加入几个必须的函数：

```c
// 生成树节点
TNODE* makeTNode(char* val, TNODE* left, TNODE* right)

// 生成 query 节点
QUERY* makeQuery(char* keyword, QUERY* next, QUERY *subquery, TNODE* subtree)
  
// 将 af 作为 pre 的 nextquery 相连
QUERY* attachNextQuery(QUERY* pre, QUERY* af)
 
// 将 kid 作为 parent 的 subquery 相连
QUERY* attachSubQuery(QUERY* parent, QUERY* kid)
  
```

这样一来，我们就有足够的能力将各个部分分别安置好，问题变成了**如何将这些嵌入到 yacc 中？**

## 嵌入语法规则

基于前文的认知，在**语法规则**段作出了以下设计：

```c
%%
sql_list:
        sql ';'     {$$=$1; query=$$;}
    ;
sql:
        schema      
    ;

schema:
        select_statement table_expression   
    ;

select_statement:
        SELECT target_list          
    ;
target_list:
        target_list ',' target      
    |   target                      
    ;
target:
        VAL                         
    |   arithmatic_operation        
    ;
   
arithmatic_operation:
        VAL DIV NUM     
    |   NUM DIV VAL     
    |   VAL MUL NUM     
    |   NUM MUL VAL     
    |   VAL PL  NUM     
    |   NUM PL  VAL     
    |   VAL MI  NUM     
    |   NUM MI  VAL     
    ;

scalar_exp:
        scalar_exp  PL  scalar_exp  
    |   scalar_exp  MI  scalar_exp  
    |   scalar_exp  MUL scalar_exp  
    |   scalar_exp  DIV scalar_exp  
    |   atom                        
    ;
atom:
        VAL                         
    |   NUM                         
    ;

table_expression:
        from_clause where_clause    
    ;
from_clause:
        FROM table_ref_commalist    
    ;
table_ref_commalist:
        table_ref_commalist ',' table_ref   
    |   table_ref                           
    ;
table_ref:
        VAL                                 
    ;
where_clause:
        WHERE search_confition              
    ;
search_confition:
        search_confition OR search_confition    
    |   search_confition AND search_confition   
    |   NOT search_confition                    
    |   '(' search_confition ')'                
    |   predicate                               
    ;
predicate:
        comparison_predicate                    
    ;
comparison_predicate:
        scalar_exp COMPARISON scalar_exp        
    |   scalar_exp COMPARISON scalar_exp        
    ;
%%
```

看起来，对于一个 sql 功能子集来说似乎稍显繁琐了，但是这里其实也为之后扩充匹配集留下了空间：

+ `sql_list` ：匹配多条 sql 语句，~~暂时还有些问题~~ ，以 `';'` 作为间隔；
+ `schema` : 对 sql 语言范式进行规定，暂时只包括 `select` 语句相关，之后可以在这里进行扩充其他规则的匹配；
+ `select_statement` : 匹配 SELECT 及其子句，如 `SELECT eno, name` ；
+ `target_list` ：上述 SELECT 可能有多个查询对象，通过该规则进行匹配；
+ `target` ：上述 list 的成员，可以包括变量或者算术表达式；
+ `arithmetic_operation` : 仅匹配 SELECT 子句内的算术表达式，因为这里无法出现 `VAL/VAL` 这样的操作 ；
+ `scalar_exp` : 这个才是完整的算数表达式，放在 `arithmetic_operation` 后面，防止影响后者的匹配；
+ `table_expression` : 包括 FROM 与 WHERE，匹配数据表与对应的数据项；
+ `search_confition` : 匹配逻辑表达式；
+ `predicate` ：匹配谓词表达式，主要是“比较”规则。

## 执行

```bash
$ make run
```

<span id="reference"></span>

## 参考

+ lex and yacc,  O'Relly John R.Levine, Tony Mason
+ The Lex & Yacc Page, http://dinosaur.compilertools.net
+ 编译技术，从BNF范式到文法识别简介, https://blog.csdn.net/xfxyy_sxfancy/article/details/44854197
+ YACC（BISON）使用指南,  https://blog.csdn.net/wp1603710463/article/details/50365640