struct mys;

int main() {
    struct mys mystruct;
    return 0;
}

int func() {
    struct mys mys2;
    char* p = "heool";
    mys.a = 1;
    mys.itsstruct.itsunion.i;
    return 0;

}

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

