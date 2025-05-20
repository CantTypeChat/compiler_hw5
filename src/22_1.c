int ret_1(int);
int ret_1(float a) {return (int) (a + 1.0);}
int ret_2(int (*)(float));
int ret_2(int (*f)(int)) {
    return f(1);
}


