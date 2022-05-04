%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#ifndef YYSTYPE
	#define YYSTYPE char*
	#endif
 
	int yylex();
	void yyerror(char *);
	void yyerrok(char *);
	void lookup(char *,int,char,char*,char*);
	void update_datatype(char* , int);
	void update(char *,int,char *);
	int search_id(char *,int );
	void search_func(char* token, int lineno);
	extern FILE *yyin;
	extern int yylineno;
	extern char *yytext;
	
	void increment_scope();
	void decrement_scope();
	void push(int scope);	 
	void pop();
	int search_scope(int value);
	int search_in_scope(char *token,int lineno);
	
	typedef struct symbol_table
	{
		int line;
		char name[31];
		char type;
		char *value;
		char datatype[20];
		int scope ;
	}ST;
	int struct_index = 0;
	ST st[10000];
	
	int scope_val = 0;
	int next_scope = 1;
	
	int stack[1000];
	int top = 1;
%}

%start S
%token T_while T_do T_if T_elseif T_else T_cout T_cin T_endl T_break T_continue T_const T_void T_return T_main T_class T_private T_public T_protected T_static T_include T_namespace T_using
%token T_header T_int T_float T_bool T_char T_s T_long T_double T_short T_STRING T_friend T_mutable T_virtual 
%token T_lt_eq T_gt_eq T_equal T_not_equal T_increment T_decrement T_or T_and
%token T_identifier T_num T_error_identifier



%%
S	
	: HEADER
	;



HEADER
	: '#' T_include HEADERFILE HEADER
	| T_using T_namespace T_identifier ';' HEADER
	| X
	;
X
	: Class X
	| Function X 
	| Function_decl X
	| MAIN
	;
	
HEADERFILE
	: T_STRING
	| '<' T_header '>'
	| '<' T_identifier '>'
	| '<' error '>' { yyerrok; yyclearin; printf("Invalid header file\n\n"); }
	;

Class	
	: T_class T_identifier Base_class '{' Class_body '}' Var_list ';'
	| T_class error { yyerrok; yyclearin; printf("Invalid class name\n\n"); } Base_class '{' Class_body '}' Var_list ';'
	;

Var_list	: T_identifier ',' Var_list
			| T_identifier
			| /* lambda */
			;

Base_class	
	: ':' Virtual Access_specifier T_identifier Base_class_list
	| /* lambda */
	;

Base_class_list	
	: ',' Virtual Access_specifier T_identifier Base_class_list
	|  /* lambda */
	;

Virtual	
	: T_virtual
	|  /* lambda */
	;
		
Class_body	
	: Access_specifier ':' Class_members Class_body
	| /* lambda */
	;
			
Access_specifier	
	: T_public 
	| T_private 
	| T_protected ;
			
Class_members	: TYPE T_identifier ';' Class_members
		| T_static TYPE T_identifier ';' Class_members
		| T_mutable TYPE T_identifier ';' Class_members
		| T_const Var_initialize ';' Class_members 
		| T_static T_const Var_initialize ';' Class_members 
		
		| Function_decl Class_members
		| Class_Function Class_members
		
		| T_static Function_decl Class_members
		| T_static Class_Function Class_members
		
		| T_virtual Function_decl Class_members
		| T_virtual Class_Function Class_members
		
		| T_friend T_class T_identifier ';' Class_members
		| T_friend TYPE T_identifier '(' ')' ';' Class_members
		| T_friend TYPE T_identifier ':' ':' T_identifier '(' ')' ';' Class_members
		| T_friend Class_Function Class_members
		
		| Constr_Destr Class_members	
		|  /* lambda */
		;

Constr_Destr: '~' T_identifier '(' Parameter ')' ';'
			| '~' T_identifier '(' ')' ';'
			| '~' T_identifier '(' Parameter ')' '{' Func_body '}'
			| '~' T_identifier '(' ')' '{' Func_body '}'
			| T_identifier '(' Parameter ')' ';'
			| T_identifier '(' ')' ';'
			| T_identifier '(' Parameter ')' '{' Func_body '}'
			| T_identifier '(' ')' '{' Func_body '}'
			;

Function_decl	: TYPE T_identifier '(' Parameter ')' ';'
				| TYPE T_identifier '(' ')' ';'
				;
				
Class_Function	: TYPE T_identifier '(' Parameter ')' '{' Func_body '}'
			| TYPE T_identifier '(' ')' '{' Func_body '}'
			| TYPE T_identifier ':' ':' T_identifier '(' Parameter ')' '{' Func_body '}'			
			| TYPE T_identifier ':' ':' T_identifier '(' ')' '{' Func_body '}'
			;
			

