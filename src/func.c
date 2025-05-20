
typedef int DATA;
typedef struct s_node S_NODE;
struct s_node {
    DATA data;
    S_NODE* next;
};

int func(S_NODE* s) {
    return 1;
}
