struct s;
struct s {
    int a, b;
};

struct s* func() {
    struct s* s_node = (struct s*) malloc(sizeof(struct s));
    s_node->a = s_node->b = 1;
    return s_node;
}
