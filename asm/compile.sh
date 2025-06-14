
LEX_FILE=interp.l
YACC_FILE=interp.y
YACC_FUNC_FILE=interp.c
LIB_FILE=lib.c

byacc -vd $YACC_FILE
flex $LEX_FILE
cc -w -g -o executor lex.yy.c y.tab.c $LIB_FILE $YACC_FUNC_FILE

