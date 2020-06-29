%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    int yylex();
    void yyerror(char *s);

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

    TNODE* makeTNode(char* val, TNODE* left, TNODE* right)
    {
        TNODE *temp = (TNODE *)malloc(sizeof(TNODE));
        temp->val=val;
        temp->left=left;
        temp->right=right;
        return temp;
    }

    QUERY* makeQuery(char* keyword, QUERY* next, QUERY *subquery, TNODE* subtree)
    {
        QUERY *temp = (QUERY *)malloc(sizeof(QUERY));
        temp->keyword=keyword;
        temp->subquery=subquery;
        temp->subtree=subtree;
        temp->next=next;
        return temp;
    }

    QUERY* attachNextQuery(QUERY* pre, QUERY* af)
    {
        QUERY *head = pre;
        while(pre->next != NULL)
        {
            pre = pre->next;
        }
        pre->next = af;
        return head;
    }

    QUERY* attachSubQuery(QUERY* parent, QUERY* kid)
    {
        QUERY *head = parent;
        while(parent->subquery != NULL)
        {
            parent = parent->subquery;
        }
        parent->subquery = kid;
        return head;
    }

    char table[50][255];
    QUERY* query;
%}

%token ID VAL PL MI DIV MUL COMP ALL AND FROM WHERE SELECT COMPARISON NOT OR NUM

%union{
    typedef struct tnode TNODE;
    char *string;
    TNODE *tnode;
    QUERY *query;
}

%type <string> atom table_ref COMPARISON NOT SELECT FROM WHERE ID VAL PL MI DIV MUL COMP ALL AND OR NUM
%type <tnode> arithmatic_operation scalar_exp search_confition comparison_predicate predicate
%type <query> sql_list sql schema select_statement target_list target table_expression from_clause table_ref_commalist where_clause

%%
sql_list:
        sql ';'     {$$=$1; query=$$;}
    ;
sql:
        schema      {$$=$1;}
    ;

schema:
        select_statement table_expression   {$$=attachNextQuery($1, $2);}
    ;

select_statement:
        SELECT target_list          {$$=makeQuery($1, NULL, $2, NULL);}
    ;
target_list:
        target_list ',' target      {$$=attachSubQuery($1, $3);}
    |   target                      {$$=$1;}
    ;
target:
        VAL                         {$$=makeQuery($1, NULL, NULL, NULL);}
    |   arithmatic_operation        {$$=makeQuery("Cal", NULL, NULL, $1);}
    ;
   
arithmatic_operation:
        VAL DIV NUM     {$$=makeTNode($2, $1, $3);}
    |   NUM DIV VAL     {$$=makeTNode($2, $1, $3);}
    |   VAL MUL NUM     {$$=makeTNode($2, $1, $3);}
    |   NUM MUL VAL     {$$=makeTNode($2, $1, $3);}
    |   VAL PL  NUM     {$$=makeTNode($2, $1, $3);}
    |   NUM PL  VAL     {$$=makeTNode($2, $1, $3);}
    |   VAL MI  NUM     {$$=makeTNode($2, $1, $3);}
    |   NUM MI  VAL     {$$=makeTNode($2, $1, $3);}
    ;

scalar_exp:
        scalar_exp  PL  scalar_exp  {$$=makeTNode($2, $1, $3);}
    |   scalar_exp  MI  scalar_exp  {$$=makeTNode($2, $1, $3);}
    |   scalar_exp  MUL scalar_exp  {$$=makeTNode($2, $1, $3);}
    |   scalar_exp  DIV scalar_exp  {$$=makeTNode($2, $1, $3);}
    |   atom                        {$$=$1;}
    ;
atom:
        VAL                         {$$=$1;}
    |   NUM                         {$$=$1;}
    ;

table_expression:
        from_clause where_clause    {$$=attachNextQuery($1, $2);}
    ;
from_clause:
        FROM table_ref_commalist    {$$=makeQuery($1, NULL, $2, NULL);}
    ;
table_ref_commalist:
        table_ref_commalist ',' table_ref   {$$=attachSubQuery($1, $3);}
    |   table_ref                           {$$=$1;}
    ;
table_ref:
        VAL                                 {$$=$1;}
    ;
where_clause:
        WHERE search_confition              {$$=makeQuery($1, NULL, NULL, $2);}
    ;
