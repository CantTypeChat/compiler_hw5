
int myfunc(int a, int b) {
    return a + b;
}

int main()
{
    int (*func)(int, int);
    func = myfunc;
    func(1, 2);
    return 0;
}
