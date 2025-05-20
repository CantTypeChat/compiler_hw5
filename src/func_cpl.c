
int add_three(int, int (*)(int, int));
int add_two(int, int);

int add_three(int n, int (*parameter_function)(int, int)) {
    return n + parameter_function(n, n);
}

int add_two(int a, int b) {
    return a + b;
}
int main()
{
    printf("%d\n", add_three(1, add_two));
    return 0;
}
