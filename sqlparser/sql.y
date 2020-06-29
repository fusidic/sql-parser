%union {
    int intval;
    double floatval;
    char *strcal;
    int subtok;
}

%token NAME
%token STRING
%token INTNUM APPROXNUM

    /* operators priorities */
%left OR
%left AND
%left NOT
%left COMPARISON    /* = <> < > <= >= */
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

    /* literal keyword tokens */

%token ALL AMMSC ANY AS ASC AUTHORIZATION BETWEEN BY
%token CHARACTER CHECK CLOSE COMMIT CONTINUE CREATE CURRENT
%token CURSOR DECIMAL DECLARE DEFAULT DELETE DESC DISTINCT DOUBLE
%token ESCAPE EXISTS FETCH FLOAT FOR FOREIGN FOUND FROM GOTO
%token GRANT GROUP HAVING IN INDICATOR INSERT INTEGER INTO
%token IS KEY LANGUAGE LIKE MODULE NULLX NUMERIC OF ON
%token OPEN OPTION ORDER PRECISION PRIMARY PRIVILEGES PROCEDURE
%token PUBLIC REAL REFERENCES ROLLBACK SCHEMA SELECT SET
%token SMALLINT SOME SQLCODE SQLERROR TABLE TO UNION
%token UNIQUE UPDATE USER VALUES VIEW WHENEVER WHERE WITH WORK
%token COBOL FORTRAN PASCAL PLI C ADA

%%
sql_list:   
        sql ';'
    |   sql_list sql ';'
    ;
sql:        
        schema
    |   manipulative_statement
    ;
schema:
        CREATE SCHEMA AUTHORIZATION user opt_schema_element_list
    ;
opt_schema_element_list:
        /* empty */
    |   schema_element_list
    ;
schema_element_list:
        schema_element
    |   schema_element_list schema_element
    ;
schema_element:
        base_table_def
    |   view_def
    |   privilege_def
    ;
base_table_def:
        CREATE TABLE table '(' base_table_element_commalist ')'
    ;


manipulative_statement:
        close_statement
    |   commit_statement
    |   delete_statement_positioned
    |   delete_statement_searched
    ;


insert_statement:
        INSERT INTO table opt_column_commalist values_or_query_spec
    ;
values_or_query_spec:
        VALUES '(' insert_atom_commalist ')'
    |   query_spec
    ;
insert_atom_commalist:
        insert_atom
    |   insert_atom_commalist ',' insert_atom
    ;
insert_atom:
        atom
    |   NULLX
    ;
atom:
        parameter_ref
    |   literal
    |   USER
    ;


delete_statement_positioned:
        DELETE FROM table WHERE CURRENT OF cursor
    ;
delete_statement_searched:
        DELETE FROM table opt_where_clause
    ;
opt_where_clause:
        /* blank */
    | where_clause
    ;
where_clause:
        WHERE search_condition
    ;


update_statement_positioned:
        UPDATE table SET assignment_commalist WHERE CURRENT OF cursor
    ;
assignment_commalist:
    |   assignment
    |   assignment_commalist ',' assignment
    ;
assignment:
        column COMPARISON scalar_exp
    |   column COMPARISON NULLX
    ;
update_statement_searched:
        UPDATE table SET assignment_commalist opt_where_clause
    ;


select_statement:
        SELECT opt_all_distinct selection
        INTO target_commalist
        table_exp
    |   SELECT opt_all_distinct selection table_exp
    ;
opt_all_distinct:
    |   ALL
    |   DISTINCT
    ;
selection:
        scalar_exp_commalist
    |   '*'
    ;
scalar_exp_commalist:
    ;
query_exp:
        query_term
    ;

table_exp:
        from_clause
        opt_where_clause
        opt_group_by_clause
        opt_having_clause
    ;
from_clause:
        FROM table_ref_commalist
    ;
table_ref_commalist:
        table_ref
    |   table_ref_commalist ',' table_ref
    ;
table_ref:
        table
    |   table range_variable
    ;
range_variable:
        NAME
    ;
where_clause:
        WHERE search_condition
    ;
opt_group_by_clause:
        /* empty */
    |   GROUP BY column_ref_commalist
    ;
column_ref_commalist:
        column_ref
    |   column_ref_commalist ',' column_ref
    ;
opt_having_clause:
        /* empty */
    |   HAVING search_condition
    ;


scalar_exp:
        scalar_exp '+' scalar_exp
    |   scalar_exp '-' scalar_exp
    |   scalar_exp '*' scalar_exp
    |   scalar_exp '/' scalar_exp
    |   '+' scalar_exp %prec UMINUS
    |   '-' scalar_exp %prec UMINUS
    |   atom
    |   column_ref
    |   function_ref
    |   '(' scalar_exp ')'
    ;


search_condition:
    |   search_condition OR search_condition
    |   search_condition AND search_condition
    |   NOT search_condition
    |   '(' search_condition ')'
    |   predicate
    ;
predicate:
        comparison_predicate
    |   between_predicate
    |   like_predicate
    |   test_for_null
    |   in_predicate
    |   all_or_any_predicate
    |   existence_test
    ;
comparison_predicate:
        scalar_exp COMPARISON scalar_exp
    |   scalar_exp COMPARISON subquery
    ;
between_predicate:
        scalar_exp NOT BETWEEN scalar_exp AND scalar_exp
    |   scalar_exp BETWEEN scalar_exp AND scalar_exp
    ;
like_predicate:
        scalar_exp NOT LIKE atom opt_escape
    |   scalar_exp LIKE atom opt_escape
    ;
opt_escape:
        /* empty */
    |   ESCAPE atom
    ;
test_for_null:
        column_ref IS NOT NULLX
    |   column_ref IS NULLX
    ;
in_predicate:
        scalar_exp NOT IN '(' subquery ')'
    |   scalar_exp IN '(' subquery ')'
    |   scalar_exp NOT IN '(' atom_commalist ')'
    |   scalar_exp IN '(' atom_commalist ')'
    ;
atom_commalist:
        atom
    |   atom_commalist ',' atom
    ;
all_or_any_predicate:
        scalar_exp COMPARISON any_all_some subquery
    ;
any_all_some:
        ANY
    |   ALL
    |   SOME
    ;
existence_test:
        EXISTS subquery
    ;
subquery:
        '(' SELECT opt_all_distinct selection table_exp ')'
    ;

opt_column_commalist:
    ;
cursor:
    ;
