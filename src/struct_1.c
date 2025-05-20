struct s;
struct s {
    int a : 4;
    int : 24;
    int b : 4;
};

int func(struct s ss) {
    return ss.a + ss.b;
}
