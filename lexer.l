%{
    #ifndef YYSTYPE
    #define YYSTYPE char*
    #endif
    
    #include<string.h>
    #include<stdio.h>
    #include "y.tab.h"

    int comment = 1;
    void TokenFile(char*,char*);
    
%}

alpha [A-Za-z_]
digit [0-9]
%option yylineno

%%

 /*comments*/

"/*"  {comment-=1;}
"*/"  {comment+=1;}
"//".* ;

 /*spaces*/

[ \t\n] ;


 /* keywords */
 /* recognize all keywords and return the correct token */

"while"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_while;}}
"do"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_do;}}
"if"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_if;}}
"else"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_else;}}
"else if"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_elseif;}}
"cout"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_cout;}}
"cin"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_cin;}}
"endl"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_endl;}}
"break"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_break;}}
"continue"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_continue;}}
"const"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_const;}}
"return"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_return;}}
"include"   {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext); return T_include;}}
"using"   {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext); return T_using;}}
"namespace"   {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext); return T_namespace;}}
"main"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_main;}}

 /* class definitions */
"class"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_class;}}
"private"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_private;}}
"public"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_public;}}
"protected"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_protected;}}
"static"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_static;}}
"virtual" 	{if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_virtual;}}
"mutable" 	{if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_mutable;}}
"friend" 	{if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_friend;}}

 /* data types*/
 /* recognize int, double, bool, and string constants, return 
 the correct token and set appropriate field of yylval */
"void"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_void;}}
"int" 	 {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_int;}}
"float"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_float;}}
"bool" 	 {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_bool;}}
"char" 	 {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_char;}}
"string"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_s;}}
"long"    {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_long;}}
"double"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_double;}}
"short"  {if(comment==1){TokenFile("Keyword",yytext);yylval = strdup(yytext);return T_short;}}
 /* recognize identifiers, return the correct 
 token and set appropriate fields of yylval */
{alpha}({alpha}|{digit})*	{
								//printf("Identifier: %s\n", yytext);
								if(yyleng < 32 && yyleng > 0)
								{
									yylval = strdup(yytext);
                                     {if(comment==1)
                                    {
                                        TokenFile("Identifier",yytext);
                                        yylval = strdup(yytext);
									    return T_identifier;
								    }
                                    }
                                }
								else
								{
									yylval = strdup(yytext);
									return T_error_identifier;
								}
							}
{alpha}({alpha}|{digit})*"\.h"	{if(comment == 1) {TokenFile("Identifier",yytext); yylval = strdup(yytext); return T_header;}}
			
 /* constants  --> return values to commentd */				
{digit}+	 {if(comment==1){TokenFile("Constants",yytext);yylval = strdup(yytext);return T_num;}}
{digit}+\.({digit}+)?([eE][+-]?{digit}+)?	 {if(comment==1){TokenFile("Constants",yytext);yylval = strdup(yytext);return T_num;}}
\'.\' 	{return *yytext;}
\".*\" 	 {if(comment==1){TokenFile("String",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_STRING;}}

 /* recognize punctuation and single char operators 
 and return the ASCII value as the token */ 
 /* recognize two character operators and return the correct token */

 /* relational operators */
[<, >, ?, =]  {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);return *yytext;}}
"<="     {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_lt_eq;}}
">="     {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_gt_eq;}}
"=="     {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_equal;}}
"!="     {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_not_equal;}}

 /* arithmetic operators */
[+, -, *, /, %]  {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);return *yytext;}}
"++"     {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_increment;}}
"--"     {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);yylval = strdup(yytext);return T_decrement;}}

 /* bitwise operators */
[^, !, |, &]  {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);return *yytext;}}

 /* logical operators */
"||"    	 {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);return T_or;}}
"&&"    	 {if(comment==1){TokenFile("Operators",yytext);yylval = strdup(yytext);return T_and;}}

.    return yytext[0];

%%

void TokenFile(char *t,char *s)
{
    FILE *fptr;
    fptr = fopen("tokens.txt", "a");
    if(fptr == NULL)
    {
          printf("Error!");
          exit(1);
    }

    fprintf(fptr,"%s\t->\t%s\n",  t,s);
    fclose(fptr);
}
