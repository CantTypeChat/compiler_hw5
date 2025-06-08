

digit       [0-9]
letter      [a-zA-Z_]
delim       [ \t]
line        [\n]
ws          {delim}+
float				{digit}+\.{digit}*
identifier  {letter}({letter}|{digit})*
integer_literal    [0-9]|[1-9][0-9]+
%{
#include<stdlib.h>
#include<string.h>
#include "type.h"
#include "y.tab.h"
extern int line_no;
extern long long yylval;
extern A_ID* current_id;
int checkIdentifier(char *s);
extern A_ID *searchIdentifier(char *, A_ID*);
%}
%%
{ws}            { }
{line}          { line_no++; }

"auto"          { return(AUTO_SYM); }
"break"         { return(BREAK_SYM); }
"case"          { return(CASE_SYM); }
"continue"      { return(CONTINUE_SYM); }
"default"       { return(DEFAULT_SYM); }
"do"            { return(DO_SYM); }
"else"          { return(ELSE_SYM); }
"enum"          { return(ENUM_SYM); }
"for"           { return(FOR_SYM); }
"if"            { return(IF_SYM); }
"return"        { return(RETURN_SYM); }
"sizeof"        { return(SIZEOF_SYM); }
"struct"        { return(STRUCT_SYM); }
"switch"        { return(SWITCH_SYM); }
"typedef"       { return(TYPEDEF_SYM); }
"union"         { return(UNION_SYM); }
"while"         { return(WHILE_SYM); }
"\+\+"            { return(PLUSPLUS); }
"\-\-"            { return(MINUSMINUS); }
"\->"            { return(ARROW); }
"<"             { return(LSS); }
">"             { return(GTR); }
"<="            { return(LEQ); }
">="                        { return(GEQ); }
"=="                        { return(EQL); }
"!="                        { return(NEQ); }
"&&"                        { return(AMPAMP); }
"||"                        { return(BARBAR); }
"\.\.\."                       { return(DOTDOTDOT); }

"\("                         { return(LP); }
"\)"                         { return(RP); }
"\["                         { return(LB); }
"\]"                         { return(RB); }
"\{"                         { return(LR); }
"\}"                         { return(RR); }

"\:"                         { return(COLON); }
"\."                         { return(DOT); }
"\,"                         { return(COMMA); }
"\!"                         { return(EXCL); }
"*"                         { return(STAR); }
"\/"                         { return(SLASH); }
"\%"                         { return(PERCENT); }
"\&"                         { return(AMP); }
"\;"                         { return(SEMICOLON); }

"\+"                         { return(PLUS); }
"\-"                         { return(MINUS); }
"\="                         { return(ASSIGN); }
"\^"                         { return(BXOR); }

"~"                         { return(TILDE); }
"|"                         { return(BAR); }
">>"                        { return(GTRGTR); }
"<<"                        { return(LSSLSS); }
"\?"                         { return(QUESTION); }

"volatile"                 { return(VOLATILE_SYM); }
"static"                   { return(STATIC_SYM); }


"const"                    { return(CONST_SYM); }
"goto"                     { return(GOTO_SYM); }

{integer_literal}                   { yylval = atoi(yytext); return(INTEGER_CONSTANT); }
{float}                    { yylval = (char*) strdup(yytext); return(FLOAT_CONSTANT); }
{identifier}               { yylval = (char*) strdup(yytext); return(checkIdentifier(yytext));}

\"([^\"\n]|\\[\"\n])*\"               {
        yylval = (char*) strdup(yytext);
        return(STRING_LITERAL);}

\'([^'\n]|\\[\\\'nt])\'       { 
    char c;
    if(yytext[1] == '\\') {
        switch(yytext[2]) {
            case 'n':
               c = '\n';
               break;
            case 't':
               c = '\t';
               break; 
            case '\\':
               c = '\\';
               break;
            case '\'':
               c = '\'';
               break;
            default:
               printf("unknown const char detected.\n");
        }
    } else {
        c = yytext[1];
    }
    yylval = (char) c;
    return(CHARACTER_CONSTANT);
}

%%

int checkIdentifier(char *s) {
    A_ID *a;
    A_ID *b = current_id;
    a = searchIdentifier(s, b);
    if(a == NIL)
        return IDENTIFIER;
    else if(a->kind == ID_TYPE) {
        yylval = a->type;
        return TYPE_IDENTIFIER;
    } else
        return IDENTIFIER;
}

int yywrap(void) {
    return (1);
}