Function
	: TYPE Declrfun
	| '~' Declrfun
	| TYPE T_identifier '(' Parameter ')' '{' Func_body '}' {lookup($2,yylineno,'F',NULL,NULL);}
	| TYPE T_identifier '(' ')' '{' Func_body '}' {lookup($2,yylineno,'F',NULL,NULL);}
	;

Declrfun
	: T_identifier ':' ':' T_identifier '(' Parameter ')' '{' Func_body '}'	{lookup($1,yylineno,'F',NULL,NULL);}		
	| T_identifier ':' ':' T_identifier '(' ')' '{' Func_body '}' {lookup($1,yylineno,'F',NULL,NULL);}	
	;	
			
			
Parameter	: TYPE T_identifier Parameter
		| TYPE T_identifier ',' Parameter
		| TYPE T_identifier 
		| TYPE T_identifier '=' LIT Default_parameters 
		;

Default_parameters	: ',' Var_initialize Default_parameters
					| /*lambda */
					;
		
Var_initialize	: TYPE T_identifier '=' LIT
				| /*lambda */
				;	
Func_body
	: C
	;
	
MAIN
	: T_int T_main '('')' BODY
	| T_void T_main '('')' BODY
	| error { yyerrok; yyclearin; printf("Wrong main() data type\n\n"); } T_main '('')' BODY
	;

BODY
	: '{' { increment_scope(); } C '}' { decrement_scope(); } C
	|  /* lambda */
	;

C
	: DECLR ';' C 
	| STATEMENTS ';' C
	| LOOP C
	| ASSIGN ';' C 
	| BODY
	| error ';' { yyerrok; yyclearin; printf("Invalid Statement\n\n"); } C
	;

LOOP
	: T_if '(' COND ')' '{' C '}'  IF_L
	| T_do '{' C '}' T_while '(' COND ')' ';'
	;
UX
	: T_identifier UO 
	| UO T_identifier
	;

UO 
	: T_increment 
	| T_decrement
	;

IF_L
	: T_elseif '(' COND ')' '{' C'}' IF_L
	| T_else '{' C'}' IF_L
	| /* lambda */
	;

COND
      : LIT RELOP COND
      |'(' COND ')'COND
      | NEG COND
      | LOGIC_OP COND
      | /* lambda */
      ;
RELOP
      : '>'
      | '<' 
      | T_lt_eq 
      | T_gt_eq 
      | T_equal 
      | T_not_equal
      | /* lambda */
      ;

LOGIC_OP
      : T_and 
      | T_or
      | '|'
      | '&'
      ;

NEG
      : '~'
      ;


TYPE
	: T_void		{update_datatype($1, yylineno);}
	| T_int			{update_datatype($1, yylineno);}
	| T_float		{update_datatype($1, yylineno);}
	| T_char		{update_datatype($1, yylineno);}
	| T_bool		{update_datatype($1, yylineno);}
	| T_s		{update_datatype($1, yylineno);}
	| T_long		{update_datatype($1, yylineno);}
	| T_double		{update_datatype($1, yylineno);}
	| T_short		{update_datatype($1, yylineno);}
	| T_int '*' 		{update_datatype($1, yylineno);}
	| T_float '*' 		{update_datatype($1, yylineno);}
	| T_char '*' 		{update_datatype($1, yylineno);}
	| T_void '*'		{update_datatype($1, yylineno);}
	| T_int '&' 		{update_datatype($1, yylineno);}
	| T_float '&' 		{update_datatype($1, yylineno);}
	| T_char '&' 		{update_datatype($1, yylineno);}
	| T_void '&'		{update_datatype($1, yylineno);}
	;
	

DECLR
	: TYPE LISTVAR
	| T_static TYPE LISTVAR
	| T_const TYPE LISTVAR
	/*| TYPE T_num error ';'	{ yyerrok; yyclearin; printf("Declaration error\n"); }*/
	;

LISTVAR
	: T_identifier LISTVAR      {lookup($1,yylineno,'I',NULL,NULL);}
	| T_identifier '=' EXP LISTVAR {lookup($1,yylineno,'I',NULL,NULL);update($1,yylineno,$3);}
	| ',' LISTVAR
	/*| error	';'	{ yyerrok; yyclearin; printf("Variable list error\n"); }*/
	|
	;

ASSIGN
	: T_identifier '=' EXP    {update($1,yylineno,$3);}
	;

STATEMENTS
	: T_return EXP
	| UX
	| PRINT 
	| T_identifier Function_call {search_func($1,yylineno);}
	| /* lambda */
	;	

EXP
	: TERM 
	| EXP '+' TERM
	| EXP '-' TERM
	;
TERM
	: FACTOR
	| TERM '*' FACTOR
	| TERM '/' FACTOR
	| TERM '%' FACTOR
	;
FACTOR
	: LIT 
	| '(' EXP ')' 
	;
