%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"type.h"
#include"y.tab.h"
#define YYSTYPE long long
#define YYSTYPE_IS_DECLARED 1
extern int semantic_err;
extern void print_ast(A_NODE *node);    
extern char *yytext;
A_TYPE *int_type, *char_type, *void_type, *float_type, *string_type;
A_NODE *root;
A_ID* current_id=NIL;
int syntax_err=0;
int line_no=1;
int current_level=0;
A_NODE *makeNode(NODE_NAME, A_NODE *, A_NODE *, A_NODE *);
A_NODE *makeNodeList(NODE_NAME, A_NODE *, A_NODE *);
A_ID *makeIdentifier(char *);
A_ID *makeDummyIdentifier();
A_TYPE *makeType(T_KIND);
A_SPECIFIER *makeSpecifier(A_TYPE *, S_KIND);
A_ID *searchIdentifier(char *, A_ID*);
A_ID *searchIdentifierAtCurrentLevel(char *, A_ID*);
A_SPECIFIER *updateSpecifier(A_SPECIFIER *, A_TYPE *, S_KIND);
void checkForwardReference();
void setDefaultSpecifier(A_SPECIFIER *);
A_ID *linkDeclaratorList(A_ID*, A_ID*);
A_ID *getIdentifierDeclared(char *);
A_TYPE *getTypeOfStructOrEnumRefIdentifier(T_KIND, char *, ID_KIND);
A_ID *setDeclaratorInit(A_ID*, A_NODE *);
A_ID *setDeclaratorKind(A_ID*, ID_KIND);
A_ID *setDeclaratorElementType(A_ID *, A_TYPE *);
A_ID *setDeclaratorType(A_ID*, A_TYPE *);
A_ID *setDeclaratorTypeAndKind(A_ID*, A_TYPE *, ID_KIND);
A_ID *setDeclaratorListSpecifier(A_ID*, A_SPECIFIER *);
A_ID *setFunctionDeclaratorSpecifier(A_ID*, A_SPECIFIER *);
A_ID *setFunctionDeclaratorBody(A_ID*, A_NODE *);
A_ID *setParameterDeclaratorSpecifier(A_ID*, A_SPECIFIER *);
A_ID *setStructDeclaratorListSpecifier(A_ID*, A_TYPE *);
A_TYPE *setTypeNameSpecifier(A_TYPE *, A_SPECIFIER *);
A_TYPE *setTypeElementType(A_TYPE *, A_TYPE *);
A_TYPE *setTypeField(A_TYPE *, A_ID *);
A_TYPE *setTypeExpr(A_TYPE *, A_NODE *);
A_TYPE *setTypeAndStructOrEnumIdentifier(T_KIND, char *, ID_KIND);
BOOLEAN isNotSameFormalParameters(A_ID *, A_ID *);
BOOLEAN isVaArgs(A_ID*);
BOOLEAN isNotSameType(A_TYPE *, A_TYPE *);
BOOLEAN isPointerOrArrayType(A_TYPE *);
void syntax_error(int, char*);
void initialize();

A_TYPE *getTypeFromSpecifier(A_SPECIFIER *);

%}
/*
%union {
    A_NODE* a_node;
    A_ID* a_id;
    A_TYPE* a_type;
    A_SPECIFIER *a_specifier;
    BOOLEAN boolean;
    T_KIND t_kind;
    Q_KIND q_kind;
    S_KIND s_kind;
    ID_KIND id_kind;
    LIT_VALUE lit_value;
    A_LITERAL a_literal;
}
*/
%token AUTO_SYM BREAK_SYM CASE_SYM CONTINUE_SYM DEFAULT_SYM DO_SYM ELSE_SYM ENUM_SYM FOR_SYM IF_SYM RETURN_SYM SIZEOF_SYM STRUCT_SYM SWITCH_SYM TYPEDEF_SYM UNION_SYM WHILE_SYM PLUSPLUS MINUSMINUS ARROW LSS GTR LEQ GEQ EQL NEQ AMPAMP BARBAR AMP BAR DOTDOTDOT DOT LP RP LB RB LR RR COLON COMMA EXCL STAR SLASH PERCENT PLUS MINUS ASSIGN INTEGER_CONSTANT FLOAT_CONSTANT STRING_LITERAL CHARACTER_CONSTANT TILDE BXOR SEMICOLON STATIC_SYM CONST_SYM VOLATILE_SYM TYPE_IDENTIFIER IDENTIFIER LSSLSS GTRGTR GTR QUESTION GOTO_SYM
%%
program             :   translation_unit {root=makeNode(N_PROGRAM, 0, $1, 0); checkForwardReference();}
                    ;
translation_unit    :   external_declaration {$$=$1;}
                    |   translation_unit external_declaration {$$=linkDeclaratorList($1, $2);}
                    ;

external_declaration:   function_definition {$$=$1;}
                    |   declaration {$$=$1;}
                    ;

function_definition :   declaration_specifiers declarator {$$=setFunctionDeclaratorSpecifier($2, $1);} compound_statement {$$=setFunctionDeclaratorBody($3, $4);}
                    |   declarator {$$=setFunctionDeclaratorSpecifier($1,makeSpecifier(int_type,0));} compound_statement {$$=setFunctionDeclaratorBody($2,$3);}
                    ;

