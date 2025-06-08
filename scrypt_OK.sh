#!/bin/bash

SEM_FILE=sem.c
YACC_FILE=parse.y
LEX_FILE=lex2.l
EXECUTABLE=./test
SRC_DIR=src
SYN_AST=print.c
SEM_AST=print_sem.c
echo "Checking for segfaults in $SRC_DIR/*.c ..."

flex $LEX_FILE
byacc -vd $YACC_FILE

cc -w -g -o test $SYN_AST $SEM_AST lex.yy.c y.tab.c $SEM_FILE