LIT
	: T_identifier
	| T_num
	;

	
Function_call	: '(' Arguments')' 
				| '.' T_identifier '(' Arguments')' 
				|  '(' ')' 
				| '.' T_identifier '(' ')' 
				;

Arguments	: LIT Arguments
			| ',' Arguments
			| LIT
			;

PRINT
      : T_cout  OUT 
      | T_cin IN
      ;
IN
      : '>''>' T_PRINT IN
      | /* lambda */
      ;
OUT
      : '<''<' T_PRINT OUT
      | /* lambda */
      ;
      
T_PRINT
	: T_STRING
	| LIT
	| T_endl
	;
    
%%
char datatype[20];
int line_number = 0;

int main(int argc,char *argv[])
{
	if(argc < 2)
	{
		printf("No input file provided\n");
		exit(0);
	}
	
	FILE* input_fp = fopen(argv[1], "r");
	yyin = input_fp;
	if(!yyparse())  //yyparse-> 0 if success
	{
		printf("Parsing Complete\n");
		FILE *fptr;
		fptr = fopen("symbol.txt", "a");
		if(fptr == NULL)
		{
			  printf("Error!");
			  exit(1);
		}
		else
		{
			fprintf(fptr,"Number of entries in the symbol table = %d\n\n",struct_index);
			fprintf(fptr,"-----------------------------------Symbol Table-----------------------------------------------\n\n");
			fprintf(fptr,"S.No\t  Token  \t Line Number \t Category \t DataType \t Value \t\t\t Scope \n");
			for(int i = 0;i < struct_index;i++)
			{
				char *ty;


				if(st[i].type=='F')
				{
					ty="func_call";
					fprintf(fptr,"%-4d\t  %-7s\t   %-10d \t %-9s\t  %-7s\t   %-5s\t\t  %-4d\n",i+1,st[i].name,st[i].line,ty,st[i].datatype,st[i].value,st[i].scope);
				}
				ty= "identifier";
				fprintf(fptr,"%-4d\t  %-7s\t   %-10d \t %-9s\t  %-7s\t   %-5s\t\t  %-4d\n",i+1,st[i].name,st[i].line,ty,st[i].datatype,st[i].value,st[i].scope);
			}
		}
		fclose(fptr);
	}
	
	else printf("Parsing failed\n");
	
	fclose(yyin);
	return 0;
}

void yyerror(char *s)
{
  	printf("Syntax error at line - %d\n\tERROR at %s - ",yylineno, yytext);
}

void update_datatype(char* DType, int lno)
{
	strcpy(datatype, DType);
	line_number = lno;	
}

void lookup(char *token,int line,char type,char *value,char *datatype_remove)
{
	if(search_in_scope(token, line) != -1) printf("ERROR at line %d: \'%s\' is being re-declared\n\n", line, token);
	else
	{
		strcpy(st[struct_index].name,token);
		st[struct_index].type=type;
		if(value==NULL)
			st[struct_index].value=NULL;
		else
			strcpy(st[struct_index].value,value);
			
		strcpy(st[struct_index].datatype, datatype);
		st[struct_index].scope = scope_val;
			
		st[struct_index].line = line;
		struct_index++;  
	}
}

int search_in_scope(char *token,int lineno)
{
	for(int i = 0;i < struct_index;i++)
	{
		if(!strcmp(st[i].name,token) && (st[i].scope == scope_val))
		{
			return i;
		}
	}
	return -1;
}

int search_id(char *token,int lineno)
{
	for(int i = 0;i < struct_index;i++)
	{
		if(!strcmp(st[i].name,token) && search_scope(st[i].scope))
		{
			return i;
		}
	}
	return -1;
}

void search_func(char* token, int lineno)
{
	int index = search_id(token, lineno);
	if(index == -1) printf("ERROR at line %d: Function - \'%s\' not declared\n\n", lineno, token);
}

void update(char *token,int lineno,char *value)
{
	int flag = 0;

	int index = search_id(token, lineno);
	if(index == -1) printf("ERROR at line %d: \'%s\' is not declared\n\n", lineno, token);
	else
	{
	  st[index].value = (char*)malloc(sizeof(char)*strlen(value));
	  strcpy(st[index].value,value);
	  st[index].line = lineno;
	  return;
	}
}

void increment_scope()
{	
	scope_val = next_scope;
	push(scope_val);
	++next_scope;
}

void decrement_scope()
{
	pop();
	scope_val = stack[top-1];
}

void push(int scope)
{
	stack[top++]=scope;
}
 
void pop()
{
	--top;
}

int search_scope(int value)
{
	/*for(int i = 0; i<top; ++i)
		printf("%d ",stack[i]);*/
	for(int i = 0; i<top; ++i)
		if(value == stack[i]) return 1;
	return 0;
}