declaration         :   declaration_specifiers init_declarator_list_opt SEMICOLON {$$=setDeclaratorListSpecifier($2,$1);}
                    ;

declaration_specifiers: type_specifier {$$=makeSpecifier($1,0);}
                      | storage_class_specifier {$$=makeSpecifier(0,$1);}
                      | type_specifier declaration_specifiers {$$=updateSpecifier($2,$1,0);}
                      | storage_class_specifier declaration_specifiers {$$=updateSpecifier($2,0,$1);}
                      ;

storage_class_specifier: AUTO_SYM {$$=S_AUTO;}
                       | STATIC_SYM {$$=S_STATIC;}
                       | TYPEDEF_SYM {$$=S_TYPEDEF;}
                       ;

init_declarator_list_opt        : /* empty */ {$$=NIL;}
                                | init_declarator_list {$$=$1;}
                                ;


init_declarator_list   : init_declarator {$$=$1;}
                       | init_declarator_list COMMA init_declarator {$$=linkDeclaratorList($1, $3);}
                       ;

init_declarator        : declarator {$$=$1;}
                       | declarator ASSIGN initializer {$$=setDeclaratorInit($1, $3);}
                       ;

type_specifier         : struct_specifier {$$=$1;}
                       | enum_specifier {$$=$1;}
                       | TYPE_IDENTIFIER {$$=$1;}
                       ;

struct_specifier        : struct_or_union IDENTIFIER {$$=setTypeStructOrEnumIdentifier($1, $2, ID_STRUCT);} LR {$$ = current_id; current_level++;} struct_declaration_list RR {checkForwardReference(); $$=setTypeField($3, $6); current_level--; current_id=$5;}
                        | struct_or_union {$$=makeType($1);} LR {$$=current_id; current_level++;} struct_declaration_list RR {checkForwardReference(); $$=setTypeField($2, $5); current_level--; current_id=$4;} 
                        | struct_or_union IDENTIFIER {$$=getTypeOfStructOrEnumRefIdentifier($1,$2,ID_STRUCT);}
                        ;

struct_or_union         : STRUCT_SYM {$$=T_STRUCT;}
                        | UNION_SYM {$$=T_UNION;}
                        ;

struct_declaration_list : struct_declaration {$$=$1;}
                        | struct_declaration_list struct_declaration {$$=linkDeclaratorList($1, $2);}
                        ;

struct_declaration      : specifier_qualifier_list struct_declarator_list SEMICOLON {$$=setStructDeclaratorListSpecifier($2,$1);}
                        ;

specifier_qualifier_list: type_specifier
                        | type_specifier specifier_qualifier_list
                        ;

struct_declarator_list  : struct_declarator {$$=$1;}
                        | struct_declarator_list COMMA struct_declarator {$$=linkDeclaratorList($1,$3);}
                        ;

struct_declarator       : declarator {$$=$1;}
                        | COLON constant_expression {$$=setDeclaratorInit(makeDummyIdentifier(), makeNode(N_INIT_LIST_ONE, 0, $2, 0));}
                        | declarator COLON constant_expression {$$=setDeclaratorInit($1, makeNode(N_INIT_LIST_ONE, 0, $3, 0));} //
                        ;

enum_specifier          : ENUM_SYM IDENTIFIER {$$=setTypeStructOrEnumIdentifier(T_ENUM,$2,ID_ENUM);} LR enumerator_list RR {$$=setTypeField($3,$5);}
                        | ENUM_SYM {$$=makeType(T_ENUM);} LR enumerator_list RR {$$=setTypeField($2,$4);}
                        | ENUM_SYM IDENTIFIER {$$=getTypeOfStructOrEnumRefIdentifier(T_ENUM,$2,ID_ENUM);}
                        ;

enumerator_list         : enumerator {$$=$1;}
                        | enumerator_list COMMA enumerator {$$=linkDeclaratorList($1, $3);}
                        ;

enumerator              : IDENTIFIER {$$=setDeclaratorKind(makeIdentifier($1),ID_ENUM_LITERAL);}
                        | IDENTIFIER {$$=setDeclaratorKind(makeIdentifier($1),ID_ENUM_LITERAL);} ASSIGN constant_expression {$$=setDeclaratorInit($2,$4);}
                        ;

declarator              : pointer direct_declarator {$$=setDeclaratorElementType($2,$1);}
                        | direct_declarator {$$=$1;}
                        ;

pointer                 : STAR {$$=makeType(T_POINTER);}
                        | STAR pointer {$$=setTypeElementType($2,makeType(T_POINTER));}
                        ;


direct_declarator       : IDENTIFIER {$$=makeIdentifier($1);}
                        | LP declarator RP {$$=$2;}
                        | direct_declarator LB constant_expression_opt RB {$$=setDeclaratorElementType($1,setTypeExpr(makeType(T_ARRAY),$3));}
                        | direct_declarator LP {$$=current_id; current_level++;} parameter_type_list_opt RP {$$=setDeclaratorElementType($1,setTypeField(makeType(T_FUNC),$4)); checkForwardReference(); current_level--; current_id=$3;}
                        ;

constant_expression_opt : /* empty */
                        | constant_expression
                        ;

