%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "UserDefined.h"

GHashTable *      table_p;		//Symbol table to store data
GPtrArray *          code;		//Array where the Quads will be stored

extern int  yylineno;
void        yyerror(char *s);

%}

%union {
   int          integer_value;
   float        float_value;
   char *       string_value;
   entry_p      symTab;
   GPtrArray *	list;
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

%type <integer_value> type m
%type <symTab> variable factor term simple_exp exp stmt_seq block stmt
%type <list> n

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

stmt_seq    : stmt_seq  stmt m                  {
                                                      $$ = malloc(sizeof(entry_p));                                                      
                                                      $$->list_next = cloneList($2->list_next);                                                      
                                                      backPatch(code,$2->list_next,$3);
                                                }
            |                                   {                                                      
                                                      
                                                }
            ;

stmt        : IF exp THEN m stmt                {
                                                      $$ = malloc(sizeof(entry_p));
                                                      backPatch(code,$2->list_true,$4);
                                                      $$->list_next = mergeList($2->list_false,$5->list_next);
                                                } 
            | IF exp THEN m stmt n m stmt       {
                                                      $$ = malloc(sizeof(entry_p));
                                                      backPatch(code,$2->list_true,$4);
                                                      backPatch(code,$2->list_false,$7);
                                                      $$->list_next=mergeList($5->list_next,mergeList($6,$8->list_next));
                                                }
            | WHILE m exp DO m stmt             {     
                                                      $$ = malloc(sizeof(entry_p));                                                      
                                                      backPatch(code,$3->list_true,$5);
                                                      $$->list_next = cloneList($3->list_false);                                                      
                                                      union result res;
                                                      res.address = $2;
                                                      g_ptr_array_add(code,newQuad("jump",res,NULL,NULL));
                                                }
            | variable ASSIGN exp SEMI          {
                                                      $$ = malloc(sizeof(entry_p));
                                                      writeFile("code.txt",genAssign($1->name,$3->name));
                                                      if($1->type == real){
                                                            if($3->type == real){
                                                                  //SymUpdate(table_p,$1->name,$1->type,$3->value);                                                                  
                                                            }else{
                                                                  /* Coercion */
                                                            	printf("\nInfo. Coercion performed at line %d passing integer to float\n",yylineno );
                                                                  //SymUpdate(table_p,$1->name,real,$3->value);
                                                            }
                                                      }else{
                                                            if($3->type == real){
                                                                  printf("\nWarning! In line %d: Incompatible types, passing float to int\n",yylineno );
                                                            }else{
                                                                  //SymUpdate(table_p,$1->name,$1->type,$3->value);
                                                            }
                                                      }
                                                      /* Place the "code" generated in the array that represents the memory */
                                                      union result res;
                                                      res.entry = $1;
                                                      g_ptr_array_add(code,newQuad("assign",res,$3,NULL));
                                                      $$->list_next = g_ptr_array_new();       
                                                }                             
            | READ LPAREN variable RPAREN SEMI  {
                                                      $$ = malloc(sizeof(entry_p));
                                                      $$->list_next = g_ptr_array_new();
                                                      union result resWrite;
                                                      resWrite.entry = $3;
                                                      g_ptr_array_add(code,newQuad("read",resWrite,NULL,NULL));
                                                      
                                                }
            | WRITE LPAREN exp RPAREN SEMI      {
                                                      $$ = malloc(sizeof(entry_p));
                                                      $$->list_next = g_ptr_array_new();
                                                      union result resRead;
                                                      resRead.entry = $3;                                                      
                                                      g_ptr_array_add(code,newQuad("write",resRead,NULL,NULL));                                                      
                                                      
                                                }
            | block                             {                                                      
                                                      $$ = $1;
                                                }
            ;
            
m           :									{
													$$ = code->len;
												}
            ;
n           : ELSE 								{
													$$ = newList(code->len);
													union result res;
													res.address = 0;
													g_ptr_array_add(code,newQuad("jump",res,NULL,NULL));
												}
            ;

block       : LBRACE stmt_seq RBRACE            {                                                      
                                                    $$ = $2;                                                      
                                                }
            ;

exp         : simple_exp LT simple_exp          {                                                      
                                                      $$->type = integer;
                                                      $$->list_true = newList(code->len);
                                                      
                                                      $$->list_false = newList(code->len+1);                                                               
                                                      union result res;
                                                      res.address = 0;
                                                      g_ptr_array_add(code,newQuad("LT",res,$1,$3));
                                                      union result res2;
                                                      res.address = 0;
                                                      g_ptr_array_add(code,newQuad("jump",res,NULL,NULL));
                                                }
            | simple_exp EQ simple_exp          {
                                                      $$->type = integer;
                                                      $$->list_true = newList(code->len);
                                                      $$->list_false = newList(code->len+1);
                                                      union result res;
                                                      res.address = 0;
                                                      g_ptr_array_add(code,newQuad("EQ",res,$1,$3));
                                                      union result res2;
                                                      res.address = 0;
                                                      g_ptr_array_add(code,newQuad("jump",res,NULL,NULL));
                                                }
            | simple_exp GT simple_exp          {
                                                      $$->type = integer;
                                                      $$->list_true = newList(code->len);
                                                      $$->list_false = newList(code->len+1);
                                                      union result res;
                                                      res.address = 0;
                                                      g_ptr_array_add(code,newQuad("GT",res,$1,$3));
                                                      union result res2;
                                                      res.address = 0;
                                                      g_ptr_array_add(code,newQuad("jump",res,NULL,NULL));
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
                                                      /* Place the "code" generated in the array that represents the memory */
                                                      union result res;
                                                      res.entry = $$;
                                                      g_ptr_array_add(code,newQuad("sum",res,$1,$3));
                                                      
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
                                                      /* Place the "code" generated in the array that represents the memory */
                                                      union result res;
                                                      res.entry = $$;
                                                      g_ptr_array_add(code,newQuad("minus",res,$1,$3));
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
                                                      /* Place the "code" generated in the array that represents the memory */
                                                      union result res;
                                                      res.entry = $$;
                                                      g_ptr_array_add(code,newQuad("mult",res,$1,$3));
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
                                                      /* Place the "code" generated in the array that represents the memory */
                                                      union result res;
                                                      res.entry = $$;
                                                      g_ptr_array_add(code,newQuad("div",res,$1,$3));
                                                }
            | factor                            {
                                                      $$ = $1;
                                                }                 
            ;

factor      : LPAREN exp RPAREN                 {
                                                      $$ = $2;

                                                }
            | INT_NUM                           {                                                      
                                                      union val value;
                                                      value.i_value = $1;                                                      
                                                      $$ = newTempCons(table_p,value,integer);
                                                }
            | FLOAT_NUM                         {                                                      
                                                      union val value;
                                                      value.r_value = $1;                                                      
                                                      $$ = newTempCons(table_p,value,real);
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

        code = g_ptr_array_new();            

      	if(!yyparse())
			printf("\nParsing complete\n");
		else
			printf("\nParsing failed\n");
	
	fclose(yyin);
#ifdef DEBUG
	/* Print the Quads generated for debugging pruposes */
	PrintCode(code);
#endif
	/* Execute the code generated using the given symbol table */
	interprete(table_p,code);   
#ifdef DEBUG
	/* Print the table entries when the process is done */
	printf("\nValue of integer: %d\nValue of real: %d\n",integer,real);
	PrintTable(table_p);
#endif
	/* Free the space used by the symbol table*/
	g_hash_table_destroy(table_p);
	return EXIT_SUCCESS;
}
         
void yyerror(char *s) {
      printf("In line %d: %s %s\n", yylineno, s, yytext );
      exit(1);
}     
