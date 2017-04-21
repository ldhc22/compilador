%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "UserDefined.h"
#include "FileManagement.h"

GHashTable * table_p;
extern int yylineno;
void yyerror(char *s);

%}

%union {
   int            integer_value;
   float          float_value;
   char *         string_value;
   entry_p        symTab;
}


%token <string_value> ID
%token <integer_value> INT_NUM
%token <float_value> FLOAT_NUM
%token SEMI
%token COMA
%token INTEGER
%token FLOAT
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO
%token ASSIGN
%token WRITE
%token READ
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token LT
%token GT
%token EQ
%token LTEQ
%token PLUS
%token MINUS
%token TIMES 
%token DIV

%type <integer_value> type
%type <symTab> variable factor term simple_exp exp

%left MINUS PLUS
%left TIMES DIV

%expect 1
 
%%

program     : var_dec stmt_seq     { printf ("No syntax errors \n");}
            ;

var_dec     : var_dec single_dec  
            |                       
            ;

single_dec  : type ID SEMI                            {
                                                            if(SymLookUp(table_p,$2)!=NULL){
                                                                  printf("\nWarning! In line %d: Variable %s already defined\n",yylineno,$2 );                                                                  
                                                            }else{
                                                                  SymInsert(table_p,$2,$1);
                                                            }
                                                      }     
            ;


type        : INTEGER                                {$$ = integer;}                         
            | FLOAT                                  {$$ = real;}
            ;

stmt_seq    : stmt_seq stmt  
            |          
            ;

stmt        : IF exp THEN stmt  
            | IF exp THEN stmt ELSE stmt
            | WHILE exp DO stmt  
            | variable ASSIGN exp SEMI          {
                                                      writeFile("code.txt",genAssign($1->name,$3->name));
                                                      if($1->type == real){
                                                            if($3->type == real){
                                                                  SymUpdate(table_p,$1->name,$1->type,$3->value);
                                                                  //writeFile("code.txt","");
                                                            }else{
                                                                  /* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  SymUpdate(table_p,$1->name,real,$3->value);
                                                            }
                                                      }else{
                                                            if($3->type == real){
                                                                  printf("\nWarning! In line %d: Incompatible types, passing float to int\n",yylineno );
                                                            }else{
                                                                  SymUpdate(table_p,$1->name,$1->type,$3->value);
                                                            }
                                                      }
                                                }                             
            | READ LPAREN variable RPAREN SEMI
            | WRITE LPAREN exp RPAREN SEMI
            | block
            ;

block       : LBRACE stmt_seq RBRACE
            ;

exp         : simple_exp LT simple_exp          {
                                                      $$->type = integer;
                                                }
            | simple_exp EQ simple_exp          {
                                                      $$->type = integer;
                                                }
            | simple_exp GT simple_exp          {
                                                      $$->type = integer;
                                                }
            | simple_exp                        {
                                                      $$ = $1;
                                                }               
            ;

simple_exp  : simple_exp PLUS term              {
                                                      $$ = newTemp(table_p);
                                                      if($1->type == real){
                                                            if($3->type==real){
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                      }
                                                      else{
                                                            if($3->type==real){
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                $$->type = real;
                                                            }
                                                            else{
                                                                  $$->type = integer;
                                                            }
                                                      }
                                                      // if(strcmp($1->name,"int")==0){
                                                      //       if(strcmp($2->name,"int")==0)
                                                      //             writeFile("code.txt",genSum($$->name,$1->value,$3->name));            
                                                      // }
                                                      writeFile("code.txt",genSum($$->name,$1->name,$3->name));            
                                                      
                                                }
            | simple_exp MINUS term             {     
                                                      $$ = newTemp(table_p);
                                                      if($1->type == real){
                                                            if($3->type==real){
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                      }
                                                      else{
                                                            if($3->type==real){
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                                  $$->type = integer;
                                                            }
                                                      }
                                                      writeFile("code.txt",genMinus($$->name,$1->name,$3->name));            
                                                }
            | term                              {
                                                      $$ = $1;
                                                }             
            ;

term        : term TIMES factor                 {
                                                      $$ = newTemp(table_p);
                                                      if($1->type == real){
                                                            if($3->type==real){
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                      }
                                                      else{
                                                            if($3->type==real){
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                                  $$->type = integer;
                                                            }
                                                      }
                                                      writeFile("code.txt",genMult($$->name,$1->name,$3->name));            
                                                }
            | term DIV factor                   {     
                                                      $$ = newTemp(table_p);
                                                      if($1->type == real){
                                                            if($3->type==real){
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                      }
                                                      else{
                                                            if($3->type==real){
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                            else{
                                                            	/* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  $$->type = real;
                                                            }
                                                      }   
                                                      writeFile("code.txt",genDiv($$->name,$1->name,$3->name));                                                               
                                                }
            | factor                            {
                                                      $$ = $1;
                                                }                 
            ;

factor      : LPAREN exp RPAREN                 {
                                                      $$ = $2;
                                                }
            | INT_NUM                           {
                                                      $$ = malloc(sizeof(entry_p));
                                                      $$->name = malloc(sizeof(char *));
                                                      strcpy($$->name,"int");
                                                      $$->value.i_value = $1;
                                                      $$->type = integer;
                                                }
            | FLOAT_NUM                         {
                                                      $$ = malloc(sizeof(entry_p));
                                                      $$->name = malloc(sizeof(char *));
                                                      strcpy($$->name,"float");
                                                      $$->value.r_value = $1;
                                                      $$->type = real;
                                                }
            | variable                          {
                                                      $$ = $1;
                                                }     
            ;

variable    : ID                                {
                                                      entry_p node = SymLookUp(table_p,$1);
                                                      if(node == NULL){
                                                            printf("\nWarning! In line %d: Undeclared variable %s\n",yylineno,$1);                                                            
                                                      }else{
                                                            $$ = node;
                                                      }
                                                }
            ;


%%
#include"lex.yy.c"
#include<ctype.h>
int count=0;

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");

      /* Create the hash table to use as symbol table */
      	table_p = g_hash_table_new_full(g_str_hash, g_str_equal,NULL,(GDestroyNotify)FreeItem);

      	if(!yyparse())
			printf("\nParsing complete\n");
		else
			printf("\nParsing failed\n");
	
	fclose(yyin);

	/* Print the table entries when the process is done */
	printf("\nValue of integer: %d\nValue of real: %d\n",integer,real);
	PrintTable(table_p);   
      //writeFile("code.txt",genMult("t0","a","b"));

	/* Free the space used by the symbol table*/
	g_hash_table_destroy(table_p);
	return EXIT_SUCCESS;
}
         
void yyerror(char *s) {
      printf("In line %d: %s %s\n", yylineno, s, yytext );
      exit(1);
}     