parameter_type_list_opt : /* empty */ {$$=NIL;}
                        | parameter_type_list {$$=$1;}
                        ;

parameter_type_list     : parameter_list {$$=$1;}
                        | parameter_list COMMA DOTDOTDOT {$$=linkDeclaratorList($1,setDeclaratorKind(makeDummyIdentifier(),ID_PARM));}
                        ;

parameter_list          : parameter_declaration {$$=$1;}
                        | parameter_list COMMA parameter_declaration {$$=linkDeclaratorList($1,$3);}
                        ;

parameter_declaration   : declaration_specifiers declarator  {$$=setParameterDeclaratorSpecifier($2,$1);}
                        | declaration_specifiers abstract_declarator_opt {$$=setParameterDeclaratorSpecifier(setDeclaratorType(makeDummyIdentifier(),$2),$1);}
                        ;

abstract_declarator_opt : /* empty */ {$$=0;}
                        | abstract_declarator {$$=$1;}
                        ;
abstract_declarator     : pointer {$$=$1;}
                        | direct_abstract_declarator {$$=$1;}
                        | pointer direct_abstract_declarator {$$=setTypeElementType($2,makeType(T_POINTER));}
                        ;

direct_abstract_declarator : LP abstract_declarator RP {$$=$2;}
                           | LB constant_expression_opt RB  {$$=setTypeExpr(makeType(T_ARRAY),$2);}
                           | LP parameter_type_list_opt RP {$$=setTypeExpr(makeType(T_FUNC),$2);}
                           | direct_abstract_declarator LB constant_expression_opt RB {$$=setTypeElementType($1,setTypeExpr(makeType(T_ARRAY),$3));}
                           | direct_abstract_declarator LP parameter_type_list_opt RP {$$=setTypeElementType($1,setTypeField(makeType(T_FUNC),$3));}
                           ;

initializer             :   constant_expression {$$=makeNode(N_INIT_LIST_ONE, 0, $1, 0);} 
                        |   LR initializer_list RR {$$=$2;}
                        |   LR initializer_list COMMA RR {$$=$2;}
                        ;

initializer_list        :   initializer {$$=makeNode(N_INIT_LIST,$1,0,makeNode(N_INIT_LIST_NIL,0,0,0));}
                        | initializer_list COMMA initializer {$$=makeNodeList(N_INIT_LIST,$1,$3);}
                        ;

statement               : labeled_statement {$$=$1;}
                        | compound_statement {$$=$1;}
                        | expression_statement {$$=$1;}
                        | selection_statement {$$=$1;}
                        | iteration_statement {$$=$1;}
                        | jump_statement {$$=$1;}
                        ;

labeled_statement       : CASE_SYM constant_expression COLON statement {$$=makeNode(N_STMT_LABEL_CASE,$2,0,$4);}
                        | DEFAULT_SYM COLON statement {$$=makeNode(N_STMT_LABEL_DEFAULT,0,$3,0);}
                        ;

compound_statement      : LR {$$=current_id; current_level++;} declaration_list_opt statement_list_opt RR {checkForwardReference(); current_level--; current_id=$2; $$=makeNode(N_STMT_COMPOUND,$3,0,$4);}
                        ;

declaration_list_opt    : /* empty */ {$$=NIL;}
                        | declaration_list {$$=$1;}
                        ;

declaration_list        : declaration {$$=$1;}
                        | declaration_list declaration {$$=linkDeclaratorList($1, $2);}
                        ;

statement_list          : statement {$$=makeNode(N_STMT_LIST,$1,0,makeNode(N_STMT_LIST_NIL,0,0,0));}
                        | statement_list statement {$$=makeNodeList(N_STMT_LIST,$1,$2);}
                        ;

statement_list_opt  : /* empty */ {$$=makeNode(N_STMT_LIST_NIL,0,0,0);}
                    | statement_list {$$=$1;}

expression_statement    : SEMICOLON {$$=makeNode(N_STMT_EMPTY,0,0,0);}
                        | expression SEMICOLON {$$=makeNode(N_STMT_EXPRESSION,0,$1,0);}
                        ;

selection_statement     : IF_SYM LP expression RP statement {$$=makeNode(N_STMT_IF,$3,0,$5);}
                        | IF_SYM LP expression RP statement ELSE_SYM statement {$$=makeNode(N_STMT_IF_ELSE,$3,$5,$7);}
                        | SWITCH_SYM LP expression RP statement {$$=makeNode(N_STMT_SWITCH,$3,0,$5);}
                        ;

iteration_statement     : WHILE_SYM LP expression RP statement {$$=makeNode(N_STMT_WHILE,$3,0,$5);}
                        | DO_SYM statement WHILE_SYM LP expression RP SEMICOLON {$$=makeNode(N_STMT_DO,$2,0,$5);}
                        | FOR_SYM LP for_expression RP statement {$$=makeNode(N_STMT_FOR,$3,0,$5);}
                        ;

for_expression  : expression_opt SEMICOLON expression_opt SEMICOLON expression_opt {$$=makeNode(N_FOR_EXP,$1,$3,$5);} 
                ;

expression_opt          : /* empty */ {$$=0;}
                        | expression {$$=$1;}
                        ;

