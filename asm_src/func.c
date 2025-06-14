int func(int a, int b);

void main() {
    int a, b;
    int result;
    scanf("%d %d", &a, &b);
    result = func(a, b);
    printf("result was: %d\n", result);
}

int func(int a, int b) {
    int c;
    c = a + b;
    printf("add a and b was: %d\n", c);
    return c;
}
