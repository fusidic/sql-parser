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
        SELECT opt_all_distinct slelection
        INTO target_commalist
        table_exp
    |  




    /* to be CONTINUE */
opt_column_commalist:
    ;
cursor:
    ;
search_condition:
    ;