jump_statement          : RETURN_SYM expression_opt SEMICOLON {$$=makeNode(N_STMT_RETURN,0,$2,0);}
                        | CONTINUE_SYM SEMICOLON {$$=makeNode(N_STMT_CONTINUE,0,0,0);}
                        | BREAK_SYM SEMICOLON {$$=makeNode(N_STMT_BREAK,0,0,0);}
                        ;

primary_expression      : IDENTIFIER {$$=makeNode(N_EXP_IDENT,0,getIdentifierDeclared($1),0);}
                        | INTEGER_CONSTANT {$$=makeNode(N_EXP_INT_CONST,0,$1,0);}
                        | FLOAT_CONSTANT {$$=makeNode(N_EXP_FLOAT_CONST,0,$1,0);}
                        | CHARACTER_CONSTANT {$$=makeNode(N_EXP_CHAR_CONST,0,$1,0);}
                        | STRING_LITERAL {$$=makeNode(N_EXP_STRING_LITERAL,0,$1,0);}
                        | LP expression RP {$$=$2;}
                        ;

postfix_expression      : primary_expression {$$=$1;}
                        | postfix_expression LB expression RB {$$=makeNode(N_EXP_ARRAY,$1,0,$3);}
                        | postfix_expression LP arg_expression_list_opt RP {$$=makeNode(N_EXP_FUNCTION_CALL,$1,0,$3);}
                        | postfix_expression DOT IDENTIFIER {$$=makeNode(N_EXP_STRUCT,$1,0,$3);}
                        | postfix_expression ARROW IDENTIFIER {$$=makeNode(N_EXP_ARROW,$1,0,$3);}
                        | postfix_expression PLUSPLUS {$$=makeNode(N_EXP_POST_INC,0,$1,0);}
                        | postfix_expression MINUSMINUS {$$=makeNode(N_EXP_POST_DEC,0,$1,0);}
                        ;

arg_expression_list_opt : /* empty */ {$$=makeNode(N_ARG_LIST_NIL,0,0,0);}
                        | arg_expression_list {$$=$1;}
                        ;

arg_expression_list     : assignment_expression {$$=makeNode(N_ARG_LIST,$1,0,makeNode(N_ARG_LIST_NIL,0,0,0));}
                        | arg_expression_list COMMA assignment_expression {$$=makeNodeList(N_ARG_LIST,$1,$3);}
                        ;

unary_expression    : postfix_expression {$$=$1;}
                    | PLUSPLUS unary_expression {$$=makeNode(N_EXP_PRE_INC,0,$2,0);}
                    | MINUSMINUS unary_expression {$$=makeNode(N_EXP_PRE_DEC,0,$2,0);}
                    | AMP cast_expression {$$=makeNode(N_EXP_AMP,0,$2,0);}
                    | STAR cast_expression {$$=makeNode(N_EXP_STAR,0,$2,0);}
                    | EXCL cast_expression {$$=makeNode(N_EXP_NOT,0,$2,0);}
                    | MINUS cast_expression {$$=makeNode(N_EXP_MINUS,0,$2,0);}
                    | PLUS cast_expression {$$=$1;}
                    | SIZEOF_SYM unary_expression {$$=makeNode(N_EXP_SIZE_EXP,0,$2,0);}
                    | SIZEOF_SYM LP type_name RP {$$=makeNode(N_EXP_SIZE_TYPE,0,$3,0);}


cast_expression         : unary_expression {$$=$1;}
                        | LP type_name RP cast_expression {$$=makeNode(N_EXP_CAST, $2, 0, $4);}
                        ;


type_name               : declaration_specifiers {$$=getTypeFromSpecifier($1);}
                        | declaration_specifiers abstract_declarator  {$$=setTypeNameSpecifier($2,$1);}
                        ;

multiplicative_expression    : cast_expression {$$=$1;}
                             | multiplicative_expression STAR cast_expression {$$=makeNode(N_EXP_MUL,$1,0,$3);}
                             | multiplicative_expression SLASH cast_expression {$$= makeNode(N_EXP_DIV,$1,0,$3);}
                             | multiplicative_expression PERCENT cast_expression {$$= makeNode(N_EXP_MOD,$1,0,$3);}
                             ;

additive_expression         : multiplicative_expression {$$=$1;}
                            | additive_expression PLUS multiplicative_expression {$$=makeNode(N_EXP_ADD,$1,0,$3);}
                            | additive_expression MINUS multiplicative_expression {$$=makeNode(N_EXP_SUB,$1,0,$3);}
                            ;

shift_expression            : additive_expression {$$=$1;}
                            ;
relational_expression   : shift_expression {$$=$1;}
                        | relational_expression LSS shift_expression {$$=makeNode(N_EXP_LSS,$1,0,$3);}
                        | relational_expression GTR shift_expression {$$=makeNode(N_EXP_GTR,$1,0,$3);}
                        | relational_expression LEQ shift_expression {$$=makeNode(N_EXP_LEQ,$1,0,$3);}
                        | relational_expression GEQ shift_expression {$$=makeNode(N_EXP_GEQ,$1,0,$3);}
                        ;