search_confition:
        search_confition OR search_confition    {$$=makeTNode($2, $1, $3);}
    |   search_confition AND search_confition   {$$=makeTNode($2, $1, $3);}
    |   NOT search_confition                    {$$=makeTNode($1, NULL, $2);}
    |   '(' search_confition ')'                {$$=$2;}
    |   predicate                               {$$=$1;}
    ;
predicate:
        comparison_predicate                    {$$=$1;}
    ;
comparison_predicate:
        scalar_exp COMPARISON scalar_exp        {$$=makeTNode($2, $1, $3);}
    |   scalar_exp COMPARISON scalar_exp        {$$=makeTNode($2, $1, $3);}
    ;

%%

// 以下函数，将生成 SQL 语法树插入表格中，便于在 terminal 中显示

// initTable
//
// 初始化 table
void initTable(char s[50][255])
{
    for (int i=0; i<50; i++)
        sprintf(s[i], "%255s", " ");
}

// insertTree 
// 
// Usage: 将 subtree 插入表格 s
// 参数 offsetX 横向偏移量，20*n
// 参数 offsetY 纵向偏移量，2 *n
// 返回值 树的宽度，即所有叶节点数目
int insertTree(TNODE *tree, int offsetX, int offsetY, char s[50][255])
{
    char val[11];
    int width = 0;
    if (!tree) 
        return 0;

    // 是否为叶节点
    if (NULL == tree->left && NULL == tree->right)
        width += 1;
    
    sprintf(val, "(%-8s)", tree->val);
    
    int leftWidth = insertTree(tree->left, offsetX+20, offsetY, s);
    int rightWidth = insertTree(tree->right, offsetX+20, offsetY+2*leftWidth, s);

    // insert: tree->val
    for (int i=0; i<10; i++)
    {
        s[offsetY][offsetX+i] = val[i];
    }

    // insert: left branch
    if (NULL != tree->left)
    {
        for (int i=0; i<10; i++)
        {
            s[offsetY][offsetX+i+10] = '-';
        }
    }

    // insert: right branch
    if (NULL != tree->right)
    {
        for (int i=1; i<2*(leftWidth+1)-1; i++)
        {
            s[offsetY+i][offsetX+3] = '|';
        }
        for (int i=3; i<20; i++)
        {
            s[offsetY+2*leftWidth][offsetX+i] = '-';
        }
    }
    width = width + leftWidth + rightWidth;
    return width;
}

// insertSubQuery
//
// Usage: 将 subquery 插入表格 s
// 参数 offsetX 横向偏移量，20*n
// 参数 offsetY 纵向偏移量，2 *n
// 返回值 树的宽度，即所有叶节点数目
int insertSubQuery(QUERY *q, int offsetX, int offsetY, char s[50][255])
{
    char val[11];
    int width = 0;
    if (!q)
        return 0;
    
    // insert: q->keyword
    sprintf(val, "(%-8s)", q->keyword);
    for (int i=0; i<10; i++)
    {
        s[offsetY][offsetX+i] = val[i];
    }

    // 是否为末位 subquery
    if (NULL == q->subquery)
        width += 1;
    else
    {
        width += insertSubQuery(q->subquery, offsetX+20, offsetY, s);
        // insert link line
        for (int i=0; i<10; i++)
        {
            s[offsetY][offsetX+i+10] = '-';
        }
    }

    // 是否有 subtree
    if (NULL != q->subtree)
    {
        width += insertTree(q->subtree, offsetX+20, offsetY+2*width, s);
        // insert branch
        for (int i=1; i<2; i++)
        {
            s[offsetY+i][offsetX+3] = '|';
        }
        for (int i=3; i<20; i++)
        {
            s[offsetY+2][offsetX+i] = '-';
        }
    }
    return width;
}

// insertQuery
int insertQuery(QUERY *q, int offsetY, char s[50][255])
{
    if (!q)
        return offsetY;
    int width = insertSubQuery(q, 0, offsetY, s);
    return insertQuery(q->next, offsetY+width*2-1, s);
}

void postOrder(TNODE* root)
{

}

void inOrder(TNODE* root)
{
    if(root)
    {
        inOrder(root->left);
        fmt.printf("%s ", root->val);
        inOrder(root->right);
    }
}

void yyerror(char *s)
{
    printf("%s\n", s);
}

int yywrap()
{
    return 1;
}

int main(void)
{

    yyparse();
    initTable(table);
    int w = insertQuery(query, 0, table);
    for (int i=0; i<w; i++)
    {
        for (int j=0; j<255; j++)
        {
            printf("%c", table[i][j]);
        }
        printf("\n");
    }
    return 0;
}

