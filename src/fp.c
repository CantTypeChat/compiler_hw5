

int f(int (*p)(int)) {
    return p(1);
}

int add_one(int a) {
    return a + 1;
}

int main()
{
    printf("%d\n", f(add_one));
    return 0;
}