equality_expression  : relational_expression {$$=$1;}
                     | equality_expression EQL relational_expression {$$=makeNode(N_EXP_EQL,$1,0,$3);}
                     | equality_expression NEQ relational_expression {$$=makeNode(N_EXP_NEQ,$1,0,$3);}
                     ;

AND_expression              : equality_expression {$$=$1;}
                            ;

exclusive_OR_expression     : AND_expression {$$=$1;}
                            ;

inclusive_OR_expression     : exclusive_OR_expression {$$=$1;}
                            ;
logical_AND_expression  : inclusive_OR_expression {$$=$1;}
                        | logical_AND_expression AMPAMP inclusive_OR_expression {$$=makeNode(N_EXP_AND,$1,0,$3);}
                        ;

logical_OR_expression       : logical_AND_expression {$$=$1;}
                            | logical_OR_expression BARBAR logical_AND_expression {$$=makeNode(N_EXP_OR,$1,0,$3);}
                            ;

conditional_expression      : logical_OR_expression {$$=$1;}
                            ;

assignment_expression       : conditional_expression {$$=$1;}
                            | unary_expression ASSIGN assignment_expression {$$=makeNode(N_EXP_ASSIGN, $1, 0, $3);}
                            ;

comma_expression            : assignment_expression {$$=$1;}
                            ;

expression                  : comma_expression {$$=$1;}
                            ;

constant_expression         : expression {$$=$1;}

%%

A_NODE *makeNode (NODE_NAME n, A_NODE *a, A_NODE *b, A_NODE *c) {
    A_NODE *m;
    m = (A_NODE*) malloc(sizeof(A_NODE));
    m->name = n;
    m->llink = a;
    m->clink = b;
    m->rlink = c;
    m->type = NIL;
    m->line = line_no;
    m->value = 0;
    return (m);
}


// link a's right-edge node (N_INIT_LIST_NIL node)
// left : b
// right: N_INIT_LIST_NIL (m)
A_NODE *makeNodeList(NODE_NAME n, A_NODE *a, A_NODE *b) {
    A_NODE *m, *k;
    k = a;
    while (k->rlink)
        k = k->rlink;
    m = (A_NODE*) malloc(sizeof(A_NODE));
    m->name = k->name;
    m->llink = NIL;
    m->clink = NIL;
    m->rlink = NIL;
    m->type  = NIL;
    m->line  = line_no;
    m->value = 0;
    k->name = n;
    k->llink = b;
    k->rlink = m;
    return (a);
}

A_ID *makeIdentifier(char *s) {
    A_ID *id;
    id = malloc(sizeof(A_ID));
    id->name = s;
    id->kind = 0;
    id->specifier = 0;
    id->level = current_level;
    id->address = 0;
    id->init = NIL;
    id->type = NIL;
    id->link = NIL;
    id->line = line_no;
    id->value = 0;
    id->prev = current_id;
    current_id = id;
    return (id);
}


// make a new declarator for dummy identifier
// e.g. function definition " int func(int a, ...); "
// this function is used to analyze '...' above the non-terminal symbol.
A_ID *makeDummyIdentifier() {
    A_ID *id;
    id = malloc(sizeof(A_ID));
    id->name = "";
    id->kind = 0;
    id->specifier = 0;
    id->level = current_level;
    id->address = 0;
    id->init = NIL;
    id->type = NIL;
    id->link = NIL;
    id->line = line_no;
    id->value = 0;
    id->prev = 0;
    return (id);
}

A_TYPE *makeType(T_KIND k) {
    A_TYPE *t;
    t = malloc(sizeof(A_TYPE));
    t->kind = k;
    t->size = 0;
    t->local_var_size = 0;
    t->element_type = NIL;
    t->field = NIL;
    t->expr = NIL;
    t->check = FALSE;
    t->prt = FALSE; // ?? TODO: prt question.
    t->line = line_no;
    return (t);
}

A_SPECIFIER *makeSpecifier(A_TYPE *t, S_KIND s) {
    A_SPECIFIER *p;
    p = malloc(sizeof(A_SPECIFIER));
    p->type = t;
    p->stor = s;
    p->line = line_no;
    return (p);
}

// search the nearest symbol record
// FROM program's current_id(aka param id) WHERE s == id->name
A_ID *searchIdentifier(char *s, A_ID *id) {
    while (id) {
        if (strcmp(id->name, s) == 0)
            break;
        id = id->prev;
    }
    return (id);
}

