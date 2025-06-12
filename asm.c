#include <stdio.h>
#include <string.h>
#include "type.h"

typedef enum OP { OP_NULL, LOD, LDX, LDXB, LDA, LITI,
                  STO, STOB, STX, STXB,
                  SUBI, SUBF, DIVI, DIVF, ADDI, ADDF, OFFSET, MULI, MULF, MOD,
                  LSSI, LSSF, GTRI, GTRF,
                  LEQI, LEQF, GEQI, GEQF, NEQI, NEQF, EQLI, EQLF,
                  NOT, OR, AND, CVTI, CVTF,
                  JPC, JPCR, JMP, JPT, JPTR,
                  INT, INCI, INCF, DECI, DECF,
                  SUP, CAL, ADDR, RET,
                  MINUSI, MINUSF, CHK,
                  LDI, LDIB, SWITCH, SWVALUE, SWDEFAULT, SWLABEL, SWEND,
                  POP, POPB } OPCODE;

char *opcode_name[] = {
  "OP_NULL","LOD","LDX","LDXB","LDA","LITI",
  "STO","STOB","STX","STXB","SUBI","SUBF","DIVI","DIVF","ADDI","ADDF","OFFSET","MULI","MULF","MOD",
  "LSSI","LSSF","GTRI","GTRF",
  "LEQI","LEQF","GEQI","GEQF","NEQI","NEQF","EQLI","EQLF",
  "NOT","OR","AND","CVTI","CVTF",
  "JPC","JPCR","JMP","JPT","JPTR",
  "INT","INCI","INCF","DECI","DECF",
  "SUP","CAL","ADDR","RET",
  "MINUSI","MINUSF","CHK","LDI","LDIB",
  "SWITCH","SWVALUE","SWDEFAULT","SWLABEL","SWEND","POP","POPB"
};

typedef enum { SW_VALUE, SW_DEFAULT } SW_KIND;
typedef struct sw { SW_KIND kind; int val; int label; } A_SWITCH;

void code_generation(A_NODE *);
void gen_literal_table();
void gen_program(A_NODE *);
void gen_expression(A_NODE *);
void gen_expression_left(A_NODE *);
void gen_arg_expression(A_NODE *);
void gen_statement(A_NODE *, int, int, A_SWITCH[], int *);
void gen_statement_list(A_NODE *, int, int, A_SWITCH[], int *);
void gen_initializer_global(A_NODE *, A_TYPE *, int);
void gen_initializer_local(A_NODE *, A_TYPE *, int);
void gen_declaration_list(A_ID *);
void gen_declaration(A_ID *);
void gen_code_i(OPCODE, int, int);
void gen_code_f(OPCODE, int, float);
void gen_code_s(OPCODE, int, char *);
void gen_code_l(OPCODE, int, int);
void gen_label_number(int);
void gen_label_name(char *);
void gen_error();
int get_label();
int label_no = 0;
int gen_err = 0;
extern FILE *fout;
extern A_TYPE *int_type, *float_type, *char_type, *void_type, *string_type;
extern A_LITERAL literal_table[];
extern int literal_no;

void code_generation(A_NODE *node)
{
    gen_program(node);
    gen_literal_table();
}

void gen_literal_table()
{
    int i;
    for (i = 1; i <= literal_no; i++) {
        fprintf(fout, "literal %5d  ", literal_table[i].addr);
        if (literal_table[i].type == int_type)
            fprintf(fout, "%d\n", literal_table[i].value.i);
        else if (literal_table[i].type == float_type)
            fprintf(fout, "%f\n", literal_table[i].value.f);
        else if (literal_table[i].type == char_type)
            fprintf(fout, "%d\n", literal_table[i].value.c);
        else if (literal_table[i].type == string_type)
            fprintf(fout, "%s\n", literal_table[i].value.s);
    }
}

void gen_program(A_NODE *node)
{
    switch (node->name) {
        case N_PROGRAM:
            gen_code_i(INT, 0, node->value);
            gen_code_s(SUP, 0, "main");
            gen_code_i(RET, 0, 0);
            gen_declaration_list(node->clink);
            break;
        default:
            gen_error(100, node->line);
            break;
    }
}


