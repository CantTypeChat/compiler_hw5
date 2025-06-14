#!/bin/bash

ASM_FILE=asm.c
MAIN_FILE=main.c
SEM_FILE=sem.c
YACC_FILE=parse.y
LEX_FILE=lex2.l
EXECUTABLE=./test
SRC_DIR=src
SYN_AST=print.c
SEM_AST=print_sem.c
flex $LEX_FILE
byacc -vd $YACC_FILE

cc -w -g -o test $SYN_AST $SEM_AST lex.yy.c y.tab.c $SEM_FILE $MAIN_FILE $ASM_FILE