// search the nearest symbol record
// FROM id's symbol table
// WHERE s == id->name
// AND current_level == id->level
A_ID *searchIdentifierAtCurrentLevel(char *s, A_ID *id) {
    while (id) {
        if(id->level < current_level)
            return (NIL);
        if (strcmp(id->name, s) == 0)
            break;
        id = id -> prev;
    }
    return (id);
}
            
    void checkForwardReference() {
        A_ID *id;
        A_TYPE *t;
        id = current_id;
        while(id) {
            
            if(id->level < current_level)
                break;
            // break if no problem in the current level.

            t = id->type;

            // check if there are any no-kind symbol records or
            // prototype strucr_or_enum symbol records.
            
            if(id->kind == ID_NULL)
                syntax_error(31, id->name);
            else if ((id->kind == ID_STRUCT || id->kind == ID_ENUM)
                    && t->field == NIL)
                syntax_error(32, id->name);
            id = id->prev;
        }
    }

    // set specifier's NIL or NULL members to default value.
    void setDefaultSpecifier(A_SPECIFIER *p) {
        if (p->type == NIL)
            p->type = int_type;
        if (p->stor == S_NULL)
            p->stor = S_AUTO;
    }

    // call this function when reduce
    // declarator_specifiers: type_specifier declaration_specifiers
    // | storage_class_specifier declaration_specifiers
    A_SPECIFIER *updateSpecifier(A_SPECIFIER *p, A_TYPE *t, S_KIND s) {
        if (t) {
            if (p -> type) {
                if (p->type == t)
                    ;
                // prevent sequential different type specifiers.
                else
                    syntax_error(24, NIL);
            } else
                p->type = t;
        }

        if (s) {
            if (p->stor) {
                if(s==p->stor)
                    ;
                // prevent sequential differnt storage class specifiers.
                else
                    syntax_error(24, NIL);
            } else {
                p->stor=s;
            }
        }
        return (p);
    }



    // id1's edge_node->link = id2
    A_ID *linkDeclaratorList(A_ID *id1, A_ID *id2) {
        A_ID *m = id1;
        if (id1==NIL)
            return (id2);

        while(m->link)
            m=m->link;
        m->link = id2;
        /*
        if (id1->kind == ID_STRUCT)
            prt_A_ID(id1);
        if (id2->kind == ID_STRUCT)
            prt_A_ID(id2);
            */
        return (id1);
    }

    // call if use id in the expression.
    // e.g. "a = 10;"
    // when "a" (IDENTIFIER) is reduced to a(primary_expression),
    // we should check if there is a symbol 'a' in the previous symbol tables.
    // else, error.
    // TODO: what if "a" is a 'ID_FUNC'?
    A_ID *getIdentifierDeclared(char *s) {
        A_ID *id;
        id = searchIdentifier(s, current_id);
        if(id == NIL)
            syntax_error(13, s);
        return (id);
    }


    // this is used
    // struct s;
    // ...
    // struct s a; << at this point.
    // so we do not have to check the completeness of the previous struct.
    A_TYPE *getTypeOfStructOrEnumRefIdentifier(T_KIND k, char *s, ID_KIND kk) {
        A_TYPE *t;
        A_ID *id;
        id = searchIdentifier(s, current_id);

        // if there is a prototype(same kind && same type-kind) with same name,
        // return cp->type. (do not check either complete or not)
        if (id) {
            if (id -> kind == kk && id ->type->kind == k) {
                return (id->type);
            } else
                syntax_error(11, s);
        }

        t = makeType(k);
        id = makeIdentifier(s);
        id->kind = kk;
        id->type = t;
        return (t);
    }

    // link n(syntax tree) to id(symbol record)
    // when reduce by the rule
    // declarator_initializer: declarator ASSIGN initializer
    // or
    // enumarator: IDENTIFIER ASSIGN expression
    A_ID *setDeclaratorInit(A_ID *id, A_NODE *n) {
        id->init = n;
        return (id);
    }

    // set symbol record's kind.
    A_ID *setDeclaratorKind(A_ID *id, ID_KIND k) {
        A_ID *a;
        a = searchIdentifierAtCurrentLevel(id->name, id->prev);
        if (a && a->kind == k) // typedef problem
            syntax_error(12, id->name);
        id->kind = k;
        return (id);
    }

    A_ID *setDeclaratorType(A_ID *id, A_TYPE *t) {
        id->type = t;
        return (id);
    }

    // link t to the end of the id's type record.
    A_ID *setDeclaratorElementType(A_ID *id, A_TYPE *t) {
        A_TYPE *tt;
        if (id->type == NIL) {
            id->type = t;
        } else {
            tt = id->type;
            while (tt && tt->element_type)
                tt=tt->element_type;
            tt->element_type = t;
        }
        return (id);
    }

    A_ID *setDeclaratorTypeAndKind(A_ID *id, A_TYPE *t, ID_KIND k) {
        id = setDeclaratorElementType(id, t);
        id = setDeclaratorKind(id, k);
        return (id);
}

A_ID *setFunctionDeclaratorSpecifier(A_ID *id, A_SPECIFIER *p) {
    // function storage class should be S_AUTO
    A_ID *a;
    if (p->stor)
        syntax_error(25, NIL);
    setDefaultSpecifier(p);

    // id->type should be T_FUNC
    if(id->type == NIL || id->type->kind != T_FUNC) {
        syntax_error(21, NIL);
        return (id);
    } else {
        id = setDeclaratorElementType(id, p->type);
        id->kind = ID_FUNC;
    }

    // if there is a prototype,
    // it should be same kind, have same return type,
    a = searchIdentifierAtCurrentLevel(id->name, id->prev);
    if (a) {
        if (a->kind != ID_FUNC || a->type->expr)
            syntax_error(12, id->name);
        else {
            if (isNotSameFormalParameters(a->type->field, id->type->field))
                syntax_error(22, id->name);
            if (isNotSameType(a->type->element_type, id->type->element_type))
                syntax_error(26, a->name);
        }
    }

    // push the current_id to the end of the parameter list
    a = id->type->field;
    while (a) {
        if (strlen(a->name))
            current_id=a;
        else if (a->type)
            syntax_error(23, NIL);
        a = a->link;
    }
    return (id);
}

