struct mys;

struct mys {
    int a;
    int b;
    int c;
    float f1, f2, f3;
    struct {
        int annonymus;
        union {
            int i;
            char c;
        } itsunion;
    } itsstruct;

    int adsa[612];
};
int main() {
    struct mys mystruct;
    return 0;
}


int func() {
    struct mys mys2;
    char* p;
    p = "heool";
    mys2.a = 1;
    mys2.itsstruct.itsunion.i;
    return 0;
}

