	/* This is the declaration section */ 
%{  
	#include <stdlib.h>
	#include <string.h>  
	#include <glib.h>
%}

	/* Here we declare variables to make the grammatics easier */
d [0-9]
leter [a-zA-Z_]
%%

	/* Reserved words*/
"int" 		{ return INTEGER;}
"float" 	{ return FLOAT;}
"if" 		{ return IF;}
"then"	 	{ return THEN;}
"else"		{ return ELSE;}
"while"	 	{ return WHILE;}
"read"	 	{ return READ;}
"write" 	{ return WRITE;}
"do"		{ return DO;}

	/* Punctuation tokens */
"," 		{ return COMA;}
";" 		{ return SEMI;}
"(" 		{ return LPAREN;}
")" 		{ return RPAREN;}
"{" 		{ return LBRACE;}
"}" 		{ return RBRACE;}

	/* Relational tokens */
"<" 		{ return LT;}
">" 		{ return GT;}
"<=" 		{ return GT;}
">=" 		{ return LT;}
"=" 		{ return EQ;}
"!=" 		{ return EQ;}

	/* Arithmetical tokens */
"+" 		{ return PLUS;}
"-" 		{ return MINUS;}
"*" 		{ return TIMES;}
"/" 		{ return DIV;}

":=" 		{ return ASSIGN;}


	/* Grammatic for real numbers and another for integer numbers */
-?(({d}*\.{d}+)([eE][+-]?{d}+)?) 	 { 	yylval.float_value = atof (yytext);
										return FLOAT_NUM; }
-?({d}+)							 { 	yylval.integer_value = atoi (yytext);
										return INT_NUM; }


	/* Grammatic for identifiers using the variables defined above */
({leter})({leter}|{d})* 			 { 	yylval.string_value = strdup(yytext);
										return ID;}

	

	/* Grammatics for multi-line comments, error handling and single line comments */
"/*"[^*]*"*"+([^*/][^*]*[*]+)*[/]  	;
"/*"								;
"//".* 								;

	/* Skip blank space and tab*/
[ \t\r]+ 							; 

	/* New line */
\n 									yylineno = yylineno +1;
								
	/* Any other character not recognized */
. 									{return yytext[0];}
%%