A_ID *setFunctionDeclaratorBody(A_ID *id, A_NODE *n) {
    if(id->type != NIL)
        id->type->expr = n;
    else
        syntax_error(21, NIL);
    return (id);
}

A_ID *setDeclaratorListSpecifier(A_ID *id, A_SPECIFIER *p) {
    A_ID *a;
    // TODO setDefaultSpecifier: p->stor is not S_NULL.
    setDefaultSpecifier(p);
    a = id;
    while(a) {
        if (strlen(a->name) && searchIdentifierAtCurrentLevel(a->name, a->prev))
            syntax_error(12, a->name);
        a = setDeclaratorElementType(a, p->type);
        if(p->stor==S_TYPEDEF)
            a->kind = ID_TYPE;
        else if (a->type->kind == T_FUNC)
            a->kind = ID_FUNC;
        else
            a->kind = ID_VAR;
        a->specifier = p->stor;
        
        /* TODO: discuss with CJ
        // I think the code below might be reduntant..
        if(a->specifier==S_NULL)
            a->specifier=S_AUTO;
        // because we'd already call setDefaultSpecifier(p)..
        */
        
        a = a->link;
    }
    return (id);
}

A_ID *setParameterDeclaratorSpecifier(A_ID *id, A_SPECIFIER *p) {
    if(searchIdentifierAtCurrentLevel(id->name, id->prev))
        syntax_error(12, id->name);
    
    if(p->stor)
        syntax_error(14, NIL);


    // if parameter is void, param_field should be NIL.
    // TODO: size == 0 && check == TRUE if and only if type == void
    if(p->type->size == 0 && p->type->check == TRUE) {
        return NIL;
    }
    setDefaultSpecifier(p);
    id = setDeclaratorElementType(id, p->type);
    id->kind = ID_PARM;
    return (id);
}



A_ID *setStructDeclaratorListSpecifier(A_ID *id, A_TYPE *t) {
    A_ID *a;
    a = id;
    while(a) {
        if (searchIdentifierAtCurrentLevel(a->name, a->prev))
            syntax_error(12, a->name);
        // printf("a->name: %s\n", a->name);
        a = setDeclaratorElementType(a, t);
        a->kind = ID_FIELD;
        a = a->link;
    }
    return (id);
}

A_TYPE *getTypeFromSpecifier(A_SPECIFIER *p) {
    if (p->stor)
        syntax_error(20, NIL);
    return p->type;
}

A_TYPE *setTypeNameSpecifier(A_TYPE *t, A_SPECIFIER *p) {
    if (p->stor)
        syntax_error(20, NIL);
    setDefaultSpecifier(p);
    t = setTypeElementType(t, p->type);
    return (t);
}


// link the type record s with
// the end of the type record t.
A_TYPE *setTypeElementType(A_TYPE *t, A_TYPE *s) {
    A_TYPE *q;
    if (t == NIL)
        return s;
    q = t;
    while (q->element_type)
        q = q->element_type;
    q->element_type = s;
    return (t);
}

A_TYPE *setTypeField(A_TYPE *t, A_ID *n) {
    t->field = n;
    return (t);
}

A_TYPE *setTypeExpr(A_TYPE *t, A_NODE *n) {
    t->expr = n;
    return (t);
}


// this is used
//
// line 2: struct s;
// ...
// line 4: struct s (!) { int id; } s;  at (!) point.
//
// because there is a struct_declaration_list in the line 4, (actually, when LR in the next token)
// the prototype's field in the line 2 should be NIL.
A_TYPE *setTypeStructOrEnumIdentifier(T_KIND k, char *s, ID_KIND kk) {
    A_TYPE *t;
    A_ID *id, *a, *b;
    b = current_id;

    a = searchIdentifierAtCurrentLevel(s, b);
    if (a) {
        if (a->kind == kk && a->type->kind == k) {
            if (a->type->field)
                syntax_error(12, s);
            else
                return (a->type);
        } else
            syntax_error(12, s);
    }

    id = makeIdentifier(s);
    t = makeType(k);
    id->type = t;
    id->kind = kk;
    return (t);
}


// use when set default type record.
A_TYPE *setTypeAndKindOfDeclarator(A_TYPE *t, ID_KIND k, A_ID *id) {
    if (searchIdentifierAtCurrentLevel(id->name, id->prev))
        syntax_error(12, id->name);
    id->type = t;
    id->kind = k;
    return (t);
}

// Initially, parameter a, b is pointing the first ID_PARM symbol record of each T_FUNC type table.
BOOLEAN isNotSameFormalParameters(A_ID *a, A_ID *b) {
    // return FALSE when parameters matched.
    // return TRUE  when parameters mismatched.
    if ((a == NIL && b != NIL) || 
            (a != NIL && b == NIL)) 
        return (TRUE);
    
    while(a) {
        if ( b != NIL) {
           if ( isVaArgs(a) && isVaArgs(b) )
               return (FALSE);
           else if (isVaArgs(a) != isVaArgs(b) )
               return (TRUE);
        }

        if (b == NIL || isNotSameType(a->type, b->type))
            return (TRUE);
        a = a->link;
        b = b->link;
    }
    if (b)
        return (TRUE);
    else
        return (FALSE);
}

BOOLEAN isVaArgs(A_ID* a) {
    return strcmp(a->name, "") == 0 && a->type == NIL && a->kind == ID_PARM;
}

// check if the two types are same by recursive calling..
// until else statement is returned..
BOOLEAN isNotSameType(A_TYPE *t1, A_TYPE *t2) {
    if (isPointerOrArrayType(t1) && isPointerOrArrayType(t2)) {
        return isNotSameType(t1->element_type,t2->element_type);
    } else if (t1->kind == T_FUNC && t2->kind == T_FUNC) {
        if (isNotSameFormalParameters(t1->field, t2->field))
            return TRUE;
        if (isNotSameType(t1->element_type, t2->element_type))
            return TRUE;
        return FALSE;
    } else
        return (t1!=t2);
}

BOOLEAN isPointerOrArrayType(A_TYPE *t1) {
    if( t1 && (t1 -> kind == T_POINTER || t1->kind == T_ARRAY))
        return TRUE;
    else
        return FALSE;
}

void initialize() {
    // set default data type
    int_type = setTypeAndKindOfDeclarator(
            makeType(T_ENUM), ID_TYPE, makeIdentifier("int"));
    float_type = setTypeAndKindOfDeclarator(
            makeType(T_ENUM), ID_TYPE, makeIdentifier("float"));
    char_type = setTypeAndKindOfDeclarator(
            makeType(T_ENUM), ID_TYPE, makeIdentifier("char"));
    void_type = setTypeAndKindOfDeclarator(
            makeType(T_ENUM), ID_TYPE, makeIdentifier("void"));

    string_type = setTypeElementType(makeType(T_POINTER), char_type);

    int_type->size = 4;
    int_type->check = TRUE;

    float_type->size = 4;
    float_type->check = TRUE;

    char_type->size = 1;
    char_type->check = TRUE;
    
    void_type->size = 0;
    void_type->check = TRUE;

    string_type->size = 4; // TODO maybe the size of the address..
    string_type->check = TRUE;

    // compiler needs ability to parse printf function (library function)
    // even if there isn't a printf function (library function) declaration on the target file.
    setDeclaratorTypeAndKind(
            makeIdentifier("printf"),
            setTypeField(
                    setTypeElementType(
                            makeType(T_FUNC),
                            void_type
                            ),
                    linkDeclaratorList(
                            setDeclaratorTypeAndKind(
                                    makeDummyIdentifier(),
                                    string_type,
                                    ID_PARM
                                    ),
                            setDeclaratorKind(
                                    makeDummyIdentifier(),
                                    ID_PARM
                            )
                    )
            ),
            ID_FUNC);
    
    setDeclaratorTypeAndKind(
            makeIdentifier("scanf"),
            setTypeField(
                    setTypeElementType(
                            makeType(T_FUNC),
                            void_type
                            ),
                    linkDeclaratorList(
                            setDeclaratorTypeAndKind(
                                    makeDummyIdentifier(),
                                    string_type,
                                    ID_PARM
                                    ),
                            setDeclaratorKind(
                                    makeDummyIdentifier(),
                                    ID_PARM
                            )
                    )
            ),
            ID_FUNC);
    setDeclaratorTypeAndKind(
            makeIdentifier("malloc"),
            setTypeField(
                    setTypeElementType(
                            makeType(T_FUNC),
                            string_type
                            ),
                    setDeclaratorTypeAndKind(
                                    makeDummyIdentifier(),
                                    string_type,
                                    ID_PARM
                                    )
            ),
            ID_FUNC);
}




void syntax_error(int i, char *s) {
    syntax_err++;
    printf("line %d: syntax error: ", line_no);
    switch (i) {
        case 11: printf("illegal referencing struct or union identifier %s", s);
        break;
        
        case 12: printf("redeclaration of identifier %s", s); break;
        case 13: printf("undefined identifier %s", s); break;
        case 14: printf("illegal type specifier in formal parameter"); break;
        case 20: printf("illegal storage class in type specifiers"); break;
        case 21: printf("illegal function declarator"); break;
        case 22: printf("conflicting parm type in prototype function %s", s); break;
        case 23: printf("empty parameter name"); break;
        case 24: printf("illegal declaration specifiers"); break;
        case 25: printf("illegal function specifiers"); break;
        case 26: printf("illegal or conflicting return type in function %s", s); break;
        case 31: printf("undefined type for identifier %s", s); break;
        case 32: printf("incomplete forward reference for identifier %s", s); break;
        default: printf("unknown"); break;
   }

    if (strlen(yytext) == 0)
        printf("at end\n");
    else
        printf("near %s\n", yytext);
}        
            



int yyerror(char* s)
{
    fprintf(stderr, "error: %s \n", s);
    exit(EXIT_FAILURE);
}


extern void print_sem_ast(A_NODE *);
extern void semantic_analysis(A_NODE *);

int main() {
    initialize();
    yyparse(); 
    if (syntax_err) exit(1);
    print_ast(root);
    semantic_analysis(root);
    if (semantic_err) exit(1);
    print_sem_ast(root);
}
